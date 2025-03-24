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

  def batch
    service = DonationBatchService.new(
      user: @current_user,
      donations_params: params[:donations]
    )
    service.call
    render json: { message: "Donations recorded successfully" }, status: :created

  rescue DonationBatchService::TooManyDonationsError => e
    render json: { error: e.message }, status: :bad_request

  rescue DonationBatchService::InvalidProjectIdsError => e
    render json: { error: "Some project_ids are invalid", invalid_ids: e.invalid_ids }, status: :unprocessable_entity

  rescue DonationBatchService::ValidationError => e
    render json: { error: "Validation failed", details: e.errors }, status: :unprocessable_entity
  end


  private

  def donation_params
    params.require(:donation).permit(:amount, :currency, :project_id)
  end
end
