module Resync
  module Extensions

    # Injects a {Client} that subclasses can use to fetch
    # resources and links
    #
    # @!attribute [rw] client
    #   @return [Client] the injected {Client}. Defaults to
    #     a new {Client} instance.
    module WithClient
      attr_writer :client

      def client
        @client ||= Client.new
      end
    end

    # Allows a delegate to provide a {Client}. The delegate
    # can be any object with a +:client+ method.
    #
    # @!attribute [rw] client
    #   @return [Client] the delegate's {Client}.
    module WithClientDelegate
      attr_writer :client_delegate

      def client
        @client_delegate.client
      end
    end
  end
end
