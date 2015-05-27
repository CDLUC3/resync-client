require 'spec_helper'

module Resync
  describe Client do
    before(:each) do
      @connection = instance_double(Faraday::Connection)
      @response = instance_double(Faraday::Response)
      @client = Client.new(connection: @connection)
    end

    it 'handles file:// URIs'
    it 'handles http URIs'
    it 'handles https URIs'

    describe '#get' do
      it 'retrieves a CapabilityList' do
        uri = URI('http://example.org/capability-list.xml')
        data = File.read('spec/data/examples/capability-list.xml')
        expect(@response).to receive(:body) { data }
        expect(@connection).to receive(:get).with('http://example.org/capability-list.xml') { @response }
        doc = @client.get(uri)
        expect(doc).to be_a(Resync::CapabilityList)
      end

      it 'retrieves a ChangeDump' do
        uri = URI('http://example.org/change-dump.xml')
        data = File.read('spec/data/examples/change-dump.xml')
        expect(@response).to receive(:body) { data }
        expect(@connection).to receive(:get).with('http://example.org/change-dump.xml') { @response }
        doc = @client.get(uri)
        expect(doc).to be_a(Resync::ChangeDump)
      end

      it 'retrieves a ChangeDumpManifest' do
        uri = URI('http://example.org/change-dump-manifest.xml')
        data = File.read('spec/data/examples/change-dump-manifest.xml')
        expect(@response).to receive(:body) { data }
        expect(@connection).to receive(:get).with('http://example.org/change-dump-manifest.xml') { @response }
        doc = @client.get(uri)
        expect(doc).to be_a(Resync::ChangeDumpManifest)
      end

      it 'retrieves a ChangeList' do
        uri = URI('http://example.org/change-list.xml')
        data = File.read('spec/data/examples/change-list.xml')
        expect(@response).to receive(:body) { data }
        expect(@connection).to receive(:get).with('http://example.org/change-list.xml') { @response }
        doc = @client.get(uri)
        expect(doc).to be_a(Resync::ChangeList)
      end

      it 'retrieves a ResourceDump' do
        uri = URI('http://example.org/resource-dump.xml')
        data = File.read('spec/data/examples/resource-dump.xml')
        expect(@response).to receive(:body) { data }
        expect(@connection).to receive(:get).with('http://example.org/resource-dump.xml') { @response }
        doc = @client.get(uri)
        expect(doc).to be_a(Resync::ResourceDump)
      end

      it 'retrieves a ResourceDumpManifest' do
        uri = URI('http://example.org/resource-dump-manifest.xml')
        data = File.read('spec/data/examples/resource-dump-manifest.xml')
        expect(@response).to receive(:body) { data }
        expect(@connection).to receive(:get).with('http://example.org/resource-dump-manifest.xml') { @response }
        doc = @client.get(uri)
        expect(doc).to be_a(Resync::ResourceDumpManifest)
      end

      it 'retrieves a ResourceList' do
        uri = URI('http://example.org/resource-list.xml')
        data = File.read('spec/data/examples/resource-list.xml')
        expect(@response).to receive(:body) { data }
        expect(@connection).to receive(:get).with('http://example.org/resource-list.xml') { @response }
        doc = @client.get(uri)
        expect(doc).to be_a(Resync::ResourceList)
      end

      it 'retrieves a SourceDescription' do
        uri = URI('http://example.org/source-description.xml')
        data = File.read('spec/data/examples/source-description.xml')
        expect(@response).to receive(:body) { data }
        expect(@connection).to receive(:get).with('http://example.org/source-description.xml') { @response }
        doc = @client.get(uri)
        expect(doc).to be_a(Resync::SourceDescription)
      end

      it 'retrieves a ChangeListIndex' do
        uri = URI('http://example.org/change-list-index.xml')
        data = File.read('spec/data/examples/change-list-index.xml')
        expect(@response).to receive(:body) { data }
        expect(@connection).to receive(:get).with('http://example.org/change-list-index.xml') { @response }
        doc = @client.get(uri)
        expect(doc).to be_a(Resync::ChangeListIndex)
      end

      it 'retrieves a ResourceListIndex' do
        uri = URI('http://example.org/resource-list-index.xml')
        data = File.read('spec/data/examples/resource-list-index.xml')
        expect(@response).to receive(:body) { data }
        expect(@connection).to receive(:get).with('http://example.org/resource-list-index.xml') { @response }
        doc = @client.get(uri)
        expect(doc).to be_a(Resync::ResourceListIndex)
      end

      it 'injects the client into the returned document' do
        uri = URI('http://example.org/resource-list-index.xml')
        data = File.read('spec/data/examples/resource-list-index.xml')
        expect(@response).to receive(:body) { data }
        expect(@connection).to receive(:get).with('http://example.org/resource-list-index.xml') { @response }
        doc = @client.get(uri)
        expect(doc.client).to be(@client)
      end
    end

    describe '#new' do
      it 'creates its own connection if none is provided' do
        data = File.read('spec/data/examples/capability-list.xml')
        expect(Faraday).to receive(:new).and_return(@connection)
        expect(@response).to receive(:body) { data }
        expect(@connection).to receive(:get).with('http://example.org/capability-list.xml') { @response }
        client = Client.new
        client.get(URI('http://example.org/capability-list.xml'))
      end
    end

  end
end
