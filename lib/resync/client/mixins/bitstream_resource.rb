require 'resync/client/zip'

# A resource that refers to a bitsream within a zipped bitstream package.
#
# @!attribute [rw] zip_package_delegate
#   @return [ZipPackage] the provider of the containing package,
#   e.g. its manifest
module Resync
  class Client
    module Mixins
      module BitstreamResource
        attr_accessor :zip_package_delegate

        # @return [ZipPackage] the package containing the bitstream for this resource
        def containing_package
          @zip_package_delegate.zip_package
        end

        # @return [Bitstream] the bitstream for this resource
        def bitstream
          containing_package.bitstream_for(self)
        end
      end
    end
  end
end
