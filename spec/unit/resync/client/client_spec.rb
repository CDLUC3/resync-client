require 'spec_helper'

module Resync
  describe Client do
    before(:each) do
      @helper = instance_double(Client::HTTPHelper)
      @client = Client.new(helper: @helper)
    end

    describe '#get' do
      it 'retrieves a CapabilityList' do
        uri = URI('http://example.org/capability-list.xml')
        data = File.read('spec/data/examples/capability-list.xml')
        expect(@helper).to receive(:fetch).with(uri: uri).and_return(data)
        doc = @client.get_and_parse(uri)
        expect(doc).to be_a(Resync::CapabilityList)
      end

      it 'retrieves a ChangeDump' do
        uri = URI('http://example.org/change-dump.xml')
        data = File.read('spec/data/examples/change-dump.xml')
        expect(@helper).to receive(:fetch).with(uri: uri).and_return(data)
        doc = @client.get_and_parse(uri)
        expect(doc).to be_a(Resync::ChangeDump)
      end

      it 'retrieves a ChangeDumpManifest' do
        uri = URI('http://example.org/change-dump-manifest.xml')
        data = File.read('spec/data/examples/change-dump-manifest.xml')
        expect(@helper).to receive(:fetch).with(uri: uri).and_return(data)
        doc = @client.get_and_parse(uri)
        expect(doc).to be_a(Resync::ChangeDumpManifest)
      end

      it 'retrieves a ChangeList' do
        uri = URI('http://example.org/change-list.xml')
        data = File.read('spec/data/examples/change-list.xml')
        expect(@helper).to receive(:fetch).with(uri: uri).and_return(data)
        doc = @client.get_and_parse(uri)
        expect(doc).to be_a(Resync::ChangeList)
      end

      it 'retrieves a ResourceDump' do
        uri = URI('http://example.org/resource-dump.xml')
        data = File.read('spec/data/examples/resource-dump.xml')
        expect(@helper).to receive(:fetch).with(uri: uri).and_return(data)
        doc = @client.get_and_parse(uri)
        expect(doc).to be_a(Resync::ResourceDump)
      end

      it 'retrieves a ResourceDumpManifest' do
        uri = URI('http://example.org/resource-dump-manifest.xml')
        data = File.read('spec/data/examples/resource-dump-manifest.xml')
        expect(@helper).to receive(:fetch).with(uri: uri).and_return(data)
        doc = @client.get_and_parse(uri)
        expect(doc).to be_a(Resync::ResourceDumpManifest)
      end

      it 'retrieves a ResourceList' do
        uri = URI('http://example.org/resource-list.xml')
        data = File.read('spec/data/examples/resource-list.xml')
        expect(@helper).to receive(:fetch).with(uri: uri).and_return(data)
        doc = @client.get_and_parse(uri)
        expect(doc).to be_a(Resync::ResourceList)
      end

      it 'retrieves a SourceDescription' do
        uri = URI('http://example.org/source-description.xml')
        data = File.read('spec/data/examples/source-description.xml')
        expect(@helper).to receive(:fetch).with(uri: uri).and_return(data)
        doc = @client.get_and_parse(uri)
        expect(doc).to be_a(Resync::SourceDescription)
      end

      it 'retrieves a ChangeListIndex' do
        uri = URI('http://example.org/change-list-index.xml')
        data = File.read('spec/data/examples/change-list-index.xml')
        expect(@helper).to receive(:fetch).with(uri: uri).and_return(data)
        doc = @client.get_and_parse(uri)
        expect(doc).to be_a(Resync::ChangeListIndex)
      end

      it 'retrieves a ResourceListIndex' do
        uri = URI('http://example.org/resource-list-index.xml')
        data = File.read('spec/data/examples/resource-list-index.xml')
        expect(@helper).to receive(:fetch).with(uri: uri).and_return(data)
        doc = @client.get_and_parse(uri)
        expect(doc).to be_a(Resync::ResourceListIndex)
      end

      it 'injects the client into the returned document' do
        uri = URI('http://example.org/resource-list-index.xml')
        data = File.read('spec/data/examples/resource-list-index.xml')
        expect(@helper).to receive(:fetch).with(uri: uri).and_return(data)
        doc = @client.get_and_parse(uri)
        expect(doc.client).to be(@client)
      end

      it 'injects the client recursively' do
        uri = URI('http://example.org/resource-list-index.xml')
        data = File.read('spec/data/examples/resource-list-index.xml')
        resource_list_xml = File.read('spec/data/examples/resource-list.xml')
        expect(@helper).to receive(:fetch).with(uri: uri).and_return(data)
        doc = @client.get_and_parse(uri)
        doc.resources.each do |r|
          expect(r.client).to be(@client)
          expect(@helper).to receive(:fetch).with(uri: r.uri).and_return(resource_list_xml)
          resource_doc = r.get_and_parse
          expect(resource_doc.client).to be(@client)
          resource_doc.resources.each do |r2|
            expect(r2.client).to be(@client)
          end
        end
      end
    end

    describe '#new' do
      it 'creates its own connection if none is provided' do
        uri = URI('http://example.org/capability-list.xml')
        data = File.read('spec/data/examples/capability-list.xml')
        expect(Client::HTTPHelper).to receive(:new).and_return(@helper)
        expect(@helper).to receive(:fetch).with(uri: uri).and_return(data)
        client = Client.new
        client.get_and_parse(uri)
      end
    end

    describe '#download_to_temp_file' do
      it 'delegates to the helper' do
        uri = 'http://example.org/capability-list.xml'
        path = '/tmp/whatever.zip'
        expect(@helper).to receive(:fetch_to_file).with(uri: URI(uri)).and_return(path)
        expect(@client.download_to_temp_file(uri)).to eq(path)
      end
    end

    describe '#download_to_file' do
      it 'delegates to the helper' do
        uri = 'http://example.org/capability-list.xml'
        path = '/tmp/whatever.zip'
        expect(@helper).to receive(:fetch_to_file).with(uri: URI(uri), path: path).and_return(path)
        expect(@client.download_to_file(uri: uri, path: path)).to eq(path)
      end
    end

    describe 'example.rb' do
      it 'works' do
        fail 'figure out why example.rb isn\'t working'
      end

    end
  end
end
