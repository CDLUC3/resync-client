require 'resync'
require_relative 'resource_client_delegate'

module Resync
  class Client
    module Mixins
      # A resource container whose resources are not, themselves, resource containers
      module PlainList
        # Delegates to {BaseResourceList#resources} for interoperation with {ListIndex#all_resources}.
        # @return [Enumerator::Lazy<Resync::Resource>] a lazy enumeration of the resources in this document
        def all_resources
          resources.lazy
        end
      end
    end
  end

  class ChangeList
    prepend Client::Mixins::PlainList
  end

  class ResourceList
    prepend Client::Mixins::PlainList
  end
end
