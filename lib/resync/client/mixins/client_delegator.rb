require 'resync/client'

# An object that delegates to another to provide a {Client} for downloading
# resources and links.
#
# @!attribute [rw] client_delegate
#   @return [#client] The client provider.
module Resync
  class Client
    module Mixins
      module ClientDelegator
        attr_accessor :client_delegate

        def client
          client_delegate.client
        end

        # Creates a one-off delegate wrapper around the specified {Client}
        # @param value [Client] the client
        def client=(value)
          @client_delegate = ClientDelegate.new(value)
        end

        # Minimal 'delegate' wrapper around a specified {Client}
        class ClientDelegate
          # @return [#client] the client
          attr_reader :client

          # Creates a new {ClientDelegate} wrapping the specified {Client}
          # @param client The client to delegate to
          def initialize(client)
            @client = client
          end
        end
      end
    end
  end
end
