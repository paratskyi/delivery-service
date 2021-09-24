class Transport
  include Comparable
  include TransportHelper
  include ::CONST

  attr_accessor :max_weight, :speed, :available
  attr_reader :number_of_deliveries, :delivery_cost, :location

  @instances = []

  def initialize(max_weight:, speed:, delivery_cost:, number_of_deliveries: 0)
    @max_weight = max_weight
    @speed = speed
    @available = true
    @location = LOCATION.find_by_value('In garage')
    @delivery_cost = delivery_cost
    @number_of_deliveries = number_of_deliveries
    Transport.add_instance self
    generate_custom_methods
  end

  class << self
    def add_instance(instance)
      @instances.push instance
      instance.class.instance_variable_get(:@instances).push instance
    end

    def all
      @instances
    end
  end

  def location=(value)
    raise ArgumentError, "'#{value}' is invalid for location attribute" unless LOCATION.include?(value)

    @location = LOCATION.find_by_value(value)
  end

  def delivery_time(distance)
    distance.to_f / speed
  end

  def send_transport
    @number_of_deliveries += 1
    self.location = 'On route'
    self.available = false
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

  private

  def generate_custom_methods
    instance_variables.each do |attribute|
      attribute_name = attribute.to_s.sub('@', '')
      generate_find_by_attribute_methods(attribute_name)
      generate_filter_by_attribute_methods(attribute_name)
    end
  end

  def generate_find_by_attribute_methods(attribute_name)
    Transport.define_singleton_method "find_by_#{attribute_name}".to_sym do |value|
      all.find { |transport| transport.public_send(attribute_name) == value }
    end
  end

  def generate_filter_by_attribute_methods(attribute_name)
    Transport.define_singleton_method "filter_by_#{attribute_name}".to_sym do |&block|
      all.select { |transport| block.call(transport.public_send(attribute_name.to_sym)) }
    end
  end
end
