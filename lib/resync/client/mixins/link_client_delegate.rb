require_relative 'client_delegator'

# A link container that is capable of providing those resources with a {Client}
module Resync
  class Client
    module Mixins
      module LinkClientDelegate
        prepend ClientDelegator

        # Sets this object as the client provider delegate for each link.
        # @param value [Array<Link>] the links for this list
        def links=(value)
          super
          links.each { |l| l.client_delegate = self }
        end
      end
    end
  end
end
