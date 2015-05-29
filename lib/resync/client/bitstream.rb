module Resync

  # A single entry in a ZIP package.
  class Bitstream

    attr_reader :path
    attr_reader :resource
    attr_reader :metadata

    def initialize(zipfile:, resource:)
      self.resource = resource
      @zip_entry = zipfile.find_entry(@path)
    end

    def size
      @size ||= @zip_entry.size
    end

    def stream
      @stream ||= @zip_entry.get_input_stream
    end

    def content
      @content ||= stream.read
    end

    def mime_type
      @mime_type ||= metadata.mime_type
    end

    private

    def resource=(value)
      fail ArgumentError, 'nil is not a resource' unless value
      self.metadata = value.metadata
      @resource = value
    end

    def metadata=(value)
      fail 'no metadata found' unless value
      self.path = value.path
      @metadata = value
    end

    def path=(value)
      fail 'no path found in metadata' unless value
      @path = value.start_with?('/') ? value.slice(1..-1) : value
    end

  end

end
