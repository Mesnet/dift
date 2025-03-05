# spec/services/exchange_rate_service_spec.rb

require 'rails_helper'

RSpec.describe ExchangeRateService do
  let(:service) { described_class.new }

  before do
    Rails.cache.clear
  end

  describe "#fetch_rate" do
    context "when from_currency equals to_currency" do
      it "returns 1.0" do
        expect(service.fetch_rate("USD", "USD")).to eq(1.0)
      end
    end

    context "when the API call is successful" do
      before do
        # Stub Faraday to return a 200 response with a sample JSON
        stub_request(:get, %r{https://v6.exchangerate-api.com/v6/.*/latest/USD})
          .to_return(
            status: 200,
            body: {
              "conversion_rates" => {
                "EUR" => 0.93,
                "USD" => 1.0
              }
            }.to_json
          )
      end

      it "returns the correct rate" do
        rate = service.fetch_rate("USD", "EUR")
        expect(rate).to eq(0.93)
      end

      it "caches the result" do
        # First call triggers the external request
        service.fetch_rate("USD", "EUR")
        # Second call should use cache (so we can check request count, etc.)
        service.fetch_rate("USD", "EUR")

        # If you're using WebMock, you can check that only 1 external request was made:
        expect(WebMock).to have_requested(:get, %r{/latest/USD}).once
      end
    end

    context "when the API call fails" do
      before do
        stub_request(:get, %r{https://v6.exchangerate-api.com/v6/.*/latest/USD})
          .to_return(status: 500, body: "")
      end

      it "returns nil (or doesn't find the currency key)" do
        rate = service.fetch_rate("USD", "EUR")
        expect(rate).to be_nil
      end
    end
  end
end
