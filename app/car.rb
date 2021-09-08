class Car < Transport
  attr_reader :registration_number

  def initialize(registration_number:)
    super(
      max_weight: CAR_MAX_WEIGHT,
      speed: CAR_SPEED
    )
    @registration_number = registration_number
  end
end
