class RentalCommissionSplitter
	attr_reader :price, :days_count

	DAILY_ASSISTANCE_DAILY_FEE = 100

	OWNER_COMMISSION_RATIO = 0.7
	COMMISSION_RATIO = 0.3

	def initialize(price:, days_count:)
		@price = price
		@days_count = days_count
	end

	def call
		{
			insurance_fee: insurance_fee,
			assistance_fee: assistance_fee,
			drivy_fee: drivy_fee
		}
	end

	def insurance_fee
		@insurance_fee ||= (commission / 2).to_i
	end

	def assistance_fee
		@assistance_fee ||= (DAILY_ASSISTANCE_DAILY_FEE * days_count).to_i
	end

	def drivy_fee
		@drivy_fee ||= (commission - insurance_fee - assistance_fee).to_i
	end

	private

	def commission
		@commission ||= price.to_f * COMMISSION_RATIO
	end
end
