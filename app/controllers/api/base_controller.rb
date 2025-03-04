module Api
  class BaseController < ApplicationController
    skip_before_action :verify_authenticity_token

    before_action :authenticate_user!

    private

    def authenticate_user!
      token = request.headers["Authorization"]
      @current_user = User.find_by(api_token: token)
      render json: { error: "Unauthorized" }, status: :unauthorized unless @current_user
    end

    def current_user
      @current_user
    end
  end
end
