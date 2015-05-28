require 'net/http'
require 'tempfile'
require 'uri'
require 'mime-types'

module Resync
  class Client

    class HTTPHelper

      DEFAULT_MAX_REDIRECTS = 5

      attr_accessor :user_agent
      attr_accessor :redirect_limit

      def initialize(user_agent:, redirect_limit: DEFAULT_MAX_REDIRECTS)
        @user_agent = user_agent
        @redirect_limit = redirect_limit
      end

      def fetch_to_file(uri, limit = redirect_limit)
        response = fetch(uri, limit)
        content_type = response['Content-Type']
        mime_type = MIME::Types[content_type].first || MIME::Types['application/octet-stream'].first
        extension = mime_type.preferred_extension || 'bin'
        tempfile = Tempfile.new(['resync-client', ".#{extension}"])
        ObjectSpace.undefine_finalizer(tempfile) # don't delete on exit
        begin
          open tempfile, 'w' do |out|
            response.read_body do |chunk|
              out.write(chunk)
            end
          end
          tempfile.path
        ensure
          tempfile.close
        end
      end

      def fetch(uri, limit = redirect_limit)
        fail "Redirect limit (#{redirect_limit}) exceeded" if limit <= 0
        req = Net::HTTP::Get.new(uri, 'User-Agent' => user_agent)
        Net::HTTP.start(uri.hostname, uri.port, use_ssl: (uri.scheme == 'https')) do |http|
          response = http.request(req)
          case response
          when Net::HTTPInformation
            fetch(uri, limit)
          when Net::HTTPRedirection
            location = response['location']
            new_uri = URI(location)
            new_uri = uri + location if new_uri.relative?
            fetch(new_uri, limit - 1)
          when Net::HTTPSuccess
            response
          else
            fail "Error #{response.code}: #{response.message} retrieving URI #{uri}"
          end
        end
      end
    end
  end
end
