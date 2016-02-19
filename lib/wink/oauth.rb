require "faraday"
require "faraday_middleware"
require "multi_json"
require "addressable/template"

module Wink
  class Oauth

    def token(username, password)
      response = post('/oauth2/token', {
        body: {
          client_id: Wink.client_id,
          client_secret: Wink.client_secret,
          username: username,
          password: password,
          grant_type: "password"
        }
      })
      response.body["data"]
    end

    def refresh(refresh_token)
      response = post('/oauth2/token', {
        body: {
          client_id: Wink.client_id,
          client_secret: Wink.client_secret,
          refresh_token: refresh_token,
          grant_type: "refresh_token"
        }
      })
      response.body["data"]
    end

    def connection
      @connection ||= Faraday.new(Wink.endpoint) do |conn|
        conn.options[:timeout]      = 5
        conn.options[:open_timeout] = 2

        conn.request  :json
        conn.response :json, :content_type => /\bjson$/


        conn.adapter Faraday.default_adapter # make requests with Net::HTTP
      end
    end

    def request(method, path, params = {})
      body = params.delete(:body)
      body = MultiJson.dump(body) if Hash === body

      case method
      when :post
        connection.post(path) do |req|
          req.body = body if body
        end
      when :get
        connection.get(path) do |req|
          req.body = body if body
        end
      when :put
        connection.put(path, body)
      end
    end

    def post(path, params = {})
      request(:post, path, params)
    end

    def get(path, params = {})
      request(:get, path, params)
    end

    def put(path, params = {})
      request(:put, path, params)
    end

  end
end
