require 'date'

class Rental
	attr_reader :id, :car_id, :start_date, :end_date, :distance
  attr_writer :options

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

  def options
    @options || []
  end

  def options_list
    options.map(&:type)
  end

  def car=(value)
    raise StandardError.new("car id mismatch error: car id #{value.id} doesn't match the rental's car_id #{car_id}.") unless value.id == car_id

    @car = value
  end

  def car
    @car
  end

  def price
    RentalPriceComputer.new(rental: self).call
  end

  def fees
		RentalCommissionSplitter.new(price: price, days_count: days_count)
	end

  %i[assistance_fee drivy_fee insurance_fee].each do |label|
		define_method("#{label}") do
			fees.send(label)
		end
	end

	def optional_fees
		OptionalFeesHandler.new(options: options_list, days_count: days_count)
	end

  Option::AVAILABLE_OPTIONS.each do |label|
		define_method("optional_#{label}_fee") do
			optional_fees.send(:"#{label}_fee")
		end
	end

  def optional_fees_total
    optional_fees.total
  end
end
