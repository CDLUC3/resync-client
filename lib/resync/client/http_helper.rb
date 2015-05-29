require 'net/http'
require 'tempfile'
require 'uri'
require 'mime-types'

module Resync

  # Utility class simplifying GET requests for HTTP/HTTPS resources.
  #
  class HTTPHelper

    # The default number of redirects to follow before erroring out.
    DEFAULT_MAX_REDIRECTS = 5

    # @!attribute [rw] user_agent
    #   @return [String] the User-Agent string to send when making requests
    attr_accessor :user_agent

    # @!attribute [rw] redirect_limit
    #   @return [Integer] the number of redirects to follow before erroring out
    attr_accessor :redirect_limit

    # Creates a new +HTTPHelper+
    #
    # @param user_agent [String] the User-Agent string to send when making requests
    # @param redirect_limit [Integer] the number of redirects to follow before erroring out
    #   (defaults to {DEFAULT_MAX_REDIRECTS})
    def initialize(user_agent:, redirect_limit: DEFAULT_MAX_REDIRECTS)
      @user_agent = user_agent
      @redirect_limit = redirect_limit
    end

    # Gets the content of the specified URI as a
    # {http://ruby-doc.org/stdlib-2.2.2/libdoc/net/http/rdoc/Net/HTTPResponse.html Net::HTTPResponse}
    # @param uri [URI] The URI to retrieve
    # @param limit [Integer] the number of redirects to follow before erroring out
    # @param block [Block] an optional block to be applied to the response in order to
    #   be able to invoke +Net::HTTPResponse#read_body+; if this is provided, the return
    #   value of the method will be the return value of the block. (It's a bit hackish;
    #   see {http://stackoverflow.com/a/29598327/27358 this Stack Overflow discussion}
    #   for an explanation of the underlying +Net:HTTP+ issues.)
    # @return [Net::HTTPResponse] the response, if successful, or the result of the applied
    #   block
    def fetch(uri, limit = redirect_limit, &block)
      fail "Redirect limit (#{redirect_limit}) exceeded retrieving URI #{uri}" if limit <= 0
      req = Net::HTTP::Get.new(uri, 'User-Agent' => user_agent)
      Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
        handle_response(uri, limit, req, http, &block)
      end
    end

    # Downloads the content of the specified URI to a temporary file
    # @return [String] the path to the temporary file
    def fetch_to_file(uri, limit = redirect_limit)
      fetch(uri, limit) do |response|
        tempfile = Tempfile.new(['resync-client', ".#{extension_for(response)}"])
        begin
          open tempfile, 'w' do |out|
            response.read_body { |chunk| out.write(chunk) }
          end
          return tempfile.path
        ensure
          tempfile.close
        end
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
      http.request(req) do |response|
        case response
        when Net::HTTPSuccess
          yield response if block_given?
          response
        when Net::HTTPInformation, Net::HTTPRedirection
          fetch(redirect_uri_for(response, uri), limit - 1)
        else
          fail "Error #{response.code}: #{response.message} retrieving URI #{uri}"
        end
      end
    end

  end
end
