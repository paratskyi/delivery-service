class Bike < Transport
  attr_reader :max_distance

  def initialize
    super(
      max_weight: BIKE_MAX_WEIGHT,
      speed: BIKE_SPEED
    )
    @max_distance = BIKE_MAX_DISTANCE
  end
end
