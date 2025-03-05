require 'rails_helper'

RSpec.describe "Donations API", type: :request do
  let(:user) { create(:user) }
  let(:project) { create(:project) }

  describe "POST /api/donations" do
    let(:valid_params) do
      {
        donation: {
          amount: 5000,
          currency: "EUR",
          project_id: project.id
        }
      }
    end

    context "with a valid token" do
      it "creates a donation" do
        post "/api/donations", params: valid_params, headers: { "Authorization" => user.api_token }
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["amount"]).to eq(5000)
        expect(json["currency"]).to eq("EUR")
        expect(json["project_id"]).to eq(project.id)
        expect(json["user_id"]).to eq(user.id)
      end
    end

    context "with invalid parameters" do
      it "returns unprocessable entity" do
        invalid_params = { donation: { amount: nil, currency: "EUR", project_id: project.id } }
        post "/api/donations", params: invalid_params, headers: { "Authorization" => user.api_token }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context "with an invalid token" do
      it "returns unauthorized" do
        post "/api/donations", params: valid_params, headers: { "Authorization" => "invalid" }
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  describe "GET /api/donations/total" do
    let!(:donation1) { create(:donation, user: user, project: project, amount: 1000, currency: "USD") }
    let!(:donation2) { create(:donation, user: user, project: project, amount: 2000, currency: "USD") }

    it "returns total donations in requested currency in cents" do
      allow_any_instance_of(ExchangeRateService).to receive(:fetch_rate)
        .with("USD", "EUR").and_return(0.9)

      get "/api/donations/total",
        params: { currency: "EUR" },
        headers: { "Authorization" => user.api_token }

      expect(response).to have_http_status(:ok)
      json = JSON.parse(response.body)
      expect(json["total"]).to eq(2700)
      expect(json["currency"]).to eq("EUR")
    end
  end
end
