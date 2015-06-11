require_relative 'resource_client_delegate'

module Resync
  class Client
    module Mixins
      # A resource container whose resources are, themselves, resource containers
      module ListOfResourceLists
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
end
