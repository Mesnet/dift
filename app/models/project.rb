class Project < ApplicationRecord
	has_many :donations
	validates :name, presence: true
end
