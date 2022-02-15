class OptionalFeesHandler
	ADDITIONNAL_INSURANCE_DAILY_FEE = 1000
	BABY_SEAT_DAILY_FEE = 200
	GPS_DAILY_FEE = 500

	attr_reader :options, :days_count

	def initialize(options:, days_count:)
		@options = options
		@days_count = days_count
	end

	def total
		@total ||= begin
      additional_insurance_fee + baby_seat_fee + gps_fee
	  end
  end

	def additional_insurance_fee
		@additional_insurance_fee ||= begin
			return 0 unless additional_insurance_option?

			(ADDITIONNAL_INSURANCE_DAILY_FEE * days_count).to_i
		end
	end

	def baby_seat_fee
		@baby_seat_fee ||= begin
			return 0 unless baby_seat_option?

			(BABY_SEAT_DAILY_FEE * days_count).to_i
		end
	end

	def gps_fee
		@gps_fee ||= begin
			return 0 unless gps_option?

			(GPS_DAILY_FEE * days_count).to_i
		end
	end

	private

	Option::AVAILABLE_OPTIONS.each do |label|
		define_method("#{label}_option?") do
			options.include?(label)
		end
	end
end
