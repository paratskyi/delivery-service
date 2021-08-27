class Transport
  include Comparable
  include ::CONST

  attr_accessor :max_weight, :speed, :available

  def initialize(max_weight:, speed:)
    @max_weight = max_weight
    @speed = speed
    @available = true
  end

  def delivery_time(distance)
    distance / speed
  end

  def bike?
    instance_of?(Bike)
  end

  def car?
    instance_of?(Car)
  end

  def <=>(other)
    return 0 if delivery_speed_ratio == other.delivery_speed_ratio
    return 1 if delivery_speed_ratio < other.delivery_speed_ratio
    return -1 if delivery_speed_ratio > other.delivery_speed_ratio
  end

  def delivery_speed_ratio
    @speed / @max_weight
  end
end
