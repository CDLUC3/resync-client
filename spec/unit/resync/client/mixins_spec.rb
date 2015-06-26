require 'spec_helper'

module Resync

  # TODO: Share examples
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

    describe ResourceList do
      describe '#all_resources' do
        it 'delegates to #resources, but lazily' do
          resources = Array.new(3) do
            resource = instance_double(Resource)
            allow(resource).to receive(:client_delegate=)
            resource
          end
          list = ResourceList.new(resources: resources)
          all_resources = list.all_resources
          expect(all_resources.to_a).to eq(list.resources)
          expect(all_resources).to be_a(Enumerator::Lazy)
        end
      end
    end

    describe ChangeList do
      describe '#all_resources' do
        it 'delegates to #resources, but lazily' do
          resources = []
          resources[0] = Resource.new(uri: 'http://example.org/', modified_time: Time.utc(1999, 1, 1))
          resources[1] = Resource.new(uri: 'http://example.org/', modified_time: Time.utc(2000, 1, 1))
          resources[2] = Resource.new(uri: 'http://example.org/', modified_time: Time.utc(2001, 3, 1))

          list = ChangeList.new(resources: resources)
          all_resources = list.all_resources
          expect(all_resources.to_a).to eq(list.resources)
          expect(all_resources).to be_a(Enumerator::Lazy)
        end
      end

      describe '#all_changes' do
        it 'delegates to #changes, lazily' do
          resources = []
          resources[0] = Resource.new(uri: 'http://example.org/', modified_time: Time.utc(1999, 1, 1), metadata: Metadata.new(change: Types::Change::CREATED))
          resources[1] = Resource.new(uri: 'http://example.org/', modified_time: Time.utc(2000, 1, 1), metadata: Metadata.new(change: Types::Change::CREATED))
          resources[2] = Resource.new(uri: 'http://example.org/', modified_time: Time.utc(1999, 3, 1), metadata: Metadata.new(change: Types::Change::UPDATED))
          resources[3] = Resource.new(uri: 'http://example.org/', modified_time: Time.utc(1999, 6, 1), metadata: Metadata.new(change: Types::Change::UPDATED))
          resources[4] = Resource.new(uri: 'http://example.org/', modified_time: Time.utc(2000, 3, 1), metadata: Metadata.new(change: Types::Change::UPDATED))
          resources[5] = Resource.new(uri: 'http://example.org/', modified_time: Time.utc(2000, 6, 1), metadata: Metadata.new(change: Types::Change::UPDATED))
          resources[6] = Resource.new(uri: 'http://example.org/', modified_time: Time.utc(1999, 9, 1), metadata: Metadata.new(change: Types::Change::DELETED))
          resources[7] = Resource.new(uri: 'http://example.org/', modified_time: Time.utc(2000, 9, 1), metadata: Metadata.new(change: Types::Change::DELETED))
          list = ChangeList.new(resources: resources)
          all_changes = list.all_changes(of_type: Types::Change::UPDATED, in_range: Time.utc(1999, 4, 1)..Time.utc(2000, 4, 1))
          expect(all_changes).to be_a(Enumerator::Lazy)
          expect(all_changes.to_a).to eq([resources[3], resources[4]])
        end
      end
    end

    describe BaseChangeIndex do
      before(:each) do
        @helper = instance_double(Client::HTTPHelper)
        @client = Client.new(helper: @helper)
      end

      describe '#all_changes' do
        it 'flattens the child changelists' do
          change_index_uri = URI('http://example.com/dataset1/changelist.xml')
          change_index_data = File.read('spec/data/examples/change-list-index.xml')
          expect(@helper).to receive(:fetch).with(uri: change_index_uri).and_return(change_index_data)

          list1_uri = URI('http://example.com/20130101-changelist.xml')
          list1_data = File.read('spec/data/examples/change-list-1.xml')
          expect(@helper).to receive(:fetch).with(uri: list1_uri).and_return(list1_data)

          list2_uri = URI('http://example.com/20130102-changelist.xml')
          list2_data = File.read('spec/data/examples/change-list-2.xml')
          expect(@helper).to receive(:fetch).with(uri: list2_uri).and_return(list2_data)

          list3_uri = URI('http://example.com/20130103-changelist.xml')
          list3_data = File.read('spec/data/examples/change-list-3.xml')
          expect(@helper).to receive(:fetch).with(uri: list3_uri).and_return(list3_data)

          expected_mtimes = [
            Time.utc(2013, 1, 1, 1),
            Time.utc(2013, 1, 1, 23),
            Time.utc(2013, 1, 2, 1),
            Time.utc(2013, 1, 2, 23),
            Time.utc(2013, 1, 3, 1)
          ]

          change_index = @client.get_and_parse(change_index_uri)
          index = 0
          change_index.all_changes(in_range: (Time.utc(0)..Time.new)).each do |c|
            res = index.even? ? 1 : 2
            expect(c.uri).to eq(URI("http://example.com/res#{res}"))
            expect(c.modified_time).to be_time(expected_mtimes[index])
            index += 1
          end
          expect(index).to eq(5)
        end

        it 'doesn\'t download unnecessary changelists' do
          change_index_uri = URI('http://example.com/dataset1/changelist.xml')
          change_index_data = File.read('spec/data/examples/change-list-index.xml')
          expect(@helper).to receive(:fetch).with(uri: change_index_uri).and_return(change_index_data)

          list2_uri = URI('http://example.com/20130102-changelist.xml')
          list2_data = File.read('spec/data/examples/change-list-2.xml')
          expect(@helper).to receive(:fetch).with(uri: list2_uri).and_return(list2_data)

          list3_uri = URI('http://example.com/20130103-changelist.xml')
          list3_data = File.read('spec/data/examples/change-list-3.xml')
          expect(@helper).to receive(:fetch).with(uri: list3_uri).and_return(list3_data)

          change_index = @client.get_and_parse(change_index_uri)
          count = 0
          change_index.all_changes(in_range: (Time.utc(2013, 1, 2, 12)..Time.utc(2013, 1, 3, 0, 30))).each do |c|
            expect(c.modified_time).to be_time(Time.utc(2013, 1, 2, 23))
            expect(c.uri).to eq(URI('http://example.com/res2'))
            count += 1
          end
          expect(count).to eq(1)
        end

        it 'is lazy when unfiltered' do
          change_index_uri = URI('http://example.com/dataset1/changelist.xml')
          change_index_data = File.read('spec/data/examples/change-list-index.xml')
          expect(@helper).to receive(:fetch).with(uri: change_index_uri).and_return(change_index_data)

          list2_uri = URI('http://example.com/20130102-changelist.xml')
          expect(@helper).not_to receive(:fetch).with(uri: list2_uri)

          list3_uri = URI('http://example.com/20130103-changelist.xml')
          expect(@helper).not_to receive(:fetch).with(uri: list3_uri)

          change_index = @client.get_and_parse(change_index_uri)
          all_changes = change_index.all_changes
          expect(all_changes).to be_a(Enumerator::Lazy)
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
    end

    describe Resource do
      describe '#get_and_parse' do
        it 'gets the resource using the injected client' do
          client = instance_double(Resync::Client)
          resource = instance_double(Resync::ResourceList)
          @list.client = client
          expect(client).to receive(:get_and_parse).with(@resources[0].uri) { resource }
          expect(@resources[0].get_and_parse).to be(resource)
        end

        it 'caches the downloaded contents' do
          client = instance_double(Resync::Client)
          resource = instance_double(Resync::ResourceList)
          @list.client = client
          expect(client).to receive(:get_and_parse).once.with(@resources[0].uri) { resource }
          expect(@resources[0].get_and_parse).to be(@resources[0].get_and_parse)
        end
      end

      describe '#get' do
        it 'gets the resource contents using the injected client' do
          data = 'I am the contents of a resource'
          client = instance_double(Resync::Client)
          @list.client = client
          expect(client).to receive(:get).with(@resources[0].uri) { data }
          expect(@resources[0].get).to be(data)
        end

        it 'caches the downloaded contents' do
          data = 'I am the contents of a resource'
          client = instance_double(Resync::Client)
          @list.client = client
          expect(client).to receive(:get).once.with(@resources[0].uri) { data }
          expect(@resources[0].get).to be(@resources[0].get)
        end
      end

      describe '#download_to_temp_file' do
        it 'downloads the resource contents to a file using the injected client' do
          path = '/tmp/whatever.zip'
          client = instance_double(Resync::Client)
          @list.client = client
          expect(client).to receive(:download_to_temp_file).with(@resources[0].uri) { path }
          expect(@resources[0].download_to_temp_file).to be(path)
        end

        it 'downloads anew each time' do
          path1 = '/tmp/whatever1.zip'
          path2 = '/tmp/whatever2.zip'
          client = instance_double(Resync::Client)
          @list.client = client
          expect(client).to receive(:download_to_temp_file).twice.with(@resources[0].uri).and_return(path1, path2)
          expect(@resources[0].download_to_temp_file).to eq(path1)
          expect(@resources[0].download_to_temp_file).to eq(path2)
        end
      end

      describe '#download_to_file' do
        it 'delegates to the injected client' do
          path = '/tmp/whatever.zip'
          client = instance_double(Resync::Client)
          @list.client = client
          expect(client).to receive(:download_to_file).with(uri: @resources[0].uri, path: path) { path }
          expect(@resources[0].download_to_file(path)).to be(path)
        end

        it 'downloads anew each time' do
          path = '/tmp/whatever.zip'
          client = instance_double(Resync::Client)
          @list.client = client
          expect(client).to receive(:download_to_file).twice.with(uri: @resources[0].uri, path: path) { path }
          expect(@resources[0].download_to_file(path)).to eq(@resources[0].download_to_file(path))
        end
      end
    end

    describe Link do
      describe '#get_and_parse' do
        it 'gets the link using the injected client' do
          client = instance_double(Resync::Client)
          resource = instance_double(Resync::ResourceList)
          @list.client = client
          expect(client).to receive(:get_and_parse).with(@links[0].uri) { resource }
          expect(@links[0].get_and_parse).to be(resource)
        end

        it 'caches the downloaded contents' do
          client = instance_double(Resync::Client)
          resource = instance_double(Resync::ResourceList)
          @list.client = client
          expect(client).to receive(:get_and_parse).once.with(@links[0].uri) { resource }
          expect(@links[0].get_and_parse).to be(@links[0].get_and_parse)
        end
      end

      describe '#get' do
        it 'gets the link contents using the injected client' do
          data = 'I am the contents of a link'
          client = instance_double(Resync::Client)
          @list.client = client
          expect(client).to receive(:get).with(@links[0].uri) { data }
          expect(@links[0].get).to be(data)
        end

        it 'caches the downloaded contents' do
          data = 'I am the contents of a link'
          client = instance_double(Resync::Client)
          @list.client = client
          expect(client).to receive(:get).once.with(@links[0].uri) { data }
          expect(@links[0].get).to be(@links[0].get)
        end
      end

      describe '#download_to_temp_file' do
        it 'downloads the link contents to a file using the injected client' do
          path = '/tmp/whatever1.zip'
          client = instance_double(Resync::Client)
          @list.client = client
          expect(client).to receive(:download_to_temp_file).with(@links[0].uri) { path }
          expect(@links[0].download_to_temp_file).to be(path)
        end
      end

      describe '#download_to_file' do
        it 'delegates to the injected client' do
          path = '/tmp/whatever.zip'
          client = instance_double(Resync::Client)
          @list.client = client
          expect(client).to receive(:download_to_file).with(uri: @links[0].uri, path: path) { path }
          expect(@links[0].download_to_file(path)).to be(path)
        end
      end
    end
  end
end
