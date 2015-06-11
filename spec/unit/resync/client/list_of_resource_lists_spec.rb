require 'spec_helper'

module Resync
  class Client
    module Mixins
      describe ListOfResourceLists do
        before(:each) do
          @helper = instance_double(Client::HTTPHelper)
          @client = Client.new(helper: @helper)
        end

        describe '#all_resources' do
          it 'flattens the child resourcelists' do
            cap_list_uri = URI('http://example.com/capabilitylist.xml')
            cap_list_data = File.read('spec/data/examples/capability-list.xml')
            expect(@helper).to receive(:fetch).with(uri: cap_list_uri).and_return(cap_list_data)

            resourcelist_uri = URI('http://example.com/dataset1/resourcelist.xml')
            resourcelist_data = File.read('spec/data/examples/resource-list.xml')
            expect(@helper).to receive(:fetch).with(uri: resourcelist_uri).once.and_return(resourcelist_data)

            resourcedump_uri = URI('http://example.com/dataset1/resourcedump.xml')
            resourcedump_data = File.read('spec/data/examples/resource-dump.xml')
            expect(@helper).to receive(:fetch).with(uri: resourcedump_uri).once.and_return(resourcedump_data)

            changelist_uri = URI('http://example.com/dataset1/changelist.xml')
            changelist_data = File.read('spec/data/examples/change-list.xml')
            expect(@helper).to receive(:fetch).with(uri: changelist_uri).once.and_return(changelist_data)

            changedump_uri = URI('http://example.com/dataset1/changedump.xml')
            changedump_data = File.read('spec/data/examples/change-dump.xml')
            expect(@helper).to receive(:fetch).with(uri: changedump_uri).once.and_return(changedump_data)

            expected_uris = %w(http://example.com/res3
              http://example.com/res4
              http://example.com/resourcedump-part1.zip
              http://example.com/resourcedump-part2.zip
              http://example.com/resourcedump-part3.zip
              http://example.com/res4
              http://example.com/res5-full.tiff
              http://example.com/20130101-changedump.zip
              http://example.com/20130102-changedump.zip
              http://example.com/20130103-changedump.zip).map {|url| URI(url)}

            cap_list = @client.get_and_parse(cap_list_uri)
            all_resources = cap_list.all_resources.to_a
            expect(all_resources.size).to eq(expected_uris.size)
            all_resources.each_with_index do |r, index|
              expect(r.uri).to eq(expected_uris[index])
            end
          end

          it 'is lazy enough not to download anything till it \'s iterated ' do
            cap_list_uri = URI('http://example.com/capabilitylist.xml')
            cap_list_data = File.read('spec/data/examples/capability-list.xml')
            expect(@helper).to receive(:fetch).with(uri: cap_list_uri).and_return(cap_list_data)

            resourcelist_uri = URI('http://example.com/dataset1/resourcelist.xml')
            expect(@helper).not_to receive(:fetch).with(uri: resourcelist_uri)

            resourcedump_uri = URI('http://example.com/dataset1/resourcedump.xml')
            expect(@helper).not_to receive(:fetch).with(uri: resourcedump_uri)

            changelist_uri = URI('http://example.com/dataset1/changelist.xml')
            expect(@helper).not_to receive(:fetch).with(uri: changelist_uri)

            changedump_uri = URI('http://example.com/dataset1/changedump.xml')
            expect(@helper).not_to receive(:fetch).with(uri: changedump_uri)

            cap_list = @client.get_and_parse(cap_list_uri)
            cap_list.all_resources
          end

          it 'is lazy enough not to download resources it doesn \'t need' do
            cap_list_uri = URI('http://example.com/capabilitylist.xml')
            cap_list_data = File.read('spec/data/examples/capability-list.xml')
            expect(@helper).to receive(:fetch).with(uri: cap_list_uri).and_return(cap_list_data)

            resourcelist_uri = URI('http://example.com/dataset1/resourcelist.xml')
            resourcelist_data = File.read('spec/data/examples/resource-list.xml')
            expect(@helper).to receive(:fetch).with(uri: resourcelist_uri).once.and_return(resourcelist_data)

            resourcedump_uri = URI('http://example.com/dataset1/resourcedump.xml')
            resourcedump_data = File.read('spec/data/examples/resource-dump.xml')
            expect(@helper).to receive(:fetch).with(uri: resourcedump_uri).once.and_return(resourcedump_data)

            changelist_uri = URI('http://example.com/dataset1/changelist.xml')
            expect(@helper).not_to receive(:fetch).with(uri: changelist_uri)

            changedump_uri = URI('http://example.com/dataset1/changedump.xml')
            expect(@helper).not_to receive(:fetch).with(uri: changedump_uri)

            cap_list = @client.get_and_parse(cap_list_uri)
            cap_list.all_resources.each_with_index do |r, i|
              break if i >= 3
            end
          end

          it 'caches downloaded resources' do
            cap_list_uri = URI('http://example.com/capabilitylist.xml')
            cap_list_data = File.read('spec/data/examples/capability-list.xml')
            expect(@helper).to receive(:fetch).with(uri: cap_list_uri).and_return(cap_list_data)

            resourcelist_uri = URI('http://example.com/dataset1/resourcelist.xml')
            resourcelist_data = File.read('spec/data/examples/resource-list.xml')
            expect(@helper).to receive(:fetch).with(uri: resourcelist_uri).once.and_return(resourcelist_data)

            resourcedump_uri = URI('http://example.com/dataset1/resourcedump.xml')
            resourcedump_data = File.read('spec/data/examples/resource-dump.xml')
            expect(@helper).to receive(:fetch).with(uri: resourcedump_uri).once.and_return(resourcedump_data)

            changelist_uri = URI('http://example.com/dataset1/changelist.xml')
            changelist_data = File.read('spec/data/examples/change-list.xml')
            expect(@helper).to receive(:fetch).with(uri: changelist_uri).once.and_return(changelist_data)

            changedump_uri = URI('http://example.com/dataset1/changedump.xml')
            changedump_data = File.read('spec/data/examples/change-dump.xml')
            expect(@helper).to receive(:fetch).with(uri: changedump_uri).once.and_return(changedump_data)

            cap_list = @client.get_and_parse(cap_list_uri)
            a1 = cap_list.all_resources.to_a
            a2 = cap_list.all_resources.to_a
            a1.each_with_index do |r, i|
              expect(r).to be(a2[i])
            end
          end
        end
      end
    end
  end
end
