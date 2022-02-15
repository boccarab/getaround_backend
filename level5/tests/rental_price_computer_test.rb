require_relative './minitest_helper'

class RentalPriceComputerTest < Minitest::Test
  def test_price_discount_by_day
		assert_equal RentalPriceComputer.price_discount_by_day(1), 1
    (2..4).each do |i|
  		assert_equal RentalPriceComputer.price_discount_by_day(i), 0.9
    end
    (5..10).each do |i|
  		assert_equal RentalPriceComputer.price_discount_by_day(i), 0.7
    end
    (11..12).each do |i|
  		assert_equal RentalPriceComputer.price_discount_by_day(i), 0.5
    end
  end

  def test_total_price_per_day
    car = Car.new(id: 1, price_per_day: 1000, price_per_km: 2000)
    rental = Rental.new(id: 1, car_id: car.id, start_date: "2017-12-8", end_date: "2017-12-10", distance: 25)
    rental.car = car

    operation = RentalPriceComputer.new(rental: rental)

    assert_equal operation.send(:total_price_per_day), 3000
  end

  def test_total_price_per_day_with_discount
    car = Car.new(id: 1, price_per_day: 1000, price_per_km: 2000)
    rental = Rental.new(id: 1, car_id: car.id, start_date: "2017-12-8", end_date: "2017-12-10", distance: 25)
    rental.car = car

    operation = RentalPriceComputer.new(rental: rental)

    assert_equal operation.send(:total_price_per_day_with_discount), 2800
  end

  def test_total_price_per_km
    car = Car.new(id: 1, price_per_day: 1000, price_per_km: 200)
    rental = Rental.new(id: 1, car_id: car.id, start_date: "2017-12-8", end_date: "2017-12-10", distance: 25)
    rental.car = car

    operation = RentalPriceComputer.new(rental: rental)

    assert_equal operation.send(:total_price_per_km), 5000
  end

  def test_total
    car = Car.new(id: 1, price_per_day: 1000, price_per_km: 200)
    rental = Rental.new(id: 1, car_id: car.id, start_date: "2017-12-8", end_date: "2017-12-10", distance: 25)
    rental.car = car

    operation = RentalPriceComputer.new(rental: rental)

    assert_equal operation.call, 7800
  end
end
