require 'rails_helper'

RSpec.describe Donation, type: :model do
  it 'has a valid factory' do
    expect(build(:donation)).to be_valid
  end

  it 'is invalid without a user' do
    expect(build(:donation, user: nil)).not_to be_valid
  end

  it 'is invalid without a project' do
    expect(build(:donation, project: nil)).not_to be_valid
  end

  it 'is invalid without an amount' do
    expect(build(:donation, amount: nil)).not_to be_valid
  end

  it 'is invalid with amount less than or equal to 0' do
    expect(build(:donation, amount: 0)).not_to be_valid
  end

  it 'is invalid without a currency' do
    expect(build(:donation, currency: nil)).not_to be_valid
  end
end
