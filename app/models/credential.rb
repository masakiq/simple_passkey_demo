# frozen_string_literal: true

# rubocop:disable Style/HashSyntax
# Credential
class Credential
  attr_reader :id, :user_id, :webauthn_id, :name, :public_key, :transports, :sign_count

  class << self
    def create(user_id:, webauthn_id:, name:, public_key:, transports:, sign_count:)
      DB.execute(
        'INSERT INTO credentials (user_id, webauthn_id, name, public_key, transports, sign_count) VALUES (?, ?, ?, ?, ?, ?)',
        [user_id, webauthn_id, name, public_key, transports.to_json, sign_count]
      )
      find_by(webauthn_id: webauthn_id)
    end

    def find_by(**options)
      key_queries = options.keys.map { |k| "#{k} = ?" }
      query = "SELECT * FROM credentials WHERE #{key_queries.join(' and ')}"
      result = DB.execute(query, options.values).first
      return nil unless result

      build(result)
    end

    def find_all_by_user_id(user_id)
      result = DB.execute(
        'SELECT * FROM credentials WHERE user_id = ?',
        [user_id]
      )
      return nil unless result

      public_keys = []
      result.each do |r|
        public_keys << build(r)
      end
      public_keys
    end

    private

    def build(data)
      new(
        id: data[0],
        user_id: data[1],
        webauthn_id: data[2],
        name: data[3],
        public_key: data[4],
        transports: JSON.parse(data[5]),
        sign_count: data[6]
      )
    end
  end

  def initialize(id:, user_id:, webauthn_id:, name:, public_key:, transports:, sign_count:)
    @id = id
    @user_id = user_id
    @webauthn_id = webauthn_id
    @name = name
    @public_key = public_key
    @transports = transports
    @sign_count = sign_count
  end

  def update_sign_count(sign_count)
    DB.execute('UPDATE credentials SET sign_count = ? WHERE id = ?', [sign_count, id])
    @sign_count = sign_count
  end

  def as_json
    {
      id: id,
      user_id: user_id,
      webauthn_id: webauthn_id,
      name: name,
      public_key: public_key,
      transports: transports,
      sign_count: sign_count
    }
  end
end
