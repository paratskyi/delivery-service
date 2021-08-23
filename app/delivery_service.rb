class DeliveryService
  include ::CONST

  attr_reader :transport_park

  def initialize
    @transport_park = generate_transport_park
  end

  def get_transport(weight:, distance:)
    return if available_bikes.empty? && available_cars.empty? || weight > CAR_MAX_WEIGHT

    if weight <= BIKE_MAX_WEIGHT && distance <= BIKE_MAX_DISTANCE && available_bikes.any?
      available_bikes.first
    else
      available_cars.first
    end
  end

  def send_transport(transport)
    transport.available = false
  end

  private

  def available_bikes
    @transport_park.select { |transport| transport.bike? && transport.available }
  end

  def available_cars
    @transport_park.select { |transport| transport.car? && transport.available }
  end

  def generate_transport_park
    cars = (1..car_count).map { Car.new(registration_number: FFaker::Vehicle.vin) }
    bikes = (1..BIKE_COUNT).map { Bike.new }
    cars + bikes
  end

  def car_count
    rand(10)
  end
end
