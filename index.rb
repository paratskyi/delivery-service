require 'byebug'
require 'ffaker'
require_relative 'app/lib/const'
require_relative 'app/lib/support'
require_relative 'app/lib/transport_helper'
require_relative 'app/transport'
require_relative 'app/bike'
require_relative 'app/car'
require_relative 'app/delivery_service'

delivery_service = DeliveryService.new
transport = delivery_service.get_transport(weight: 5, distance: 5)
delivery_service.send_transport(transport) if transport
