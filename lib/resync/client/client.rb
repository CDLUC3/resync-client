require_relative 'version'
require_relative 'http_helper'

module Resync

  # Utility class for retrieving HTTP content and parsing it as ResourceSync documents.
  class Client

    # ------------------------------------------------------------
    # Initializer

    # Creates a new +Client+
    # @param helper [HTTPHelper] the HTTP helper. Defaults to a new HTTP helper with
    #   +resync-client VERSION+ as the User-Agent string.
    def initialize(helper: HTTPHelper.new(user_agent: "resync-client #{VERSION}"))
      @helper = helper
    end

    # ------------------------------------------------------------
    # Public methods

    # Gets the content of the specified URI and parses it as a ResourceSync document.
    def get_and_parse(uri)
      uri = Resync::XML.to_uri(uri)
      raw_contents = get(uri)
      doc = XMLParser.parse(raw_contents)
      doc.client = self
      doc
    end

    # Gets the content of the specified URI as a string.
    def get(uri)
      uri = Resync::XML.to_uri(uri)
      @helper.fetch(uri: uri)
    end

    # Gets the content of the specified URI and saves it to a temporary file.
    # @return the path to the downloaded file
    def download_to_temp_file(uri)
      uri = Resync::XML.to_uri(uri)
      @helper.fetch_to_file(uri: uri)
    end

    # Gets the content of the specified URI and saves it to the specified file.
    # @param path [String] the path to save the download to
    def download_to_file(uri:, path:)
      uri = Resync::XML.to_uri(uri)
      @helper.fetch_to_file(path: path, uri: uri)
    end

  end
end
