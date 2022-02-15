require 'json'

%w(
  models/car
  models/option
  models/rental
	operations/optional_fees_handler
	operations/rental_actions
	operations/rental_commission_splitter
	operations/rental_price_computer
  serializers/rentals_to_actions_serializer
).each do |file|
  begin
    require_relative "./#{file}.rb"
  rescue LoadError
  end
end

class GetAround
	INPUT_FILE_PATH = 'data/input.json'
	OUTPUT_FILE_PATH = 'data/output.json'

	attr_reader :cars, :rentals, :options

	def initialize
		init_data
	end

	def compute
    puts ENV['DEBUG']
		hash = RentalsToActionsSerializer.new(rentals).render

    if debug?
			pp hash
		else
			File.write(OUTPUT_FILE_PATH, JSON.pretty_generate(hash))
		end
	end

	private

	def init_data
		file = File.open(INPUT_FILE_PATH, 'r')
		data = JSON.parse(file.read, object_class: OpenStruct)

		init_cars(data.cars)
		init_options(data.options)
    init_rentals(data.rentals)
	end

	def init_cars(data)
		@cars = data.map { |data| Car.new(**data.to_h) }
	end

	def init_options(data)
		@options = data.map { |data| Option.new(**data.to_h) }
	end

	def init_rentals(data)
		@rentals = data.map do |data|
      Rental.new(**data.to_h).tap do |rental|
        rental_options = options.find_all { |o| o.rental_id == rental.id }
        rental.options = rental_options

        rented_car = cars.find { |c| c.id == rental.car_id }
        raise StandardError.new("car not found error: rental #{rental.id} referenced missing car with id #{rental.car_id}.") unless rented_car

        rental.car = rented_car
      end
    end
	end

  def debug?
    !!ENV['DEBUG']
  end
end

get_around = GetAround.new
get_around.compute
