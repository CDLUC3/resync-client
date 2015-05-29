require 'net/http'
require 'tempfile'
require 'uri'
require 'mime-types'

module Resync

  # Utility class simplifying GET requests for HTTP/HTTPS resources.
  #
  # @!attribute [rw] user_agent
  #   @return [String] the User-Agent string to send when making requests
  # @!attribute [rw] redirect_limit
  #   @return [Integer] the number of redirects to follow before erroring out
  class HTTPHelper

    # The default number of redirects to follow before erroring out.
    DEFAULT_MAX_REDIRECTS = 5

    attr_accessor :user_agent
    attr_accessor :redirect_limit

    # Creates a new +HTTPHelper+
    #
    # @param user_agent [String] the User-Agent string to send when making requests
    # @param redirect_limit [Integer] the number of redirects to follow before erroring out
    #   (defaults to {#DEFAULT_MAX_REDIRECTS})
    def initialize(user_agent:, redirect_limit: DEFAULT_MAX_REDIRECTS)
      @user_agent = user_agent
      @redirect_limit = redirect_limit
    end

    # Gets the content of the specified URI as a
    # {http://ruby-doc.org/stdlib-2.2.2/libdoc/net/http/rdoc/Net/HTTPResponse.html Net::HTTPResponse}
    # @return [Net::HTTPResponse] the response, if successful
    def fetch(uri, limit = redirect_limit)
      fail "Redirect limit (#{redirect_limit}) exceeded retrieving URI #{uri}" if limit <= 0
      req = Net::HTTP::Get.new(uri, 'User-Agent' => user_agent)
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
        handle_response(uri, limit, req, http)
      end
    end

    # Downloads the content of the specified URI to a temporary file
    # @return [String] the path to the temporary file
    def fetch_to_file(uri, limit = redirect_limit)
      response = fetch(uri, limit)
      tempfile = Tempfile.new(['resync-client', ".#{extension_for(response)}"])
      begin
        open tempfile, 'w' do |out|
          response.read_body { |chunk| out.write(chunk) }
        end
        tempfile.path
      ensure
        tempfile.close
      end
    end

    private

    def extension_for(response)
      content_type = response['Content-Type']
      mime_type = MIME::Types[content_type].first || MIME::Types['application/octet-stream'].first
      mime_type.preferred_extension || 'bin'
    end

    def redirect_uri_for(response, original_uri)
      if response.is_a?(Net::HTTPInformation)
        original_uri
      else
        location = response['location']
        new_uri = URI(location)
        new_uri.relative? ? original_uri + location : new_uri
      end
    end

    def handle_response(uri, limit, req, http)
      response = http.request(req)
      case response
      when Net::HTTPSuccess
        response
      when Net::HTTPInformation, Net::HTTPRedirection
        fetch(redirect_uri_for(response, uri), limit - 1)
      else
        fail "Error #{response.code}: #{response.message} retrieving URI #{uri}"
      end
    end

  end
end
