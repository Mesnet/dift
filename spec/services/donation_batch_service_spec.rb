require 'rails_helper'

RSpec.describe DonationBatchService do
  let(:user) { create(:user) }
  let(:project1) { create(:project) }
  let(:project2) { create(:project) }

  describe "#call" do
    context "with valid donations" do
      let(:donations_params) do
        [
          { project_id: project1.id, amount: 100, currency: "USD" },
          { project_id: project2.id, amount: 200, currency: "EUR" }
        ]
      end

      it "inserts all donations successfully" do
        expect {
          described_class.new(user: user, donations_params: donations_params).call
        }.to change(Donation, :count).by(2)
      end
    end

    context "when donation count exceeds the limit" do
      let(:donations_params) do
        Array.new(1001) { { project_id: project1.id, amount: 10, currency: "USD" } }
      end

      it "raises a TooManyDonationsError" do
        expect {
          described_class.new(user: user, donations_params: donations_params).call
        }.to raise_error(DonationBatchService::TooManyDonationsError, /Maximum batch size/)
      end
    end

    context "when project_id does not exist" do
      let(:donations_params) do
        [
          { project_id: 9999, amount: 50, currency: "USD" },
          { project_id: project1.id, amount: 100, currency: "EUR" }
        ]
      end

      it "raises an InvalidProjectIdsError with the invalid id" do
        expect {
          described_class.new(user: user, donations_params: donations_params).call
        }.to raise_error(DonationBatchService::InvalidProjectIdsError) do |error|
          expect(error.invalid_ids).to include(9999)
        end
      end
    end

    context "when donation is invalid (ex: negative amount)" do
      let(:donations_params) do
        [
          { project_id: project1.id, amount: -10, currency: "USD" },
          { project_id: project2.id, amount: 50, currency: "EUR" }
        ]
      end

      it "raises a ValidationError with details" do
        expect {
          described_class.new(user: user, donations_params: donations_params).call
        }.to raise_error(DonationBatchService::ValidationError) do |error|
          expect(error.errors.first[:index]).to eq(0)
          expect(error.errors.first[:errors]).to include("Amount must be greater than 0")
        end
      end
    end

    context "performance" do
      let(:donations_params) do
        Array.new(5) { { project_id: project1.id, amount: 100, currency: "USD" } }
      end

      it "instantiates only one base Donation object" do
        expect(Donation).to receive(:new).with(user: user).once.and_call_original

        described_class.new(user: user, donations_params: donations_params).call
      end

      it "performs a single insert_all query" do
        expect(Donation).to receive(:insert_all).once.and_call_original

        described_class.new(user: user, donations_params: donations_params).call
      end
    end
  end
end
