require_relative 'app/lib/dependencies'

delivery_service = DeliveryService.new
transport = delivery_service.get_transport(weight: 5, distance: 5)
delivery_service.send_transport(transport) if transport
