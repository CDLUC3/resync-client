require 'zip'
require 'resync'

module Resync
  class Client
    module Zip
      # A single entry in a ZIP package.
      class Bitstream

        # ------------------------------------------------------------
        # Attributes

        # @return [String] the path to the entry within the ZIP file
        attr_reader :path

        # @return [Resource] the resource describing this bitstream
        attr_reader :resource

        # @return [Metadata] the metadata for this bitstream
        attr_reader :metadata

        # ------------------------------------------------------------
        # Initializer

        # Creates a new bitstream for the specified resource.
        #
        # @param zipfile [::Zip::File] The zipfile to read the bitstream from.
        # @param resource [Resource] The resource describing the bitstream.
        def initialize(zipfile:, resource:)
          self.resource = resource
          @zip_entry = zipfile.find_entry(@path)
        end

        # ------------------------------------------------------------
        # Convenience accessors

        # The (uncompressed) size of the bitstream.
        def size
          @size ||= @zip_entry.size
        end

        # The bitstream, as an +IO+-like object. Subsequent
        # calls will return the same stream.
        def stream
          @stream ||= @zip_entry.get_input_stream
        end

        # The content of the bitstream. The content will be
        # read only once.
        def content
          @content ||= stream.read
        end

        # The content type of the bitstream, as per {#metadata}.
        def mime_type
          @mime_type ||= metadata.mime_type
        end

        # ------------------------------------------------------------
        # Private methods

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
  end
end
