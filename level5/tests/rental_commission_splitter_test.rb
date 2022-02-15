require_relative './minitest_helper'

class RentalCommissionSplitterTest < Minitest::Test
	def setup
		@days_count = 3
    @operation = ::RentalCommissionSplitter.new(price: 2000, days_count: @days_count)
	end

  def test_commission
		assert_equal @operation.send(:commission), 2000 * RentalCommissionSplitter::COMMISSION_RATIO
  end

  def test_insurance_fee
    commission = @operation.send(:commission)
		assert_equal @operation.insurance_fee, commission / 2
  end

  def test_assistance_fee
		assert_equal @operation.assistance_fee, RentalCommissionSplitter::DAILY_ASSISTANCE_DAILY_FEE * @days_count
  end

  def test_drivy_fee
    commission = @operation.send(:commission)
    assistance_fee = @operation.assistance_fee
    insurance_fee = @operation.insurance_fee

		assert_equal @operation.drivy_fee, commission - insurance_fee - assistance_fee
  end

  def test_call
    assistance_fee = @operation.assistance_fee
    insurance_fee = @operation.insurance_fee
    drivy_fee = @operation.drivy_fee
    
    expected_hash = {
			insurance_fee: insurance_fee,
			assistance_fee: assistance_fee,
			drivy_fee: drivy_fee
		}
    assert_equal @operation.call, expected_hash
  end
end
