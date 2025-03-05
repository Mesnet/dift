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
    total_cents = DonationTotalService.new(
      user: current_user,
      currency: requested_currency
    ).call

    render json: {
      total: total_cents,
      currency: requested_currency
    }, status: :ok
  end

  private

  def donation_params
    params.require(:donation).permit(:amount, :currency, :project_id)
  end
end
