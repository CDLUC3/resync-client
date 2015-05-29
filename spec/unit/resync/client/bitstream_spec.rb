require 'spec_helper'
require 'mime/type'
require 'zip'

module Resync
  describe Bitstream do

    # ------------------------------------------------------------
    # Fixture

    before(:each) do
      @zipfile = instance_double(Zip::File)

      @metadata = instance_double(Metadata)
      @path = 'path/to/resource'
      allow(@metadata).to receive(:path).and_return(@path)

      @zip_entry = instance_double(Zip::Entry)
      allow(@zipfile).to receive(:find_entry).with(@path).and_return(@zip_entry)

      @resource = instance_double(Resource)
      allow(@resource).to receive(:metadata).and_return(@metadata)

      @bitstream = Bitstream.new(zipfile: @zipfile, resource: @resource)
    end

    # ------------------------------------------------------------
    # Tests

    describe '#new' do
      it 'requires a zipfile' do
        expect { Bitstream.new(resource: @resource) }.to raise_error
      end

      it 'requires a resource' do
        expect { Bitstream.new(zipfile: @zipfile) }.to raise_error
      end
    end

    describe '#size' do
      it 'returns the size of the zip entry' do
        expect(@zip_entry).to receive(:size).and_return(123)
        expect(@bitstream.size).to eq(123)
      end
    end

    describe '#stream' do
      it 'returns the input stream from the zip entry' do
        stream = instance_double(Zip::InputStream)
        expect(@zip_entry).to receive(:get_input_stream).and_return(stream)
        expect(@bitstream.stream).to be(stream)
      end

      it 'returns the same stream each time' do
        stream = instance_double(Zip::InputStream)
        expect(@zip_entry).to receive(:get_input_stream).and_return(stream)
        expect(@bitstream.stream).to be(stream)
        expect(@bitstream.stream).to be(stream)
      end
    end

    describe '#content' do
      it 'gets the content of the stream' do
        stream = instance_double(Zip::InputStream)
        content = 'I am the content of the zip stream'
        allow(stream).to receive(:read).and_return(content)
        expect(@zip_entry).to receive(:get_input_stream).and_return(stream)
        expect(@bitstream.content).to eq(content)
      end

      it 'gets the content of the stream only once' do
        stream = instance_double(Zip::InputStream)
        content = 'I am the content of the zip stream'
        allow(stream).to receive(:read).and_return(content)
        expect(@zip_entry).to receive(:get_input_stream).and_return(stream)
        expect(@bitstream.content).to eq(content)
        expect(@bitstream.content).to eq(content)
      end
    end

    describe '#mime_type' do
      it 'returns the MIME type of the metadata' do
        mime_type = instance_double(MIME::Type)
        allow(@metadata).to receive(:mime_type).and_return(mime_type)
        expect(@bitstream.mime_type).to be(mime_type)
      end
    end

  end
end