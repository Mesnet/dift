# app/services/donation_batch_service.rb

class DonationBatchService
  class TooManyDonationsError < StandardError; end

  class InvalidProjectIdsError < StandardError
    attr_reader :invalid_ids

    def initialize(invalid_ids)
      @invalid_ids = invalid_ids
      super("Invalid project_ids: #{invalid_ids.join(', ')}")
    end
  end

  class ValidationError < StandardError
    attr_reader :errors

    def initialize(errors)
      @errors = errors
      super("Validation failed for one or more donations")
    end
  end

  MAX_BATCH_SIZE = 1000

  def initialize(user:, donations_params:)
    @user = user
    @donations_params = donations_params
  end

  def call
    raise TooManyDonationsError, "Maximum batch size is #{MAX_BATCH_SIZE}" if @donations_params.size > MAX_BATCH_SIZE

    validate_project_ids!

    records = build_validated_records

    Donation.insert_all(records) if records.any?
  end

  private

  def validate_project_ids!
    input_ids = @donations_params.map { _1[:project_id] }.uniq.map(&:to_i)
    existing_ids = Project.where(id: input_ids).pluck(:id).to_set

    invalid_ids = input_ids - existing_ids.to_a

    raise InvalidProjectIdsError.new(invalid_ids) if invalid_ids.any?
  end

  def build_validated_records
    now = Time.current
    prototype = Donation.new(user: @user)
    invalid_rows = []
    records = []

    @donations_params.each_with_index do |donation_data, idx|
      donation = prototype.dup
      donation.assign_attributes(
        project_id: donation_data[:project_id],
        amount: donation_data[:amount],
        currency: donation_data[:currency]
      )

      if donation.valid?
        records << {
          user_id: @user.id,
          project_id: donation.project_id,
          amount: donation.amount,
          currency: donation.currency,
          created_at: now,
          updated_at: now
        }
      else
        invalid_rows << { index: idx, errors: donation.errors.full_messages }
      end
    end

    raise ValidationError.new(invalid_rows) if invalid_rows.any?

    records
  end
end
