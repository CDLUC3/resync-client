require 'resync/client/zip'
require_relative 'downloadable'

# A resource that refers to a zipped bitstream package.
module Resync
  class Client
    module Mixins
      module ZippedResource
        prepend Downloadable

        # Provides the contents of this resource as a {ZipPackage}, downloading
        # it to a temporary file if necessary.
        # @return [ZipPackage] the zipped contents of this resource
        def zip_package
          @zip_package ||= Resync::Client::Zip::ZipPackage.new(download_to_temp_file)
        end
      end
    end
  end
end
