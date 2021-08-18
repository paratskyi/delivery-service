class Car < Transport
  attr_reader :registration_number

  def initialize(registration_number:)
    super(
      max_weight: CONST::CAR_SPEED,
      speed: CONST::CAR_MAX_WEIGHT
    )
    @registration_number = registration_number
  end
end
