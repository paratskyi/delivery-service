class DeliveryService
  include TransportHelper
  include ::CONST

  attr_reader :transport_park, :errors

  def initialize
    @transport_park = generate_transport_park
    @errors = []
  end

  def get_transport(weight:, distance:)
    check_transport weight

    if weight <= BIKE_MAX_WEIGHT && distance <= BIKE_MAX_DISTANCE && available_bikes.any?
      available_bikes.first
    elsif weight <= CAR_MAX_WEIGHT && available_cars.any?
      available_cars.first
    else
      @errors.push 'No available transport'
      nil
    end
  end

  def send_transport(transport)
    raise ArgumentError, 'Transport should be present' unless transport

    transport.available = false
  end

  private

  def available_bikes
    transport_park.select { |transport| transport.bike? && transport.available }
  end

  def available_cars
    transport_park.select { |transport| transport.car? && transport.available }
  end

  def generate_transport_park
    cars = (1..car_count).map { Car.new(registration_number: FFaker::Vehicle.vin) }
    bikes = (1..BIKE_COUNT).map { Bike.new }
    cars + bikes
  end

  def car_count
    rand(10)
  end

  def check_transport(weight)
    if available_bikes.empty? && available_cars.empty? || weight > CAR_MAX_WEIGHT
      raise StandardError, 'No available transport'
    end
  rescue StandardError => e
    @errors.push e.message
  end
end
