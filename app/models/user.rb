class User < ApplicationRecord
  has_secure_token :api_token

  validates :email, presence: true, uniqueness: true
end
