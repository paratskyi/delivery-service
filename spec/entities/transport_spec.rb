RSpec.describe Transport do
  describe '#initialize' do
    let(:transport_attributes) { %i[@max_weight @speed @available @location @delivery_cost @number_of_deliveries] }

    context 'Bike' do
      subject { Bike.new }
      let(:transport_attributes) { super().concat([:@max_distance]) }

      it 'must have correct attributes' do
        expect(subject).to be_a(Bike)
        expect(subject.instance_variables).to match_array(transport_attributes)
        expect(subject).to have_attributes(
          max_weight: BIKE_MAX_WEIGHT,
          speed: BIKE_SPEED,
          max_distance: BIKE_MAX_DISTANCE,
          available: true,
          location: 'In garage'
        )
      end
    end

    context 'Car' do
      subject { Car.new(transport_params) }
      let(:transport_params) { { registration_number: FFaker::Vehicle.vin } }
      let(:transport_attributes) { super().concat([:@registration_number]) }

      it 'must have correct attributes' do
        expect(subject).to be_a(Car)
        expect(subject.instance_variables).to match_array(transport_attributes)
        expect(subject).to have_attributes(
          max_weight: CAR_MAX_WEIGHT,
          speed: CAR_SPEED,
          registration_number: transport_params[:registration_number],
          available: true,
          location: 'In garage'
        )
      end

      context 'without params' do
        let(:transport_params) { nil }

        it 'raises argument error' do
          expect { subject }.to raise_error(ArgumentError)
        end
      end
    end
  end

  describe '#location' do
    let(:valid_locations) { LOCATION }
    let(:invalid_locations) { [nil, '', ' ', 'asdf', 'In route', 'On garage'] }

    shared_examples :set_correct_location do
      it 'sets correct location' do
        valid_locations.each do |location|
          transport.location = location
          expect(transport.location).to eq location
        end
      end
    end

    shared_examples :raise_error do
      it 'raises argument error' do
        invalid_locations.each do |location|
          expect { transport.location = location }.to raise_error(
            ArgumentError,
            "'#{location}' is invalid for location attribute"
          )
        end
      end
    end

    context 'Bike' do
      let(:transport) { Bike.new }

      context 'with valid locations' do
        it_behaves_like :set_correct_location
      end

      context 'with invalid locations' do
        it_behaves_like :raise_error
      end
    end

    context 'Car' do
      let(:transport) { Car.new(registration_number: FFaker::Vehicle.vin) }

      context 'with valid locations' do
        it_behaves_like :set_correct_location
      end

      context 'with invalid locations' do
        it_behaves_like :raise_error
      end
    end
  end

  describe '#comparable' do
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

  describe '#delivery_time' do
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
