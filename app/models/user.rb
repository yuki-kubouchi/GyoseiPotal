class User < ApplicationRecord
  has_secure_password

  validates :email, presence: true, uniqueness: true
  validates :email, format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "は有効なメールアドレスを入力してください" }
  validates :password_digest, presence: true
end
