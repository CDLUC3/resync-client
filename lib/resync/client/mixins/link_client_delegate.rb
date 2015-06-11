require 'resync'
require_relative 'client_delegator'

module Resync
  class Client
    module Mixins
      # A link container that is capable of providing those resources with a {Client}
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

  class Augmented
    prepend Client::Mixins::LinkClientDelegate
  end
end
