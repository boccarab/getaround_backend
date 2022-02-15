require 'json'
require 'date'

class RentalPriceComputer
	attr_reader :car, :rental

	def initialize(car:, rental:)
		@car = car
		@rental = rental

		raise StandardError.new("car id mismatch error: car id #{car.id} doesn't match the rental's car_id #{rental.car_id}.") unless car.id == rental.car_id
	end

	def call
		(total_price_per_day + total_price_per_km).to_i
	end

	private

	def total_price_per_km
		car.price_per_km * rental.distance
	end

	def total_price_per_day
		(1..rental.days_count).sum do |i|
			case i
			when 1 then car.price_per_day
			when 2..4 then car.price_per_day * 0.9
			when 5..10 then car.price_per_day * 0.7
			when 11.. then car.price_per_day * 0.5
			end
		end
	end
end

class RentalCommissionSplitter
	attr_reader :price, :days_count

	DAILY_ASSISTANCE_FEE = 100
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
		@assistance_fee ||= (DAILY_ASSISTANCE_FEE * days_count).to_i
	end

	def drivy_fee
		@drivy_fee ||= (commission - insurance_fee - assistance_fee).to_i
	end

	private

	def commission
		@commission ||= price.to_f * COMMISSION_RATIO
	end
end

class RentalActions
	attr_reader :car, :rental

	DEBIT_OWNERS = %w[driver]
	CREDIT_OWNERS = %w[owner insurance assistance drivy]

	def initialize(car:, rental:)
		@car = car
		@rental = rental

		raise StandardError.new("car id mismatch error: car id #{car.id} doesn't match the rental's car_id #{rental.car_id}.") unless car.id == rental.car_id
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
		rental_price
	end

	def owner_amount
		owner_commission
	end

	def insurance_amount
		rental_fees.insurance_fee
	end

	def assistance_amount
		rental_fees.assistance_fee
	end

	def drivy_amount
		rental_fees.drivy_fee
	end
	
	def rental_price
		@rental_price ||= RentalPriceComputer.new(car: car, rental: rental).call
	end

	def rental_fees
		@rental_fees ||= RentalCommissionSplitter.new(price: rental_price, days_count: rental.days_count)
	end

	def owner_commission
		(rental_price * RentalCommissionSplitter::OWNER_COMMISSION_RATIO).to_i
	end
end

class Car
	attr_reader :id, :price_per_day, :price_per_km

	def initialize(id:, price_per_day:, price_per_km:)
		@id = id
		@price_per_day = price_per_day
		@price_per_km = price_per_km
	end
end

class Rental
	attr_reader :id, :car_id, :start_date, :end_date, :distance

	def initialize(id:, car_id:, start_date:, end_date:, distance:)
		@id = id
		@car_id = car_id
		@start_date = start_date
		@end_date = end_date
		@distance = distance
	end

	def days_count
		# start_date begins at the beginning of the day
		# end_date ends at the end of the day
		# adding +1 to take the last day into account
		(Date.parse(end_date) - Date.parse(start_date)).abs.to_f + 1
	end
end

class GetAround
	INPUT_FILE_PATH = 'data/input.json'
	OUTPUT_FILE_PATH = 'data/output.json'

	attr_reader :cars, :rentals

	def initialize
		init_data
	end

	def compute
		data = \
			rentals.map do |rental|
				car = cars.find { |c| c.id == rental.car_id }
				raise StandardError.new("car not found error: rental #{rental.id} referenced missing car with id #{rental.car_id}.") unless car

				actions = RentalActions.new(car: car, rental: rental).call

				{ id: rental.id, actions: actions }
			end

    File.write(OUTPUT_FILE_PATH, JSON.pretty_generate(rentals: data))
	end

	private

	def init_data
		file = File.open(INPUT_FILE_PATH, 'r')
		data = JSON.parse(file.read, object_class: OpenStruct)

		init_cars(data.cars)
		init_rentals(data.rentals)
	end

	def init_cars(data)
		@cars = []

		data.each do |data|
			@cars << Car.new(**data.to_h)
		end
	end

	def init_rentals(data)
		@rentals = []

		data.each do |data|
			@rentals << Rental.new(**data.to_h)
		end
	end
end

get_around = GetAround.new
get_around.compute
