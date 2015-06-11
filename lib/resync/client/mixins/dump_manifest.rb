require 'resync'
require_relative '../zip'
require_relative 'bitstream_resource'

module Resync
  class Client
    module Mixins
      # A list of resources within a single zipped bitstream package, e.g. as provided
      # by the package manifest.
      #
      # @!attribute [rw] zip_package
      #   @return [ZipPackage] the package.
      module DumpManifest
        attr_accessor :zip_package

        # Makes each provided resource a {BitstreamResource}
        # @param value [Array<Resource>] the resources for this list
        def resources=(value)
          super
          resources.each do |r|
            unless r.respond_to?(:bitstream) && r.respond_to?(:containing_package)
              class << r
                prepend BitstreamResource
              end
            end
            r.zip_package_delegate = self
          end
        end
      end
    end
  end

  class ResourceDumpManifest
    prepend Client::Mixins::DumpManifest
  end

  class ChangeDumpManifest
    prepend Client::Mixins::DumpManifest
  end
end
