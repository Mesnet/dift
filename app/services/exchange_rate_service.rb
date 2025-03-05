# app/services/exchange_rate_service.rb

class ExchangeRateService
  BASE_URL = "https://v6.exchangerate-api.com/v6"

  def initialize
    @connection = Faraday.new(url: BASE_URL)
  end

  # Fetch the conversion rate from one currency to another
  # Example: fetch_rate("USD", "EUR") => 0.93
  def fetch_rate(from_currency, to_currency)
    return 1.0 if from_currency == to_currency

    rates = fetch_rates_for_base(from_currency)
    rates[to_currency]
  end

  private

  def fetch_rates_for_base(base_currency)
    Rails.cache.fetch("exchange_rates_#{base_currency}", expires_in: 1.hour) do
      get_rates_from_api(base_currency)
    end
  end

  def get_rates_from_api(base_currency)
    response = @connection.get("#{ENV["EXCHANGE_RATE_API_KEY"]}/latest/#{base_currency}")
    return {} unless response.status == 200

    data = JSON.parse(response.body) rescue {}
    data["conversion_rates"] || {}
  rescue StandardError => e
    Rails.logger.error("ExchangeRateService error: #{e.message}")
    {}
  end
end
