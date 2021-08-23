class Bike < Transport
  attr_reader :max_distance

  def initialize
    super(
      max_weight: BIKE_SPEED,
      speed: BIKE_MAX_WEIGHT
    )
    @max_distance = BIKE_MAX_DISTANCE
  end
end
