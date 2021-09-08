class Transport
  include Comparable
  include TransportHelper
  include ::CONST

  attr_accessor :max_weight, :speed, :available

  def initialize(max_weight:, speed:)
    @max_weight = max_weight
    @speed = speed
    @available = true
  end

  def delivery_time(distance)
    distance.to_f / speed
  end

  def bike?
    instance_of?(Bike)
  end

  def car?
    instance_of?(Car)
  end

  def <=>(other)
    return 1 if max_weight > other.max_weight
    return -1 if max_weight < other.max_weight
    return 1 if max_distance_for(self) > max_distance_for(other)
    return -1 if max_distance_for(self) < max_distance_for(other)

    0
  end
end
