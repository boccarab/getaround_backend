class RentalsToActionsSerializer
  attr_reader :collection

  def initialize(collection)
    @collection = collection
  end

  def render
    {
      rentals: hash
    }
  end

  private

  def hash
    collection.map { |item| rental_to_action(item) }
  end

  def rental_to_action(rental)
    actions = RentalActions.new(rental: rental).call

    {
      id: rental.id,
      options: rental.options_list,
      actions: actions
    }
  end
end
