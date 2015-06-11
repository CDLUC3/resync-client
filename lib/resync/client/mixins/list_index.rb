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
          resources.flat_map do |r|
            @resource_lists[r] ||= r.get_and_parse
            @resource_lists[r].resources
          end
        end
      end
    end
  end

  class ChangeListIndex
    prepend Client::Mixins::ListIndex
  end

  class ResourceListIndex
    prepend Client::Mixins::ListIndex
  end

  class BaseChangeIndex
    def all_changes(of_type: nil, in_range: nil)
      @change_lists ||= {}
      lists = in_range ? change_lists(in_range: in_range) : resources
      lists.flat_map do |cl|
        @change_lists[cl] ||= cl.get_and_parse
        @change_lists[cl].changes(of_type: of_type, in_range: in_range)
      end
    end
  end
end
