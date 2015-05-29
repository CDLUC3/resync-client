require_relative 'version'
require_relative 'http_helper'

module Resync

  # Utility class for retrieving HTTP content and parsing it as ResourceSync documents.
  class Client

    # Creates a new +Client+
    # @param helper [HTTPHelper] the HTTP helper. Defaults to a new HTTP helper with
    #   +resync-client VERSION+ as the User-Agent string.
    def initialize(helper: HTTPHelper.new(user_agent: "resync-client #{VERSION}"))
      @helper = helper
    end

    # Gets the content of the specified URI and parses it as a ResourceSync document.
    def get(uri)
      uri = Resync::XML.to_uri(uri)
      raw_contents = get_raw(uri)
      doc = XMLParser.parse(raw_contents)
      doc.client = self
      doc
    end

    # Gets the content of the specified URI and returns the HTTP response.
    def get_raw(uri)
      uri = Resync::XML.to_uri(uri)
      @helper.fetch(uri).body
    end

    # Gets the content of the specified URI and saves it to a temporary file.
    def get_file(uri)
      uri = Resync::XML.to_uri(uri)
      @helper.fetch_to_file(uri)
    end

  end
end
