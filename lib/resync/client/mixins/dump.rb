require 'resync'
require 'promise'
require 'resync/client/zip'
require 'resync/client/mixins/zipped_resource'

module Resync
  class Client
    module Mixins
      # A list of resources each of which refers to a zipped bitstream package.
      module Dump

        # Makes each resource a {ZippedResource}
        def resources=(value)
          super
          resources.each do |r|
            next if r.respond_to?(:zip_package)
            class << r
              prepend ZippedResource
            end
          end
        end

        # The {Resync::Client::Zip::ZipPackage}s for each resource, downloaded lazily
        # @return [Array<Promise<Resync::Client::Zip::ZipPackage>>] the zip packages for each resource
        def zip_packages
          @zip_packages ||= resources.map { |r| promise { r.zip_package } }
        end

      end
    end
  end

  class ResourceDump
    prepend Client::Mixins::Dump

    # Delegates to {#zip_packages} for interoperation with {DumpIndex#all_zip_packages}.
    # @return [Enumerator::Lazy<Resync::Resource>] a lazy enumeration of the packages for each
    #    resource
    def all_zip_packages
      zip_packages.lazy
    end
  end

  class ChangeDump
    include Client::Mixins::Dump

    # A list (downloaded lazily) of the {Resync::Client::Zip::ZipPackage}s for each resource
    # If a time range parameter is provided, the lists of packages is filtered by +from_time+
    # and +until_time+, in non-strict mode (only excluding those lists provably not in the range,
    # i.e., including packages without +from_time+ or +until_time+).
    # @param in_range [Range<Time>] the range of times to filter by
    # @return [Array<Promise<Resync::Client::Zip::ZipPackage>>] the zip packages for each resource
    def zip_packages(in_range: nil)
      if in_range
        change_lists = change_lists(in_range: in_range, strict: false)
        change_lists.map { |r| promise { r.zip_package } }
      else
        super()
      end
    end

    # Delegates to {#zip_packages} for interoperation with {ChangeDumpIndex#all_zip_packages}.
    # @return [Enumerator::Lazy<Resync::Resource>] a lazy enumeration of the packages for each
    #    resource
    def all_zip_packages(in_range: nil)
      zip_packages(in_range: in_range).lazy
    end
  end
end
