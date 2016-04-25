require 'resync'
require 'resync/client/mixins/resource_client_delegate'

module Resync
  class Client
    module Mixins
      # A resource container whose resources are {ZippedResourceList}s
      module DumpIndex
        prepend ResourceClientDelegate

        # Downloads and parses each resource list and returns a flattened enumeration
        # of all zip packages in each contained list. Each contained list is only downloaded
        # as needed, and only downloaded once.
        # @return [Enumerator::Lazy<Resync::Client::Zip::ZipPackage>] the flattened enumeration of packages
        def all_zip_packages
          resources.lazy.flat_map do |r|
            package_for(r)
          end
        end

        private

        def zipped_resource_list_for(r)
          @zipped_resource_lists ||= {}
          @zipped_resource_lists[r] ||= r.get_and_parse
        end

        def package_for(r)
          zrl = zipped_resource_list_for(r)
          zrl.respond_to?(:zip_packages) ? zrl.zip_packages : []
        end
      end
    end
  end

  class ChangeDumpIndex
    include Client::Mixins::DumpIndex

    # Downloads and parses each resource list and returns a flattened enumeration
    # of all zip packages in each contained list. Each contained list is only downloaded
    # as needed, and only downloaded once.
    # If a time range parameter is provided, the lists of packages is filtered by +from_time+
    # and +until_time+, in non-strict mode (only excluding those lists provably not in the range,
    # i.e., including packages without +from_time+ or +until_time+).
    # @param in_range [Range<Time>] the range of times to filter by
    # @return [Enumerator::Lazy<Resync::Client::Zip::ZipPackage>] the flattened enumeration of packages
    def all_zip_packages(in_range: nil)
      if in_range
        dump_resources = change_lists(in_range: in_range, strict: false)
        dump_resources.lazy.flat_map { |cl| package_for(cl, in_range: in_range) }
      else
        super()
      end
    end

    private

    def package_for(r, in_range: nil)
      zrl = zipped_resource_list_for(r)
      in_range ? zrl.zip_packages(in_range: in_range) : super(r)
    end
  end

  class ResourceDumpIndex
    prepend Client::Mixins::DumpIndex
  end
end
