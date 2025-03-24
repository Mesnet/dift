class Api::DonationsController < Api::BaseController
  def create
    donation = Donation.new(donation_params.merge(user: current_user))
    if donation.save
      render json: donation, status: :created
    else
      render json: { errors: donation.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def total
    requested_currency = params[:currency] || "EUR"
    service = DonationTotalService.new(user: @current_user, currency: requested_currency)
    total = service.call
    render json: { total: total, currency: params[:currency] }
  rescue DonationTotalService::ExchangeRateFetchError => e
    render json: { error: e.message }, status: :unprocessable_entity
  end

  private

  def donation_params
    params.require(:donation).permit(:amount, :currency, :project_id)
  end
end
