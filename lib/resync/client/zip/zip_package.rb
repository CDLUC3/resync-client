require 'zip'
require 'resync'
require_relative '../../extensions'
require_relative 'bitstream'

module Resync
  class Client
    module Zip
      # A ZIP package of resources or changes, providing access to individual
      # bitstreams based on the included manifest file.
      class ZipPackage

        # ------------------------------------------------------------
        # Attributes

        # @return [::Zip::File] the ZIP file wrapped by this package
        attr_reader :zipfile

        # Gets the manifest for the ZIP package. Resources in the manifest
        # are each decorated with a +bitstream+ method that returns the
        # bitstream for that resource.
        # @return [ResourceDumpManifest, ChangeDumpManifest] the manifest
        #   for the ZIP package
        attr_reader :manifest

        # ------------------------------------------------------------
        # Initializer

        # Creates a new +ZipPackage+ for the specified file.
        #
        # @param zipfile [::Zip::File, String] the ZIP file, or a path to it.
        def initialize(zipfile)
          self.zipfile = zipfile
          @bitstreams = {}
        end

        # ------------------------------------------------------------
        # Public methods

        # Gets the bitstream for the specified resource. (Note that this
        # does no validation; if the resource is not in the manifest, or
        # the corresponding entry is not in the ZIP file, the behavior of
        # the returned {Bitstream} is undefined.)
        #
        # @return [Bitstream] a bitstream wrapping the ZIP entry for the
        #   specified resource.
        def bitstream_for(resource)
          @bitstreams[resource] ||= Bitstream.new(zipfile: @zipfile, resource: resource)
        end

        # Gets all bitstreams declared in the package manifest.
        # @return [Array<Bitstream>] a list of all bitstreams in the package
        def bitstreams
          manifest.resources.to_a.map { |r| bitstream_for(r) }
        end

        # ------------------------------------------------------------
        # Private methods

        private

        def manifest=(value)
          @manifest = value
          manifest.zip_package = self
        end

        def zipfile=(value)
          @zipfile = value.is_a?(::Zip::File) ? value : ::Zip::File.open(value)
          manifest_entry = zipfile.find_entry('manifest.xml')
          fail "No manifest.xml found in zipfile #{zipfile.name}" unless manifest_entry
          manifest_stream = manifest_entry.get_input_stream
          self.manifest = XMLParser.parse(manifest_stream)
        end

      end
    end
  end
end
