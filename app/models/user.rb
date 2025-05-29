class User < ApplicationRecord
  has_secure_password
  
  validates :email, presence: true, uniqueness: true
  validates :name, presence: true

  def generate_jwt
    payload = {
      user_id: id,
      email: email,
      exp: 24.hours.from_now.to_i
    }
    JWT.encode(payload, Rails.application.secret_key_base)
  end

  def self.decode_jwt(token)
    decoded = JWT.decode(token, Rails.application.secret_key_base)
    find(decoded[0]['user_id'])
  rescue JWT::DecodeError, ActiveRecord::RecordNotFound
    nil
  end
end