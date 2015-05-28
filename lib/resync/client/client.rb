require_relative 'version'
require_relative 'http_helper'

module Resync
  class Client

    def initialize(helper: HTTPHelper.new(user_agent: "resync-client #{VERSION}"))
      @helper = helper
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
      @helper.fetch(uri).body
    end

    def get_file(uri)
      uri = Resync::XML.to_uri(uri)
      @helper.fetch_to_file(uri)
    end

  end
end
