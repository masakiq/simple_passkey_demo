# frozen_string_literal: true

# rubocop:disable Style/HashSyntax
# User
class User
  attr_reader :id, :webauthn_id, :name, :password

  class << self
    def create(name:, password:)
      DB.execute('INSERT INTO users (name, password) VALUES (?, ?)', [name, password])
      find_by(name: name)
    end

    def find_by(**options)
      key_queries = options.keys.map { |k| "#{k} = ?" }
      query = "SELECT * FROM users WHERE #{key_queries.join(' and ')}"
      result = DB.execute(query, options.values).first
      return nil unless result

      build(result)
    end

    private

    def build(data)
      new(
        id: data[0],
        webauthn_id: data[1],
        name: data[2],
        password: data[3]
      )
    end
  end

  def initialize(id:, webauthn_id:, name:, password:)
    @id = id
    @webauthn_id = webauthn_id
    @name = name
    @password = password
  end

  def update_webauthn_id(webauthn_id)
    DB.execute('UPDATE users SET webauthn_id = ? WHERE id = ?', [webauthn_id, id])
    @webauthn_id = webauthn_id
  end

  def add_credential(webauthn_id:, name:, public_key:, transports:, sign_count:)
    Credential.create(
      user_id: id,
      webauthn_id: webauthn_id,
      name: name,
      public_key: public_key,
      transports: transports,
      sign_count: sign_count
    )
  end

  def credentials
    Credential.find_all_by_user_id(id)
  end
end
