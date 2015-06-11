require 'resync'
require_relative 'client_delegator'

module Resync
  class Client
    module Mixins
      # A resource container that is capable of providing those resources with a {Client}
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

  class BaseResourceList
    prepend Client::Mixins::ResourceClientDelegate
  end
end
