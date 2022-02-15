class Option
	AVAILABLE_OPTIONS = %w[additional_insurance baby_seat gps].freeze

  attr_reader :id, :rental_id, :type

	def initialize(id:, rental_id:, type:)
		@id = id
		@rental_id = rental_id
		@type = type
	end
end
