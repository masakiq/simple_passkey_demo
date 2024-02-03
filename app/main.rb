# rubocop:disable Metrics/BlockLength, Metrics/MethodLength
require 'sinatra'
require 'openssl'
require 'securerandom'
require 'json'
require 'cbor'
require 'pry'
require 'webauthn'
require 'sqlite3'
require 'uri'
require_relative 'init_db'
require_relative 'models/user'
require_relative 'models/credential'

ORIGIN_URI = URI.parse(ARGV[0] || 'http://localhost:4567')

set :bind, '0.0.0.0'
set :port, 4567
enable :sessions

helpers do
  def logged_in?
    !!session[:user_id]
  end

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def user_platform
    case request.user_agent
    when /Windows NT/
      'Windows'
    when /Macintosh/
      'MacOS'
    when /Linux/
      'Linux'
    when /iPhone|iPad|iPod/
      'iOS'
    when /Android/
      'Android'
    else
      'Unknown'
    end
  end
end

WebAuthn.configure do |config|
  config.origin = ORIGIN_URI.to_s
  config.rp_name = 'Simple Passkey Demo Inc.'
  config.rp_id = ORIGIN_URI.host
end

get '/' do
  redirect '/account' if logged_in?
  erb :index
end

get '/account' do
  redirect '/' unless logged_in?
  @user = current_user
  unless @user
    session.clear
    redirect '/'
    return
  end
  erb :account
end

post '/logout' do
  session.clear
  redirect '/'
end

post '/register' do
  name = request.params['name']
  password = request.params['password']
  user = User.create(name: name, password: password)

  session[:user_id] = user.id
  redirect '/account'
rescue SQLite3::ConstraintException => e
  redirect '/?error=already_registered_user'
end

post '/login' do
  name = request.params['name']
  password = request.params['password']
  user = User.find_by(name: name)
  unless user
    redirect '/?error=user_not_found'
    return
  end

  unless user.password == password
    redirect '/?error=login_failed'
    return
  end

  session[:user_id] = user.id
  redirect '/account'
rescue SQLite3::ConstraintException => e
  redirect '/?error=already_registered_user'
end

post '/register_passkey_challenge' do
  content_type :json

  unless logged_in?
    status 401
    return { status: 'error', message: 'Not logged in' }.to_json
  end
  unless current_user
    session.clear
    status 404
    return { status: 'error', message: 'User not found' }.to_json
  end

  current_user.update_webauthn_id(WebAuthn.generate_user_id) unless current_user.webauthn_id
  options = WebAuthn::Credential.options_for_create(
    user: { id: current_user.webauthn_id, name: current_user.name }
  )
  o = options.as_json
  o[:excludeCredentials] = current_user.credentials.map do |c|
    {
      id: c.webauthn_id,
      type: 'public-key',
      transports: c.transports
    }
  end
  session[:register_passkey_challenge] = options.challenge

  o.to_json
end

post '/register_publick_key' do
  content_type :json

  unless logged_in?
    status 401
    return { status: 'error', message: 'Not logged in' }.to_json
  end
  unless current_user
    session.clear
    status 404
    return { status: 'error', message: 'User not found' }.to_json
  end

  begin
    credentials = JSON.parse(request.body.read)

    client_data_json = JSON.parse(Base64.decode64(credentials['response']['clientDataJSON']))
    received_challenge = client_data_json['challenge']

    unless session[:register_passkey_challenge] == received_challenge
      status 401
      return { status: 'error', message: 'Invalid challenge' }.to_json
    end
    webauthn_credential = WebAuthn::Credential.from_create(credentials)
    webauthn_credential.verify(session[:register_passkey_challenge])

    current_user.add_credential(
      webauthn_id: webauthn_credential.id,
      name: user_platform,
      public_key: webauthn_credential.public_key,
      transports: credentials['response']['transports'],
      sign_count: webauthn_credential.sign_count.to_i
    )
    session[:register_passkey_challenge] = nil

    p '登録成功'
    { status: 'success', user_id: current_user.id }.to_json
  rescue JSON::ParserError => e
    p e
    status 400
    { status: 'error', message: 'Invalid JSON' }.to_json
  rescue WebAuthn::Error => e
    p e
    status 400
    { status: 'error', message: 'Invalid credentials' }.to_json
  rescue StandardError => e
    p e
    status 500
    { status: 'error', message: 'Internal Server Error' }.to_json
  end
end

# ユーザー認証
post '/login_with_passkey_challenge' do
  content_type :json

  options = WebAuthn::Credential.options_for_get
  session[:login_with_passkey_challenge] = options.challenge

  options.as_json.to_json
end

post '/login_with_passkey' do
  content_type :json
  credentials = JSON.parse(request.body.read)
  webauthn_id = credentials['response']['userHandle']
  user = User.find_by(webauthn_id: webauthn_id)
  unless user
    status 404
    { status: 'error', message: 'User not found' }.to_json
    return
  end

  webauthn_credential = WebAuthn::Credential.from_get(credentials)
  stored_credential = Credential.find_by(user_id: user.id, webauthn_id: webauthn_credential.id)

  begin
    webauthn_credential.verify(
      session[:login_with_passkey_challenge],
      public_key: stored_credential.public_key,
      sign_count: stored_credential.sign_count
    )
    session[:login_with_passkey_challenge] = nil

    stored_credential.update_sign_count(webauthn_credential.sign_count.to_i)
    session[:user_id] = user.id

    # Continue with successful sign in or 2FA verification...
    { status: 'ok', message: 'success' }.to_json
  rescue WebAuthn::SignCountVerificationError => e
    p e
    status 401
    { status: 'error', message: 'WebAuthn SignCountVerificationError' }.to_json
  rescue WebAuthn::Error => e
    p e
    status 500
    { status: 'error', message: 'WebAuthn Error' }.to_json
  end
end

get '/passkeys' do
  content_type :json

  unless logged_in?
    status 401
    return { status: 'error', message: 'Not logged in' }.to_json
  end
  unless current_user
    session.clear
    status 404
    return { status: 'error', message: 'User not found' }.to_json
  end

  current_user.credentials.map(&:as_json).to_json
end
