require 'resync'
require_relative '../zip'
require_relative 'zipped_resource'

module Resync
  class Client
    module Mixins
      # A list of resources each of which refers to a zipped bitstream package.
      module Dump
        def resources=(value)
          super
          resources.each do |r|
            next if r.respond_to?(:zip_package)
            class << r
              prepend ZippedResource
            end
          end
        end

        # A list (downloaded lazily) of the {Resync::Client::Zip::ZipPackage}s for each resource
        # @return [Resync::Client::Zip::ZipPackages] the zip packages for each resource
        def zip_packages
          @zip_packages ||= {}
          resources.map do |r|
            @zip_packages[r] ||= r.zip_package
          end
        end

        # Aliases +:zip_packages+ as +:all_zip_packages+ for transparent
        # interoperability between +ResourceDump+ and +ResourceDumpIndex+,
        # +ChangeDump+ and +ChangeDumpIndex+
        def self.prepended(ext)
          ext.send(:alias_method, :all_zip_packages, :zip_packages)
        end
      end
    end
  end

  class ResourceDump
    prepend Client::Mixins::Dump
  end

  class ChangeDump
    prepend Client::Mixins::Dump
  end
end
