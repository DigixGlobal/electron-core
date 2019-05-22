# frozen_string_literal: true

require 'arkency/command_bus'

Rails.configuration.to_prepare do
  Rails.configuration.event_store = event_store = RailsEventStore::Client.new

  # Rails.configuration.command_bus = Arkency::CommandBus.new
  # register = command_bus.method(:register)

  # { FooCommand => FooService.new(event_store: event_store).method(:foo),
  #   BarCommand => BarService.new }.map(&register)

  # event_store.subscribe(OrderNotifier.new, to: [OrderCancelled])
end
