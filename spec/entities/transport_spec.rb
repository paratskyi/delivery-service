RSpec.describe Transport do
  context '#initialize' do
    context 'Bike' do
      subject { Bike.new }

      it 'must have correct attributes' do
        expect(subject).to be_a(Bike)
        expect(subject).to have_attributes(
          max_weight: BIKE_MAX_WEIGHT,
          speed: BIKE_SPEED,
          max_distance: BIKE_MAX_DISTANCE
        )
      end
    end

    context 'Car' do
      subject { Car.new(transport_params) }
      let(:transport_params) { { registration_number: FFaker::Vehicle.vin } }

      it 'must have correct attributes' do
        expect(subject).to be_a(Car)
        expect(subject).to have_attributes(
          max_weight: CAR_MAX_WEIGHT,
          speed: CAR_SPEED,
          registration_number: transport_params[:registration_number]
        )
      end
    end
  end

  context '#comparable' do
    let(:bike) { Bike.new }
    let(:other_bike) { Bike.new }
    let(:car) { Car.new(registration_number: FFaker::Vehicle.vin) }
    let(:other_car) { Car.new(registration_number: FFaker::Vehicle.vin) }

    context 'when compare Bike with other Bike' do
      it 'returns correct comparison result' do
        expect(bike == other_bike).to be true
        expect(bike >= other_bike).to be true
        expect(bike <= other_bike).to be true
        expect(bike > other_bike).to be false
        expect(bike < other_bike).to be false
      end
    end

    context 'when compare Car with other Car' do
      it 'returns correct comparison result' do
        expect(car == other_car).to be true
        expect(car >= other_car).to be true
        expect(car <= other_car).to be true
        expect(car > other_car).to be false
        expect(car < other_car).to be false
      end
    end

    context 'when compare Bike with Car' do
      it 'returns correct comparison result' do
        expect(bike == car).to be false
        expect(bike >= car).to be false
        expect(bike <= car).to be true
        expect(bike > car).to be false
        expect(bike < car).to be true
      end
    end

    context 'when compare Car with Bike' do
      it 'returns correct comparison result' do
        expect(car == bike).to be false
        expect(car >= bike).to be true
        expect(car <= bike).to be false
        expect(car > bike).to be true
        expect(car < bike).to be false
      end
    end

    context 'when Transport objects have same weight' do
      context 'with different max_distance' do
        before do
          allow(other_bike).to receive(:max_distance).and_return(50)
        end

        it 'returns correct comparison result' do
          expect(bike == other_bike).to be false
          expect(bike >= other_bike).to be false
          expect(bike <= other_bike).to be true
          expect(bike > other_bike).to be false
          expect(bike < other_bike).to be true
        end
      end
    end
  end

  context '#delivery_time' do
    let(:bike) { Bike.new }
    let(:car) { Car.new(registration_number: FFaker::Vehicle.vin) }

    context 'Bike' do
      it 'returns correct delivery speed' do
        expect(bike.delivery_time(25)).to eq 25.0 / BIKE_SPEED
      end
    end

    context 'Car' do
      it 'returns correct delivery speed' do
        expect(car.delivery_time(25)).to eq 25.0 / CAR_SPEED
      end
    end
  end
end
