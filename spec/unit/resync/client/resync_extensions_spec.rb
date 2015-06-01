require 'spec_helper'

module Resync
  describe 'extensions' do

    # ------------------------------------------------------------
    # Fixture

    before(:each) do
      @resources = [
        Resource.new(uri: 'http://example.com/dataset1/resourcelist.xml', metadata: Metadata.new(capability: 'resourcelist')),
        Resource.new(uri: 'http://example.com/dataset1/resourcedump.xml', metadata: Metadata.new(capability: 'resourcedump')),
        Resource.new(uri: 'http://example.com/dataset1/changelist.xml', metadata: Metadata.new(capability: 'changelist')),
        Resource.new(uri: 'http://example.com/dataset1/changedump.xml', metadata: Metadata.new(capability: 'changedump'))
      ]
      @links = [
        Link.new(rel: 'describedby', uri: 'http://example.org/desc1'),
        Link.new(rel: 'duplicate', uri: 'http://example.com/dup1'),
        Link.new(rel: 'describedby', uri: 'http://example.org/desc2'),
        Link.new(rel: 'duplicate', uri: 'http://example.com/dup2')
      ]
      @list = ResourceList.new(resources: @resources, links: @links)
    end

    # ------------------------------------------------------------
    # Tests

    describe BaseResourceList do

      it 'proxies all resource client requests to its own client' do
        client = instance_double(Resync::Client)
        @list.client = client
        @resources.each do |r|
          expect(r.client).to be(client)
        end
        client2 = instance_double(Resync::Client)
        @list.client = client2
        @resources.each do |r|
          expect(r.client).to be(client2)
        end
      end
    end

    describe Augmented do
      it 'proxies all link client requests to its own client' do
        client = instance_double(Resync::Client)
        @list.client = client
        @links.each do |l|
          expect(l.client).to be(client)
        end
        client2 = instance_double(Resync::Client)
        @list.client = client2
        @links.each do |l|
          expect(l.client).to be(client2)
        end
      end

      it 'defaults to a new client' do
        client = instance_double(Resync::Client)
        expect(Resync::Client).to receive(:new) { client }
        expect(@list.client).to be(client)
      end
    end

    describe Resource do
      describe '#get' do
        it 'gets the resource using the injected client' do
          client = instance_double(Resync::Client)
          resource = instance_double(Resync::ResourceList)
          @list.client = client
          expect(client).to receive(:get_and_parse).with(@resources[0].uri) { resource }
          expect(@resources[0].get_and_parse).to be(resource)
        end
      end

      describe '#get_raw' do
        it 'gets the resource contents using the injected client' do
          data = 'I am the contents of a resource'
          client = instance_double(Resync::Client)
          @list.client = client
          expect(client).to receive(:get).with(@resources[0].uri) { data }
          expect(@resources[0].get).to be(data)
        end
      end

      describe '#get_file' do
        it 'downloads the resource contents to a file using the injected client' do
          path = '/tmp/whatever.zip'
          client = instance_double(Resync::Client)
          @list.client = client
          expect(client).to receive(:download_to_temp_file).with(@resources[0].uri) { path }
          expect(@resources[0].download_to_temp_file).to be(path)
        end
      end
    end

    describe Link do
      describe '#get' do
        it 'gets the link using the injected client' do
          client = instance_double(Resync::Client)
          resource = instance_double(Resync::ResourceList)
          @list.client = client
          expect(client).to receive(:get_and_parse).with(@links[0].uri) { resource }
          expect(@links[0].get_and_parse).to be(resource)
        end
      end

      describe '#get_raw' do
        it 'gets the link contents using the injected client' do
          data = 'I am the contents of a link'
          client = instance_double(Resync::Client)
          @list.client = client
          expect(client).to receive(:get).with(@links[0].uri) { data }
          expect(@links[0].get).to be(data)
        end
      end

      describe '#get_file' do
        it 'downloads the link contents to a file using the injected client' do
          path = '/tmp/whatever.zip'
          client = instance_double(Resync::Client)
          @list.client = client
          expect(client).to receive(:download_to_temp_file).with(@links[0].uri) { path }
          expect(@links[0].download_to_temp_file).to be(path)
        end
      end
    end
  end
end
