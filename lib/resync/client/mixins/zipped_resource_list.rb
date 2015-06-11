require_relative '../zip'
require_relative 'zipped_resource'

module Resync
  class Client
    module Mixins
      # A list of resources each of which refers to a zipped bitstream package.
      module ZippedResourceList
        def resources=(value)
          super
          resources.each do |r|
            class << r
              prepend ZippedResource
            end
          end
        end

        # A list (downloaded lazily) of the {Resync::Client::Zip::ZipPackage}s for each resource
        # @return [Resync::Client::Zip::ZipPackages] the zip packages for each resource
        def zip_packages
          @zip_packages ||= Resync::Client::Zip::ZipPackages.new(resources)
        end
      end
    end
  end
end
