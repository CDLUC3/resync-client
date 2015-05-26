require 'faraday'

module Resync
  class Client
    def initialize(connection: nil)
      @connection = connection || Faraday.new
    end

    def get(uri)
      uri = Resync::XML.to_uri(uri).to_s
      response = @connection.get(uri)
      XMLParser.parse(xml: response.body)
    end
  end
end
