require 'faraday'

module Resync
  class Client
    def initialize(faraday_client: nil)
      @http_client = faraday_client || Faraday.new
    end

    def get(uri)
      data = @http_client.get(uri)
      XMLParser.parse(data)
    end
  end
end
