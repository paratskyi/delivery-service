RSpec.describe Transport do
  let(:transport_attributes) { %i[@max_weight @speed @available @location @delivery_cost @number_of_deliveries] }

  describe '#initialize' do
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

  describe '#all' do
    subject { klass.all }

    shared_examples :return_correct_transport_instances do
      it 'returns correct transport instances' do
        expect(subject.count).to eq transport_instances.count
        expect(subject).to instances_exact_match_array transport_instances
      end
    end

    shared_examples :return_empty_transport_instances do
      it 'returns empty array of transport instances' do
        expect(subject.count).to eq 0
        expect(subject).to be_empty
      end
    end

    before do
      klass.instance_variable_set(:@instances, [])
    end

    let!(:car_instances) { (1..5).map { Car.new(registration_number: FFaker::Vehicle.vin) } }
    let!(:bike_instances) { (1..5).map { Bike.new } }

    context 'when transport_instances with all transport types' do
      context 'Bike.all' do
        let(:klass) { Bike }
        let(:transport_instances) { bike_instances }
        it_behaves_like :return_correct_transport_instances
      end

      context 'Car.all' do
        let(:klass) { Car }
        let(:transport_instances) { car_instances }
        it_behaves_like :return_correct_transport_instances
      end

      context 'Transport.all' do
        let(:klass) { Transport }
        let(:transport_instances) { car_instances + bike_instances }
        it_behaves_like :return_correct_transport_instances
      end
    end

    context 'when transport_instances without bikes' do
      let!(:bike_instances) { [] }

      context 'Bike.all' do
        let(:klass) { Bike }
        it_behaves_like :return_empty_transport_instances
      end

      context 'Car.all' do
        let(:klass) { Car }
        let(:transport_instances) { car_instances }
        it_behaves_like :return_correct_transport_instances
      end

      context 'Transport.all' do
        let(:klass) { Transport }
        let(:transport_instances) { car_instances + bike_instances }
        it_behaves_like :return_correct_transport_instances
      end
    end

    context 'when transport_instances without cars' do
      let!(:car_instances) { [] }

      context 'Bike.all' do
        let(:klass) { Bike }
        let(:transport_instances) { bike_instances }
        it_behaves_like :return_correct_transport_instances
      end

      context 'Car.all' do
        let(:klass) { Car }
        it_behaves_like :return_empty_transport_instances
      end

      context 'Transport.all' do
        let(:klass) { Transport }
        let(:transport_instances) { car_instances + bike_instances }
        it_behaves_like :return_correct_transport_instances
      end
    end

    context 'when empty transport_instances' do
      let!(:bike_instances) { [] }
      let!(:car_instances) { [] }

      context 'Bike.all' do
        let(:klass) { Bike }
        it_behaves_like :return_empty_transport_instances
      end

      context 'Car.all' do
        let(:klass) { Car }
        it_behaves_like :return_empty_transport_instances
      end

      context 'Transport.all' do
        let(:klass) { Transport }
        it_behaves_like :return_empty_transport_instances
      end
    end
  end

  describe '#custom_methods' do
    shared_examples :has_all_custom_methods do
      it 'must has all custom methods' do
        custom_methods = transport_attributes.map { |attribute| "find_by_#{attribute.to_s.sub('@', '')}".to_sym }
        custom_methods += transport_attributes.map { |attribute| "filter_by_#{attribute.to_s.sub('@', '')}".to_sym }
        expect(klass.methods).to include(*custom_methods)
      end
    end

    shared_examples :find_by_attribute_return_correct_transport do
      it 'returns correct transport' do
        transport_attributes.each do |attribute|
          method_name = "find_by_#{attribute.to_s.sub('@', '')}"
          instance_variable_value = expected_transport.instance_variable_get(attribute)

          expect(
            klass.public_send(method_name, instance_variable_value).instance_variable_get(attribute)
          ).to eq instance_variable_value

          expect(klass.public_send(method_name, instance_variable_value)).to be_a(klass)
          expect(klass.public_send(method_name, instance_variable_value).to_s).to eq expected_transport.to_s
        end
      end
    end

    shared_examples :filter_by_attribute_return_correct_transport_collection do
      it 'returns correct transport collection' do
        transport_attributes.each do |attribute|
          method_name = "filter_by_#{attribute.to_s.sub('@', '')}"
          block = proc { |value| value == expected_transports.first.public_send(attribute.to_s.sub('@', '')) }
          expect(klass.public_send(method_name, &block).count).to eq expected_transports.count
          expect(klass.public_send(method_name, &block)).to instances_exact_match_array expected_transports
        end
      end
    end

    shared_examples :find_by_not_equal_value_return_nil do
      it 'returns nil' do
        transport_attributes.each do |attribute|
          next if attribute == :@available

          method_name = "find_by_#{attribute.to_s.sub('@', '')}"
          instance_variable_value = expected_transport.instance_variable_get(attribute)

          not_eq_value = case instance_variable_value
                         when Integer then instance_variable_value + 1
                         when String then "Not eq #{instance_variable_value}"
                         when FalseClass, TrueClass then !attribute
                         end

          expect(klass.public_send(method_name, not_eq_value)).to be_nil
        end
      end
    end

    shared_examples :find_by_with_empty_instances_return_nil do
      it 'returns nil' do
        transport_attributes.each do |attribute|
          method_name = "find_by_#{attribute.to_s.sub('@', '')}"
          instance_variable_value = expected_transport.instance_variable_get(attribute)

          klass.instance_variable_set(:@instances, [])

          expect(klass.public_send(method_name, instance_variable_value)).to be_nil
        end
      end
    end

    shared_examples :filter_by_not_equal_value_return_empty_array do
      it 'returns empty array' do
        transport_attributes.each do |attribute|
          next if attribute == :@available

          method_name = "filter_by_#{attribute.to_s.sub('@', '')}"
          instance_variable_value = expected_transports.first.public_send(attribute.to_s.sub('@', ''))
          not_eq_value = case instance_variable_value
                         when Integer then instance_variable_value + 1
                         when String then "Not eq #{instance_variable_value}"
                         when FalseClass, TrueClass then !attribute
                         end
          block = proc { |value| value == not_eq_value }
          expect(klass.public_send(method_name, &block)).to be_a Array
          expect(klass.public_send(method_name, &block)).to be_empty
        end
      end
    end

    shared_examples :filter_by_with_empty_instances_return_empty_array do
      it 'returns empty array' do
        transport_attributes.each do |attribute|
          method_name = "filter_by_#{attribute.to_s.sub('@', '')}"
          block = proc { |value| value == expected_transports.first.public_send(attribute.to_s.sub('@', '')) }
          klass.instance_variable_set(:@instances, [])
          expect(klass.public_send(method_name, &block)).to be_a Array
          expect(klass.public_send(method_name, &block)).to be_empty
        end
      end
    end

    shared_context :stub_expected_transport_attributes do
      before do
        transport_attributes.each do |attribute|
          instance_variable_value = expected_transport.instance_variable_get(attribute)
          case instance_variable_value
          when Integer
            expected_transport.instance_variable_set(attribute, instance_variable_value + 1)
          when String
            expected_transport.instance_variable_set(attribute, "Test #{instance_variable_value}")
          when FalseClass, TrueClass
            expected_transport.instance_variable_set(attribute, !attribute)
          end
        end
      end
    end

    shared_context :stub_expected_transport_collection_attributes do
      before do
        expected_transports.each do |expected_transport|
          transport_attributes.each do |attribute|
            instance_variable_value = expected_transport.instance_variable_get(attribute)
            case instance_variable_value
            when Integer
              expected_transport.instance_variable_set(attribute, 1)
            when String
              expected_transport.instance_variable_set(attribute, 'Test location')
            when FalseClass, TrueClass
              expected_transport.instance_variable_set(attribute, !attribute)
            end
          end
        end
      end
    end

    before do
      klass.instance_variable_set(:@instances, [])
      (1..5).map { Car.new(registration_number: FFaker::Vehicle.vin) }
      (1..5).map { Bike.new }
    end

    context 'Bike' do
      let(:transport_attributes) { super().concat([:@max_distance]) }
      let(:klass) { Bike }
      let(:expected_transport) { klass.new }

      let!(:expected_transports) { (1..5).map { klass.new } }

      it_behaves_like :has_all_custom_methods

      context 'find_by_{attribute}' do
        include_context :stub_expected_transport_attributes
        it_behaves_like :find_by_attribute_return_correct_transport
        it_behaves_like :find_by_not_equal_value_return_nil
        it_behaves_like :find_by_with_empty_instances_return_nil
      end

      context 'filter_by_{attribute}' do
        include_context :stub_expected_transport_collection_attributes
        it_behaves_like :filter_by_attribute_return_correct_transport_collection
        it_behaves_like :filter_by_not_equal_value_return_empty_array
        it_behaves_like :filter_by_with_empty_instances_return_empty_array
      end
    end

    context 'Car' do
      let(:transport_attributes) { super().concat([:@registration_number]) }
      let(:klass) { Car }
      let(:transport_params) { { registration_number: FFaker::Vehicle.vin } }
      let(:expected_transport) { klass.new(transport_params) }

      let!(:expected_transports) { (1..5).map { klass.new(transport_params) } }

      it_behaves_like :has_all_custom_methods

      context 'find_by_{attribute}' do
        include_context :stub_expected_transport_attributes
        it_behaves_like :find_by_attribute_return_correct_transport
        it_behaves_like :find_by_not_equal_value_return_nil
        it_behaves_like :find_by_with_empty_instances_return_nil
      end

      context 'filter_by_{attribute}' do
        include_context :stub_expected_transport_collection_attributes
        it_behaves_like :filter_by_attribute_return_correct_transport_collection
        it_behaves_like :filter_by_not_equal_value_return_empty_array
        it_behaves_like :filter_by_with_empty_instances_return_empty_array
      end
    end

    context 'Transport' do
      let(:klass) { Transport }

      it_behaves_like :has_all_custom_methods

      context 'find_by_{attribute}' do
        context 'Bike' do
          let(:expected_transport) { Bike.new }

          include_context :stub_expected_transport_attributes
          it_behaves_like :find_by_attribute_return_correct_transport
          it_behaves_like :find_by_not_equal_value_return_nil
          it_behaves_like :find_by_with_empty_instances_return_nil
        end

        context 'Car' do
          let(:transport_params) { { registration_number: FFaker::Vehicle.vin } }
          let(:expected_transport) { Car.new(transport_params) }

          include_context :stub_expected_transport_attributes
          it_behaves_like :find_by_attribute_return_correct_transport
          it_behaves_like :find_by_not_equal_value_return_nil
          it_behaves_like :find_by_with_empty_instances_return_nil
        end
      end

      context 'filter_by_{attribute}' do
        let(:transport_params) { { registration_number: FFaker::Vehicle.vin } }
        let!(:expected_transports) { (1..5).map { Car.new(transport_params) } + (1..5).map { Bike.new } }

        include_context :stub_expected_transport_collection_attributes
        it_behaves_like :filter_by_attribute_return_correct_transport_collection
        it_behaves_like :filter_by_not_equal_value_return_empty_array
        it_behaves_like :filter_by_with_empty_instances_return_empty_array
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
