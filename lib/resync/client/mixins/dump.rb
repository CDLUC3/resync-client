require 'resync'
require 'lazy'
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
        # @return [Array<Lazy::Promise<Resync::Client::Zip::ZipPackage>>] the zip packages for each resource
        def zip_packages
          @zip_packages ||= resources.map { |r| Lazy.promise { r.zip_package } }
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
    include Client::Mixins::Dump

    # A list (downloaded lazily) of the {Resync::Client::Zip::ZipPackage}s for each resource
    # @return [Array<Lazy::Promise<Resync::Client::Zip::ZipPackage>>] the zip packages for each resource
    def zip_packages(in_range: nil)
      if in_range
        change_lists = change_lists(in_range: in_range, strict: false)
        change_lists.map { |r| Lazy.promise { r.zip_package } }
      else
        super()
      end
    end

    alias_method :all_zip_packages, :zip_packages
  end
end
