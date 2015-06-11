require 'resync'
require_relative 'client/mixins'

Dir.glob(File.expand_path('../client/*.rb', __FILE__), &method(:require))

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
      doc.client_delegate = self
      doc
    end

    # Gets the content of the specified URI as a string.
    # @param uri [URI, String] the URI to download
    # @return [String] the content of the URI
    def get(uri)
      uri = Resync::XML.to_uri(uri)
      @helper.fetch(uri: uri)
    end

    # Gets the content of the specified URI and saves it to a temporary file.
    # @param uri [URI, String] the URI to download
    # @return [String] the path to the downloaded file
    def download_to_temp_file(uri)
      uri = Resync::XML.to_uri(uri)
      @helper.fetch_to_file(uri: uri)
    end

    # Gets the content of the specified URI and saves it to the specified file,
    # overwriting it if it exists.
    # @param uri [URI, String] the URI to download
    # @param path [String] the path to save the download to
    # @return [String] the path to the downloaded file
    def download_to_file(uri:, path:)
      uri = Resync::XML.to_uri(uri)
      @helper.fetch_to_file(path: path, uri: uri)
    end

    # Allows a {Client} to act as a {Mixins::ClientDelegator} delegate.
    # @return [Client] this client
    def client
      self
    end

  end
end
