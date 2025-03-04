require 'rails_helper'

RSpec.describe "Donations API", type: :request do
  describe "POST /api/donations" do
    let(:user) { create(:user) }
    let(:project) { create(:project) }
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
end
