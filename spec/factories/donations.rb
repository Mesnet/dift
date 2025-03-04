FactoryBot.define do
  factory :donation do
    association :user
    association :project
    amount { 1000 }      # amount in cents
    currency { "EUR" }
  end
end
