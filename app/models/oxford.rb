class Oxford < ActiveRecord::Base
  belongs_to :user
  before_save :encrypt_password

  def encrypt_password
    self.salt = SecureRandom.base64(40)
    self.password = Encryptor.encrypt(password, key: secret_key, iv: ENV['IV'], salt: salt)
  end

  def decrypt_password
    Encryptor.decrypt(password, key: secret_key, iv: ENV['IV'], salt: salt)
  end

  private
  def secret_key
    "NFUzAktEo6V+3oh9jJTBNJz7Y053silv5YmL3mX9VlQ3EMsos4EqQ6m1QEfX4fbxlJ2ShHuJRhlupmFi"
  end
end
