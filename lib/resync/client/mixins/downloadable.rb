require 'resync'
require 'resync/client/mixins/client_delegator'

module Resync
  class Client
    module Mixins
      # A downloadable resource or link.
      module Downloadable
        prepend ClientDelegator

        # Delegates to {Client#get_and_parse} to get the contents of
        # +:uri+ as a ResourceSync document. The downloaded, parsed
        # document will only be downloaded once; subsequent calls to
        # this method will return the cached document.
        def get_and_parse # rubocop:disable Style/AccessorMethodName
          @parsed_content ||= client.get_and_parse(uri)
        end

        # Delegates to {Client#get} to get the contents of this +:uri+.
        # The downloaded content will only be downloaded once; subsequent
        # calls to this method will return the cached content.
        def get # rubocop:disable Style/AccessorMethodName
          @content ||= client.get(uri)
        end

        # Delegates to {Client#download_to_temp_file} to download the
        # contents of +:uri+ to a file. Subsequent calls will download
        # the contents again, each time to a fresh temporary file.
        def download_to_temp_file # rubocop:disable Style/AccessorMethodName
          client.download_to_temp_file(uri)
        end

        # Delegates to {Client#download_to_file} to download the
        # contents of +:uri+ to the specified path. Subsequent
        # calls wiill download the contents again, potentially
        # overwriting the file if given the same path.
        # @param path [String] the path to download to
        def download_to_file(path)
          client.download_to_file(uri: uri, path: path)
        end
      end
    end
  end

  class Link
    prepend Client::Mixins::Downloadable
  end

  class Resource
    prepend Client::Mixins::Downloadable
  end
end
