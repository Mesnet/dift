require 'rails_helper'

RSpec.describe Project, type: :model do
  it 'has a valid factory' do
    expect(build(:project)).to be_valid
  end

  it 'is invalid without a name' do
    expect(build(:project, name: nil)).not_to be_valid
  end
end
