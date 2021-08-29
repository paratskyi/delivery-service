RSpec.describe TransportHelper do
  let(:bike) { Bike.new }
  let(:car) { Car.new(registration_number: FFaker::Vehicle.vin) }

  context '#max_distance_for' do
    it 'returns correct max_distance for Bike' do
      expect(max_distance_for(bike)).to eq BIKE_MAX_DISTANCE
    end

    it 'returns correct max_distance for Car' do
      expect(max_distance_for(car)).to eq Float::INFINITY
    end
  end
end
