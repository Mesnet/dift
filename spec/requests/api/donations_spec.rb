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
  end

  describe "POST /api/donations/batch" do
    let(:project2) { create(:project) }

    context "with valid batch payload" do
      let(:payload) do
        {
          donations: [
            { amount: 1000, currency: "USD", project_id: project.id },
            { amount: 2000, currency: "EUR", project_id: project2.id }
          ]
        }
      end

      it "creates all donations" do
        expect {
          post "/api/donations/batch", params: payload, headers: { "Authorization" => user.api_token }
        }.to change(Donation, :count).by(2)

        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Donations recorded successfully")
      end
    end

    context "when donation is invalid" do
      let(:payload) do
        {
          donations: [
            { amount: -500, currency: "USD", project_id: project.id }, # invalid amount
            { amount: 1500, currency: "EUR", project_id: project2.id }
          ]
        }
      end

      it "returns validation errors and does not insert anything" do
        expect {
          post "/api/donations/batch", params: payload, headers: { "Authorization" => user.api_token }
        }.not_to change(Donation, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["details"].first["errors"]).to include("Amount must be greater than 0")
      end
    end

    context "when a project_id does not exist" do
      let(:payload) do
        {
          donations: [
            { amount: 1000, currency: "USD", project_id: 9999 } # invalid project_id
          ]
        }
      end

      it "returns error for invalid project IDs" do
        post "/api/donations/batch", params: payload, headers: { "Authorization" => user.api_token }

        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json["invalid_ids"]).to include(9999)
      end
    end

    context "when batch exceeds limit" do
      let(:payload) do
        {
          donations: Array.new(1001) { { amount: 100, currency: "USD", project_id: project.id } }
        }
      end

      it "returns a bad request status" do
        post "/api/donations/batch", params: payload, headers: { "Authorization" => user.api_token }

        expect(response).to have_http_status(:bad_request)
        json = JSON.parse(response.body)
        expect(json["error"]).to match(/Maximum batch size/i)
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
