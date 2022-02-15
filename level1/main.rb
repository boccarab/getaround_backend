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
		(car.price_per_day * rental.days_count + car.price_per_km * rental.distance).to_i
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

	def compute_rental_prices
		data = \
			rentals.map do |rental|
				car = cars.find { |c| c.id == rental.car_id }
				raise StandardError.new("car not found error: rental #{rental.id} referenced missing car with id #{rental.car_id}.") unless car

				price = RentalPriceComputer.new(car: car, rental: rental).call

				{ id: rental.id, price: price }
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
get_around.compute_rental_prices
