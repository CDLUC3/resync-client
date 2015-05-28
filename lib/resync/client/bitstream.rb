module Resync

  # A single entry in a ZIP package.
  class Bitstream

    attr_accessor :path
    attr_accessor :resource
    attr_accessor :metadata

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

    def mime_type
      metadata.mime_type
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
