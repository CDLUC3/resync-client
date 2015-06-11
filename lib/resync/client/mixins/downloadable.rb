require_relative 'client_delegator'

module Resync
  class Client
    module Mixins
      # A downloadable resource or link.
      module Downloadable
        prepend ClientDelegator

        # Delegates to {Client#get_and_parse} to get the contents of
        # +:uri+ as a ResourceSync document
        def get_and_parse # rubocop:disable Style/AccessorMethodName
          client.get_and_parse(uri)
        end

        # Delegates to {Client#get} to get the contents of this +:uri+
        def get # rubocop:disable Style/AccessorMethodName
          client.get(uri)
        end

        # Delegates to {Client#download_to_temp_file} to download the
        # contents of +:uri+ to a file.
        def download_to_temp_file # rubocop:disable Style/AccessorMethodName
          client.download_to_temp_file(uri)
        end

        # Delegates to {Client#download_to_file} to download the
        # contents of +:uri+ to the specified path.
        # @param path [String] the path to download to
        def download_to_file(path)
          client.download_to_file(uri: uri, path: path)
        end
      end
    end
  end
end
