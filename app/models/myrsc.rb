class Myrsc < ActiveRecord::Base
  belongs_to :user
  before_save :encrypt_password

  def encrypt_password
    if password
      self.salt = SecureRandom.base64(40)
      self.password = Encryptor.encrypt(password, key: secret_key, iv: ENV['IV'], salt: salt)
    end
  end

  def decrypt_password
    Encryptor.decrypt(password, key: secret_key, iv: ENV['IV'], salt: salt)
  end

  private
  def secret_key
    "7ZLuESc6dMG0lkdXjAfQP0WXGi2TZ15jMQ1bKiOBz22aa0vSkHj6ohhEjLxqsXeiOSc="
  end
end
