class RentalActions
	attr_reader :rental

	DEBIT_OWNERS = %w[driver]
	CREDIT_OWNERS = %w[owner insurance assistance drivy]

	def initialize(rental:)
		@rental = rental
	end

	def call
		[].tap do |actions|
			actions.concat(DEBIT_OWNERS.map { |owner| owner_action(owner, 'debit') })
			actions.concat(CREDIT_OWNERS.map { |owner| owner_action(owner, 'credit') })
		end
	end

	private

	def owner_action(owner, type)
		{
			who: owner,
			type: type,
			amount: send("#{owner}_amount")
		}
	end

	def driver_amount
		rental.price + rental.optional_fees_total
	end

	def owner_amount
		owner_commission + rental.optional_gps_fee + rental.optional_baby_seat_fee
	end

	def insurance_amount
		rental.insurance_fee
	end

	def assistance_amount
		rental.assistance_fee
	end

	def drivy_amount
		rental.drivy_fee + rental.optional_additional_insurance_fee
	end

	def owner_commission
		@owner_commission ||= (rental.price * RentalCommissionSplitter::OWNER_COMMISSION_RATIO).to_i
	end
end
