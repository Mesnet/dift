# app/services/donation_total_service.rb

class DonationTotalService
  def initialize(user:, currency:)
    @user = user
    @currency = currency
    @exchange_service = ExchangeRateService.new
  end

  def call
    total_cents = 0
    @user.donations.find_each do |donation|
      total_cents += convert_donation_amount(donation)
    end
    total_cents
  end

  private

  def convert_donation_amount(donation)
    if donation.currency == @currency
      donation.amount
    else
      rate = @exchange_service.fetch_rate(donation.currency, @currency)
      return 0 unless rate

      (donation.amount * rate).round
    end
  end
end
