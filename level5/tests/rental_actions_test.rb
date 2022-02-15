require_relative './minitest_helper'

class RentalActionsTest < Minitest::Test
  def setup
    @rental = Rental.new(id: 1, car_id: 1, start_date: "2015-12-8", end_date: "2015-12-8", distance: 100)

    @rental.options = [
      Option.new(id: 1, rental_id: 1, type: "gps"),
      Option.new(id: 2, rental_id: 1, type: "baby_seat")
    ]

    @rental.car = Car.new("id": 1, "price_per_day": 2000, "price_per_km": 10)

    @operation = ::RentalActions.new(rental: @rental)

  end

	def test_driver_amount
    assert_equal @operation.send(:driver_amount), @rental.price + @rental.optional_fees_total
  end

	def test_owner_amount
    assert_equal @operation.send(:owner_amount), @operation.send(:owner_commission) + @rental.optional_gps_fee + @rental.optional_baby_seat_fee
  end

	def test_insurance_amount
    assert_equal @operation.send(:insurance_amount), @rental.insurance_fee
  end

	def test_assistance_amount
    assert_equal @operation.send(:assistance_amount), @rental.assistance_fee
  end

	def test_drivy_amount
		assert_equal @operation.send(:drivy_amount), @rental.drivy_fee + @rental.optional_additional_insurance_fee
  end
end
