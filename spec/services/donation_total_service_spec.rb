# spec/services/donation_total_service_spec.rb

require 'rails_helper'

RSpec.describe DonationTotalService do
  let(:user) { create(:user) }

  describe "#call" do
    context "when the user has no donations" do
      it "returns 0 cents" do
        total_cents = described_class.new(user: user, currency: "USD").call
        expect(total_cents).to eq(0)
      end
    end

    context "when donations are in the same currency as requested" do
      let!(:donation1) { create(:donation, user: user, amount: 1000, currency: "USD") }
      let!(:donation2) { create(:donation, user: user, amount: 2000, currency: "USD") }

      it "sums the amounts in cents without conversion" do
        total_cents = described_class.new(user: user, currency: "USD").call
        expect(total_cents).to eq(3000)  # 1000 + 2000
      end
    end

    context "when donations need conversion" do
      let!(:donation1) { create(:donation, user: user, amount: 1000, currency: "USD") }
      let!(:donation2) { create(:donation, user: user, amount: 2000, currency: "USD") }

      it "converts each donation to the requested currency" do
        # Stub the exchange rate for USD -> EUR
        allow_any_instance_of(ExchangeRateService).to receive(:fetch_rate)
          .with("USD", "EUR").and_return(0.9)

        total_cents = described_class.new(user: user, currency: "EUR").call
        # donation1 => 1000 * 0.9 => 900 cents
        # donation2 => 2000 * 0.9 => 1800 cents
        # total => 2700 cents
        expect(total_cents).to eq(2700)
      end
    end

    context "when fetch_rate returns nil (failed conversion)" do
      let!(:donation) { create(:donation, user: user, amount: 1000, currency: "USD") }

      it "raises an ExchangeRateFetchError" do
        allow_any_instance_of(ExchangeRateService).to receive(:fetch_rate)
          .with("USD", "EUR").and_return(nil)

        expect {
          described_class.new(user: user, currency: "EUR").call
        }.to raise_error(DonationTotalService::ExchangeRateFetchError, /Unable to fetch exchange rate/)
      end
    end
  end
end
