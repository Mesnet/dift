class Donation < ApplicationRecord
  belongs_to :user
  belongs_to :project

  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :currency, presence: true
end
