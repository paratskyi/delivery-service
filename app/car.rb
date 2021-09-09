class Car < Transport
  attr_reader :registration_number

  @instances = []

  def initialize(registration_number:)
    super(
      max_weight: CAR_MAX_WEIGHT,
      speed: CAR_SPEED,
      delivery_cost: CAR_DELIVERY_COST
    )
    @registration_number = registration_number
  end
end
