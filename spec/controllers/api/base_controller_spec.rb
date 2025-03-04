require 'rails_helper'

RSpec.describe Api::BaseController, type: :controller do
  # Create an anonymous controller inheriting from Api::BaseController
  controller do
    def index
      render json: { message: "Authenticated" }
    end
  end

  describe "GET #index" do
    context "with a valid token" do
      let(:user) { create(:user) }
      before do
        request.headers['Authorization'] = user.api_token
        get :index
      end

      it "returns a success response" do
        expect(response).to have_http_status(:ok)
        json = JSON.parse(response.body)
        expect(json["message"]).to eq("Authenticated")
      end
    end

    context "with an invalid token" do
      before do
        request.headers['Authorization'] = "invalid_token"
        get :index
      end

      it "returns an unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Unauthorized")
      end
    end

    context "without a token" do
      before { get :index }

      it "returns an unauthorized response" do
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Unauthorized")
      end
    end
  end
end
