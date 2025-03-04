# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

User.delete_all
Project.delete_all
Donation.delete_all

# Create Users using the :user factory
users = FactoryBot.create_list(:user, 10)
puts "Created #{users.count} users."

# Create Projects using the :project factory
projects = FactoryBot.create_list(:project, 5)
puts "Created #{projects.count} projects."

# Create Donations using the :donation factory
donations = []
10.times do
  donations << FactoryBot.create(:donation, user: users.sample, project: projects.sample)
end

puts "Created #{donations.count} donations."
