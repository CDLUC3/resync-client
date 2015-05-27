require 'faraday'

module Resync
  class Client
    def initialize(connection: nil)
      @connection = connection || Faraday.new
    end

    def get(uri)
      uri = Resync::XML.to_uri(uri).to_s
      response = get_raw(uri)
      doc = XMLParser.parse(xml: response.body)
      doc.client = self
      doc
    end

    def get_raw(uri)
      uri = Resync::XML.to_uri(uri).to_s
      @connection.get(uri)
    end
  end
end
