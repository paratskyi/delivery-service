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
    distance / speed
  end

  def bike?
    instance_of?(Bike)
  end

  def car?
    instance_of?(Car)
  end

  def <=>(other)
    return 0 if eql_transport?(other)
    return 1 if @max_weight > other.max_weight
    return -1 if @max_weight < other.max_weight
    return 1 if max_distance_for(self) > max_distance_for(other)
    return -1 if max_distance_for(self) < max_distance_for(other)
  end

  private

  def eql_transport?(other)
    @max_weight == other.max_weight && max_distance_for(self) == max_distance_for(other)
  end
end
