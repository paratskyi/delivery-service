RSpec.describe DeliveryService do
  let(:delivery_service) { DeliveryService.new }
  let(:delivery_params) { { weight: BIKE_MAX_WEIGHT, distance: max_distance_for(available_bike) } }

  let(:available_bike) { Bike.new }
  let(:not_available_bike) { Bike.new }
  let(:available_car) { Car.new(registration_number: FFaker::Vehicle.vin) }
  let(:not_available_car) { Car.new(registration_number: FFaker::Vehicle.vin) }
  let(:stub_transport_park!) do
    allow(delivery_service).to receive(:transport_park).and_return(
      [available_bike, not_available_bike, available_car, not_available_car]
    )
  end

  before do
    allow(not_available_bike).to receive(:available).and_return(false)
    allow(not_available_car).to receive(:available).and_return(false)
  end

  describe '#initialize' do
    let(:transport_park) { delivery_service.transport_park }

    it 'transport park must have at least one Bike' do
      expect(transport_park).not_to be_empty
      expect(transport_park.find(&:bike?)).to be_a(Bike)
    end

    it 'delivery service errors must have not errors' do
      expect(delivery_service.errors).to eq []
    end
  end

  describe '#get_transport' do
    subject { delivery_service.get_transport(delivery_params) }

    shared_examples :return_correct_transport do
      let!(:transport) { nil }

      it 'returns correct transport' do
        expect { subject }.not_to raise_error
        expect(subject.available).to be true
        expect(subject).to be_a(transport.class)
        expect(subject.to_s).to eq transport.to_s
      end
    end

    shared_examples :return_nil_with_correct_error do
      it 'returns nil with correct error' do
        expect(subject).to be_nil
        expect(delivery_service.errors).not_to be_empty
        expect(delivery_service.errors.first).to eq 'No available transport'
      end
    end

    before do
      stub_transport_park!
    end

    context 'with empty delivery params' do
      let(:delivery_params) { {} }
      it 'raises argument error' do
        expect { subject }.to raise_error(ArgumentError, 'missing keywords: weight, distance')
      end
    end

    context 'after sending transport' do
      let(:stub_transport_park!) do
        allow(delivery_service).to receive(:transport_park).and_return(
          [available_bike, other_available_bike, not_available_bike]
        )
      end
      let(:other_available_bike) { Bike.new }

      before do
        delivery_service.send_transport(available_bike)
      end

      it_behaves_like :return_correct_transport do
        let(:transport) { other_available_bike }
      end
    end

    context 'when transport park with all transport types' do
      context 'with delivery params witch correct for Bike' do
        it_behaves_like :return_correct_transport do
          let(:transport) { available_bike }
        end
      end

      context 'with delivery params witch not correct for Bike' do
        context 'weight' do
          let(:delivery_params) do
            super().merge({ weight: BIKE_MAX_WEIGHT + 1 })
          end

          it_behaves_like :return_correct_transport do
            let(:transport) { available_car }
          end
        end

        context 'distance' do
          let(:delivery_params) do
            super().merge({ distance: max_distance_for(available_bike) + 1 })
          end

          it_behaves_like :return_correct_transport do
            let(:transport) { available_car }
          end
        end
      end

      context 'with delivery params witch not correct for Car' do
        let(:delivery_params) { { weight: CAR_MAX_WEIGHT + 1, distance: max_distance_for(available_car) } }

        it_behaves_like :return_nil_with_correct_error
      end
    end

    context 'when transport park has only bikes' do
      let(:delivery_params) { { weight: BIKE_MAX_WEIGHT, distance: max_distance_for(available_bike) } }
      let(:stub_transport_park!) do
        allow(delivery_service).to receive(:transport_park).and_return(
          [available_bike, not_available_bike]
        )
      end

      context 'with delivery params witch correct for Bike' do
        it_behaves_like :return_correct_transport do
          let(:transport) { available_bike }
        end
      end

      context 'with delivery params witch not correct for Bike' do
        context 'weight' do
          let(:delivery_params) do
            super().merge({ weight: BIKE_MAX_WEIGHT + 1 })
          end

          it_behaves_like :return_nil_with_correct_error
        end

        context 'distance' do
          let(:delivery_params) do
            super().merge({ distance: max_distance_for(available_bike) + 1 })
          end

          it_behaves_like :return_nil_with_correct_error
        end
      end

      context 'with delivery params witch not correct for Car' do
        let(:delivery_params) { { weight: CAR_MAX_WEIGHT + 1, distance: max_distance_for(available_car) } }

        it_behaves_like :return_nil_with_correct_error
      end
    end

    context 'when transport park has only cars' do
      let(:delivery_params) { { weight: BIKE_MAX_WEIGHT, distance: max_distance_for(available_bike) } }
      let(:stub_transport_park!) do
        allow(delivery_service).to receive(:transport_park).and_return(
          [available_car, not_available_car]
        )
      end

      context 'with delivery params witch correct for Bike' do
        it_behaves_like :return_correct_transport do
          let(:transport) { available_car }
        end
      end

      context 'with delivery params witch not correct for Bike' do
        context 'weight' do
          let(:delivery_params) do
            super().merge({ weight: BIKE_MAX_WEIGHT + 1 })
          end

          it_behaves_like :return_correct_transport do
            let(:transport) { available_car }
          end
        end

        context 'distance' do
          let(:delivery_params) do
            super().merge({ distance: max_distance_for(available_bike) + 1 })
          end

          it_behaves_like :return_correct_transport do
            let(:transport) { available_car }
          end
        end
      end

      context 'with delivery params witch not correct for Car' do
        let(:delivery_params) { { weight: CAR_MAX_WEIGHT + 1, distance: max_distance_for(available_car) } }

        it_behaves_like :return_nil_with_correct_error
      end
    end

    context 'when empty transport park' do
      let(:delivery_params) { { weight: BIKE_MAX_WEIGHT, distance: max_distance_for(available_bike) } }
      let(:stub_transport_park!) do
        allow(delivery_service).to receive(:transport_park).and_return([])
      end

      context 'with delivery params witch correct for Bike' do
        it_behaves_like :return_nil_with_correct_error
      end

      context 'with delivery params witch not correct for Bike' do
        context 'weight' do
          let(:delivery_params) do
            super().merge({ weight: BIKE_MAX_WEIGHT + 1 })
          end

          it_behaves_like :return_nil_with_correct_error
        end

        context 'distance' do
          let(:delivery_params) do
            super().merge({ distance: max_distance_for(available_bike) + 1 })
          end

          it_behaves_like :return_nil_with_correct_error
        end
      end

      context 'with delivery params witch not correct for Car' do
        let(:delivery_params) { { weight: CAR_MAX_WEIGHT + 1, distance: max_distance_for(available_car) } }

        it_behaves_like :return_nil_with_correct_error
      end
    end
  end

  describe '#send_transport' do
    subject { delivery_service.send_transport(transport) }

    let(:transport) { delivery_service.get_transport(delivery_params) }

    context 'when transport present' do
      it 'correct updates transport attributes' do
        expect(transport.available).to be true
        expect(transport.number_of_deliveries).to eq 0
        expect(transport.location).to eq 'In garage'

        subject

        expect(transport.number_of_deliveries).to eq 1
        expect(transport.available).to be false
        expect(transport.location).to eq 'On route'
      end
    end

    context 'when transport does not present' do
      let(:transport) { nil }

      it 'raises argument error' do
        expect { subject }.to raise_error(ArgumentError, 'Transport should be present')
      end
    end
  end
end
