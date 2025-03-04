class User < ApplicationRecord
  has_many :donations
  has_secure_token :api_token

  validates :email, presence: true, uniqueness: true
end
