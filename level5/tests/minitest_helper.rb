require 'minitest/autorun'

%w(
  models/car
	models/option
	models/rental
	operations/optional_fees_handler
	operations/rental_actions
	operations/rental_commission_splitter
	operations/rental_price_computer
).each do |file|
  begin
    require_relative "./../#{file}.rb"
  rescue LoadError => e
		puts e
  end
end
