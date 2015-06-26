require 'resync'
require_relative 'resource_client_delegate'

module Resync
  class Client
    module Mixins
      # A resource container whose resources are, themselves, resource containers
      module ListIndex
        prepend ResourceClientDelegate

        # Downloads and parses each resource list and returns a flattened enumeration
        # of all resources in each contained list. Each contained list is only downloaded
        # as needed, and only downloaded once.
        # @return [Enumerator::Lazy<Resync::Resource>] the flattened enumeration of resources
        def all_resources
          @resource_lists ||= {}
          resources.lazy.flat_map do |r|
            @resource_lists[r] ||= r.get_and_parse
            @resource_lists[r].resources
          end
        end
      end

      module PlainList
        # Delegates to {BaseResourceList#resources} for interoperation with {ListIndex#all_resources}.
        # @return [Enumerator::Lazy<Resync::Resource>] a lazy enumeration of the resources in this document
        def all_resources
          resources.lazy
        end
      end
    end
  end

  class ChangeListIndex
    prepend Client::Mixins::ListIndex
  end

  class ChangeList
    prepend Client::Mixins::PlainList
  end

  class ResourceListIndex
    prepend Client::Mixins::ListIndex
  end

  class ResourceList
    prepend Client::Mixins::PlainList
  end
end
