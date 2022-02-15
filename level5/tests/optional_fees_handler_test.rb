require_relative './minitest_helper'

class OptionalFeesHandlerTest < Minitest::Test
	def setup
		@days_count = 3
	end

	def test_only_gps
    operation = ::OptionalFeesHandler.new(options: %w[gps], days_count: @days_count)

		assert_equal operation.total, OptionalFeesHandler::GPS_DAILY_FEE * @days_count
    assert_equal operation.additional_insurance_fee, 0
    assert_equal operation.baby_seat_fee, 0
    assert_equal operation.gps_fee, OptionalFeesHandler::GPS_DAILY_FEE * @days_count
  end

	def test_only_additional_insurance
    operation = ::OptionalFeesHandler.new(options: %w[additional_insurance], days_count: @days_count)

		assert_equal operation.total, OptionalFeesHandler::ADDITIONNAL_INSURANCE_DAILY_FEE * @days_count
    assert_equal operation.additional_insurance_fee, OptionalFeesHandler::ADDITIONNAL_INSURANCE_DAILY_FEE * @days_count
    assert_equal operation.baby_seat_fee, 0
    assert_equal operation.gps_fee, 0
  end

	def test_only_baby_seat
    operation = ::OptionalFeesHandler.new(options: %w[baby_seat], days_count: @days_count)

		assert_equal operation.total, OptionalFeesHandler::BABY_SEAT_DAILY_FEE * @days_count
    assert_equal operation.additional_insurance_fee, 0
    assert_equal operation.baby_seat_fee, OptionalFeesHandler::BABY_SEAT_DAILY_FEE * @days_count
    assert_equal operation.gps_fee, 0
  end

	def test_all_options
    operation = ::OptionalFeesHandler.new(options: %w[additional_insurance baby_seat gps], days_count: @days_count)

		assert_equal operation.total, (OptionalFeesHandler::ADDITIONNAL_INSURANCE_DAILY_FEE * @days_count + OptionalFeesHandler::BABY_SEAT_DAILY_FEE * @days_count + OptionalFeesHandler::GPS_DAILY_FEE * @days_count)
    assert_equal operation.additional_insurance_fee, OptionalFeesHandler::ADDITIONNAL_INSURANCE_DAILY_FEE * @days_count
    assert_equal operation.baby_seat_fee, OptionalFeesHandler::BABY_SEAT_DAILY_FEE * @days_count
    assert_equal operation.gps_fee, OptionalFeesHandler::GPS_DAILY_FEE * @days_count
  end
end
