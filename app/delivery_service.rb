class DeliveryService
  include TransportHelper
  include ::CONST

  attr_reader :transport_park, :errors

  def initialize
    @transport_park = generate_transport_park
    @errors = []
  end

  def get_transport(weight:, distance:)
    check_delivery_possibility(weight)

    transport = sorted_available_transport_park.find { |t| t.max_weight >= weight && max_distance_for(t) >= distance }

    raise_transport_error! unless transport

    transport
  end

  def send_transport(transport)
    raise ArgumentError, 'Transport should be present' unless transport

    transport.available = false
  end

  private

  def sorted_available_transport_park
    available_transports.sort_by { |transport| [transport.max_weight, max_distance_for(transport)] }
  end

  def available_transports
    transport_park.select(&:available)
  end

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

  def check_delivery_possibility(weight)
    raise_transport_error! if available_transports.empty? || weight > MAX_AVAILABLE_WEIGHT
  end

  def raise_transport_error!
    raise StandardError, 'No available transport'
  rescue StandardError => e
    @errors.push e.message
  end
end
