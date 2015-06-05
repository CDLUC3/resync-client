require 'resync'
require 'resync/extensions'
require_relative 'zip_package'

module Resync
  class Client
    module Zip
      # Lazily retrieves and caches the zip packages for the specified
      # list of resources. The packages are cached to temporary files
      # which are deleted on exit; if they are deleted while the
      # interpreter is running, the behavior is undefined (but bad things
      # are likely to happen).
      class ZipPackages
        include Enumerable

        # Creates a new {ZipPackages} wrapper for the specified list
        # of resources.
        # @param resources [Array<Resource>] The list of resources to
        #   get zip packages for.
        def initialize(resources)
          @resources = resources
          @packages = {}
        end

        # Gets the size of this list of packages.
        # @return the size of the underlying array.
        def size
          @resources.size
        end

        # Gets the zip package at the specified index, downloading it
        # if necessary.
        #
        # @return [ZipPackage] the zip package for the resource at the
        #   specified index in the underlying array.
        def [](key)
          resource = @resources[key]
          package_for(resource)
        end

        # Gets the zip package for the specified resource, downloading it
        # if necessary.
        # @return [ZipPackage] the package for the resource
        def package_for(resource)
          @packages[resource] ||= resource.zip_package
        end

        # Lazily iterates the given block for each zip package, downloading
        # as necessary.
        # @param &block [Block] The block to iterate
        def each
          @resources.lazy.each do |resource|
            yield package_for(resource)
          end
        end
      end
    end
  end
end
