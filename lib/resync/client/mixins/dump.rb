require 'resync'
require_relative '../zip'
require_relative 'zipped_resource'

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
        # @return [Enumerator#Lazy<Resync::Client::Zip::ZipPackage>] the zip packages for each resource
        def zip_packages
          @zip_packages ||= init_zip_packages
        end

        # Aliases +:zip_packages+ as +:all_zip_packages+ for transparent
        # interoperability between +ResourceDump+ and +ResourceDumpIndex+,
        # +ChangeDump+ and +ChangeDumpIndex+
        def self.prepended(ext)
          ext.send(:alias_method, :all_zip_packages, :zip_packages)
        end

        private

        def init_zip_packages
          zip_packages = self.resources.map do |r|
            package_for(r)
          end
          zip_packages.define_singleton_method(:[]) do |idx|
            package_for(self.resources[idx])
          end
          zip_packages
        end

        def package_for(r)
          (@cached_packages ||= {})[r] ||= r.zip_package
        end
      end
    end
  end

  class ResourceDump
    prepend Client::Mixins::Dump
  end

  class ChangeDump
    include Client::Mixins::Dump

    # A list (downloaded lazily) of the {Resync::Client::Zip::ZipPackage}s for each resource
    # @return [Resync::Client::Zip::ZipPackages] the zip packages for each resource
    def zip_packages(in_range: nil)
      if in_range
        change_lists = change_lists(in_range: in_range, strict: false)
        Resync::Client::Zip::ZipPackages.new(change_lists)
      else
        super()
        # @zip_packages ||= Resync::Client::Zip::ZipPackages.new(resources)
      end
    end

    alias_method :all_zip_packages, :zip_packages
  end
end


