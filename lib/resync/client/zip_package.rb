require 'rexml/document'
require 'zip'
require_relative 'bitstream'

module Resync
  # A ZIP package of resources or changes.
  class ZipPackage

    attr_accessor :zipfile

    def initialize(zipfile)
      self.zipfile = zipfile
    end

    def manifest
      unless @manifest
        manifest_entry = @zipfile.find_entry('manifest.xml')
        fail "No manifest.xml found in zipfile #{@zipfile.name}" unless manifest_entry
        manifest_stream = manifest_entry.get_input_stream
        @manifest = XMLParser.parse(manifest_stream)
      end
      @manifest
    end

    def bitstream_for(resource)
      Bitstream.new(zipfile: @zipfile, resource: resource)
    end

    def bitstreams
      manifest.resources.map { |r| bitstream_for(r) }
    end

    private

    def zipfile=(value)
      if value.is_a?(Zip::File)
        @zipfile = value
      else
        @zipfile = Zip::File.open(value)
      end
    end
  end
end
