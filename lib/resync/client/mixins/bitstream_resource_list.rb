require 'resync/client/zip'
require_relative 'bitstream_resource'

# A list of resources within a single zipped bitstream package, e.g. as provided
# by the package manifest.
#
# @!attribute [rw] zip_package
#   @return [ZipPackage] the package.
module Resync
  class Client
    module Mixins
      module BitstreamResourceList
        attr_accessor :zip_package

        # Makes each provided resource a {BitstreamResource}
        # @param value [Array<Resource>] the resources for this list
        def resources=(value)
          super
          resources.each do |r|
            class << r
              prepend BitstreamResource
            end
            r.zip_package_delegate = self
          end
        end
      end
    end
  end
end
