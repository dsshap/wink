require "wink/devices/device"

module Wink
  module Devices
    class Hub < Device
      def initialize(client, device)
        super

        @device_id  = device.fetch("hub_id")
      end

      def name
        device["name"]
      end


      def users
        response = client.get('/hubs{/hub}/users', :hub => device_id)
        response.body["data"]
      end

      def subscriptions
        response = client.get('/hubs{/hub}/subscriptions', :hub => device_id)
        response.body["data"]
      end

      def refresh
        response = client.post('/hubs{/hub}/refresh', :hub => device_id)
        response.body["data"]
      end

      def reload
        refresh
        response = client.get('/hubs{/hub}', :hub => device_id)
        @device = response.body["data"]
        self
      end

    end
  end
end
