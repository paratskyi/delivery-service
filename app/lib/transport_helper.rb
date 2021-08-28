module TransportHelper
  include Support

  def max_distance_for(object)
    object.try(:max_distance) || Float::INFINITY
  end
end
