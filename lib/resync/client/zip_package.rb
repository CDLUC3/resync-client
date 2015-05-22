require 'rexml/document'
require 'zip'

module Resync
  # A ZIP package of resources or changes.
  class ZipPackage

    attr_accessor :zipfile

    def initialize(zipfile:)
      self.zipfile = zipfile
    end

    def manifest
      unless @manifest
        manifest_entry = @zipfile.find_entry('manifest.xml')
        fail "No manifest.xml found in zipfile #{@zipfile.name}" unless manifest_entry
        manifest_stream = manifest_entry.get_input_stream
        @manifest = XMLParser.parse(xml: manifest_stream)
      end
      @manifest
    end

    def bitstreams
      manifest.resources.map { |r| to_stream(r) }
    end

    private

    def to_stream(resource)
      Bitstream.new(zipfile: @zipfile, resource: resource)
    end

    def zipfile=(value)
      if value.is_a?(Zip::File)
        @zipfile = value
      else
        @zipfile = Zip::File.open(value)
      end
    end
  end

  # A single entry in a ZIP package.
  class Bitstream

    attr_accessor :path
    attr_accessor :resource

    def initialize(zipfile:, resource:)
      @resource = resource
      self.metadata = resource.metadata
      self.path = @metadata.path
      @zip_entry = zipfile.find_entry(@path)
    end

    def size
      @zip_entry.size
    end

    def stream
      @zip_entry.get_input_stream
    end

    def content
      stream.read
    end

    private

    def metadata=(value)
      fail 'no metadata found' unless value
      @metadata = value
    end

    def path=(value)
      fail 'no path found in metadata' unless value
      @path = value.start_with?('/') ? value.slice(1..-1) : value
    end

  end
end
