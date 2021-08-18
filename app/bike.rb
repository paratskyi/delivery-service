class Bike < Transport
  attr_reader :max_distance

  def initialize
    super(
      max_weight: CONST::BIKE_SPEED,
      speed: CONST::BIKE_MAX_WEIGHT
    )
    @max_distance = CONST::BIKE_MAX_DISTANCE
  end
end
