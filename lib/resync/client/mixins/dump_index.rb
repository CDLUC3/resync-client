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
          resources.lazy.flat_map do |r|
            package_for(r)
          end
        end

        def package_for(r)
          @zipped_resource_lists ||= {}
          @zipped_resource_lists[r] ||= r.get_and_parse
          @zipped_resource_lists[r].respond_to?(:zip_packages) ? @zipped_resource_lists[r].zip_packages : []
        end
      end
    end
  end

  class ChangeDumpIndex
    include Client::Mixins::DumpIndex

    def all_zip_packages(in_range: nil)
      if in_range
        dump_resources = change_lists(in_range: in_range, strict: false)
        dump_resources.lazy.flat_map { |cl| package_for(cl, in_range: in_range) }
      else
        super()
      end
    end

    def package_for(r, in_range: nil)
      @zipped_resource_lists ||= {}
      @zipped_resource_lists[r] ||= r.get_and_parse
      if @zipped_resource_lists[r].respond_to?(:zip_packages)
        if in_range
          @zipped_resource_lists[r].zip_packages(in_range: in_range)
        else
          super(r)
        end
      else
        []
      end
    end
  end

  class ResourceDumpIndex
    prepend Client::Mixins::DumpIndex
  end
end
