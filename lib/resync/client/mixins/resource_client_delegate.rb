require_relative 'client_delegator'

# A resource container that is capable of providing those resources with a {Client}
module Resync
  class Client
    module Mixins
      module ResourceClientDelegate
        prepend ClientDelegator

        # Sets this object as the client provider delegate for each resource.
        # @param value [Array<Resource>] the resources for this list
        def resources=(value)
          super
          resources.each { |r| r.client_delegate = self }
        end
      end
    end
  end
end
