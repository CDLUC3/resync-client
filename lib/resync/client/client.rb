require_relative 'version'
require_relative 'http_client'

module Resync
  class Client

    def initialize(http_client: HttpClient.new(user_agent: "resync-client #{VERSION}"))
      @http_client = http_client
    end

    def get(uri)
      uri = Resync::XML.to_uri(uri)
      raw_contents = get_raw(uri)
      doc = XMLParser.parse(raw_contents)
      doc.client = self
      doc
    end

    def get_raw(uri)
      uri = Resync::XML.to_uri(uri)
      @http_client.fetch(uri).body
    end

    def get_file(uri)
      uri = Resync::XML.to_uri(uri)
      @http_client.fetch_to_file(uri)
    end

  end
end

