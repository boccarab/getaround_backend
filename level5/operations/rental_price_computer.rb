class RentalPriceComputer
	attr_reader :rental

  class << self
    def price_discount_by_day(day_i)
      case day_i
      when 1 then 1
      when 2..4 then 0.9
      when 5..10 then 0.7
      when 11.. then 0.5
      end
    end
  end

  def initialize(rental:)
		@rental = rental

		raise StandardError.new("car id mismatch error: car id #{rental.car.id} doesn't match the rental's car_id #{rental.car_id}.") unless rental.car.id == rental.car_id
	end

	def call
		(total_price_per_day_with_discount + total_price_per_km).to_i
	end

	private

	def total_price_per_km
		rental.car.price_per_km * rental.distance
	end

	def total_price_per_day
		(1..rental.days_count).sum do |day_i|
			rental.car.price_per_day
		end
	end

  def total_price_per_day_with_discount
		(1..rental.days_count).sum do |day_i|
			rental.car.price_per_day * RentalPriceComputer::price_discount_by_day(day_i)
		end
	end
end
