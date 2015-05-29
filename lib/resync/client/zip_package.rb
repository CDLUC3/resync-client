require 'rexml/document'
require 'zip'
require_relative 'bitstream'

module Resync
  # A ZIP package of resources or changes, providing access to individual
  # bitstreams based on the included manifest file.
  #
  # @!attribute [r] zipfile
  #   @return [Zip::File] the ZIP file wrapped by this package
  # @!attribute [r] manifest
  #   @return [ResourceDumpManifest, ChangeDumpManifest] the manifest
  #     for the ZIP package
  class ZipPackage

    attr_reader :zipfile
    attr_reader :manifest

    # Creates a new +ZipPackage+ for the specified file.
    #
    # @param zipfile [Zip::File, String] the ZIP file, or a path to it.
    def initialize(zipfile)
      self.zipfile = zipfile
    end

    # Gets the bitstream for the specified resource. (Note that this
    # does no validation; if the resource is not in the manifest, or
    # the corresponding entry is not in the ZIP file, the behavior of
    # the returned {Bitstream} is undefined.)
    #
    # @return [Bitstream] a bitstream wrapping the ZIP entry for the
    #   specified resource.
    def bitstream_for(resource)
      Bitstream.new(zipfile: @zipfile, resource: resource)
    end

    # Gets all bitstreams declared in the package manifest.
    # @return [Array<Bitstream>] a list of all bitstreams in the package
    def bitstreams
      manifest.resources.map { |r| bitstream_for(r) }
    end

    private

    def zipfile=(value)
      zipfile = value.is_a?(Zip::File) ? value : Zip::File.open(value)
      manifest_entry = zipfile.find_entry('manifest.xml')
      fail "No manifest.xml found in zipfile #{zipfile.name}" unless manifest_entry
      manifest_stream = manifest_entry.get_input_stream
      @manifest = XMLParser.parse(manifest_stream)
      @zipfile = zipfile
    end

  end
end
