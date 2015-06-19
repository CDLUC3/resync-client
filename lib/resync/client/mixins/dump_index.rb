require 'resync'
require_relative 'resource_client_delegate'

module Resync
  class Client
    module Mixins
      # A resource container whose resources are {ZippedResourceList}s
      module DumpIndex
        prepend ResourceClientDelegate

        # Downloads and parses each resource list and returns a flattened enumeration
        # of all zip packages in each contained list. Each contained list is only downloaded
        # as needed, and only downloaded once.
        # @return [Enumerator::Lazy<Resync::Client::Zip::ZipPackage>] the flattened enumeration of resources
        def all_zip_packages
          @zipped_resource_lists ||= {}
          resources.flat_map do |r|
            @zipped_resource_lists[r] ||= r.get_and_parse
            @zipped_resource_lists[r].respond_to?(:zip_packages) ? @zipped_resource_lists[r].zip_packages : []
          end
        end
      end
    end
  end

  class ChangeDumpIndex
    prepend Client::Mixins::DumpIndex
  end

  class ResourceDumpIndex
    prepend Client::Mixins::DumpIndex
  end
end
