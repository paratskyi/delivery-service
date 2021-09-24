class Bike < Transport
  attr_reader :max_distance

  @instances = []

  def initialize
    @max_distance = BIKE_MAX_DISTANCE
    super(
      max_weight: BIKE_MAX_WEIGHT,
      speed: BIKE_SPEED,
      delivery_cost: BIKE_DELIVERY_COST
    )
  end
end
