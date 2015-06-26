require 'spec_helper'

module Resync
  class Client
    module Mixins
      describe ListIndex do
        before(:each) do
          @helper = instance_double(Client::HTTPHelper)
          @client = Client.new(helper: @helper)
        end

        describe '#all_resources' do
          it 'flattens the child resourcelists' do
            index_uri = URI('http://example.com/resource-list-index.xml')
            index_data = File.read('spec/data/examples/resource-list-index.xml')
            expect(@helper).to receive(:fetch).with(uri: index_uri).and_return(index_data)

            list_1_uri = URI('http://example.com/resourcelist1.xml')
            list_1_data = File.read('spec/data/examples/resource-list-1.xml')
            expect(@helper).to receive(:fetch).with(uri: list_1_uri).once.and_return(list_1_data)

            list_1_uri = URI('http://example.com/resourcelist2.xml')
            list_1_data = File.read('spec/data/examples/resource-list-2.xml')
            expect(@helper).to receive(:fetch).with(uri: list_1_uri).once.and_return(list_1_data)

            list_1_uri = URI('http://example.com/resourcelist3.xml')
            list_1_data = File.read('spec/data/examples/resource-list-3.xml')
            expect(@helper).to receive(:fetch).with(uri: list_1_uri).once.and_return(list_1_data)

            index = @client.get_and_parse(index_uri)
            all_resources = index.all_resources.to_a
            expect(all_resources.size).to eq(6)
            all_resources.each_with_index do |r, i|
              expected_uri = URI("http://example.com/res#{i + 1}")
              expect(r.uri).to eq(expected_uri)
            end
          end

          it 'is lazy' do
            index_uri = URI('http://example.com/resource-list-index.xml')
            index_data = File.read('spec/data/examples/resource-list-index.xml')
            expect(@helper).to receive(:fetch).with(uri: index_uri).and_return(index_data)

            index = @client.get_and_parse(index_uri)
            all_resources = index.all_resources
            expect(all_resources).to be_a(Enumerator::Lazy)
          end

          it 'is lazy enough not to download anything till it \'s iterated ' do
            index_uri = URI('http://example.com/resource-list-index.xml')
            index_data = File.read('spec/data/examples/resource-list-index.xml')
            expect(@helper).to receive(:fetch).with(uri: index_uri).and_return(index_data)

            list_1_uri = URI('http://example.com/resourcelist1.xml')
            expect(@helper).not_to receive(:fetch).with(uri: list_1_uri)

            list_1_uri = URI('http://example.com/resourcelist2.xml')
            expect(@helper).not_to receive(:fetch).with(uri: list_1_uri)

            list_1_uri = URI('http://example.com/resourcelist3.xml')
            expect(@helper).not_to receive(:fetch).with(uri: list_1_uri)

            index = @client.get_and_parse(index_uri)
            index.all_resources
          end

          it 'is lazy enough not to download resources it doesn\'t need' do
            index_uri = URI('http://example.com/resource-list-index.xml')
            index_data = File.read('spec/data/examples/resource-list-index.xml')
            expect(@helper).to receive(:fetch).with(uri: index_uri).and_return(index_data)

            list_1_uri = URI('http://example.com/resourcelist1.xml')
            list_1_data = File.read('spec/data/examples/resource-list-1.xml')
            expect(@helper).to receive(:fetch).with(uri: list_1_uri).once.and_return(list_1_data)

            list_1_uri = URI('http://example.com/resourcelist2.xml')
            list_1_data = File.read('spec/data/examples/resource-list-2.xml')
            expect(@helper).to receive(:fetch).with(uri: list_1_uri).once.and_return(list_1_data)

            list_1_uri = URI('http://example.com/resourcelist3.xml')
            expect(@helper).not_to receive(:fetch).with(uri: list_1_uri)

            index = @client.get_and_parse(index_uri)
            index.all_resources.each_with_index do |_, i|
              break if i >= 3
            end
          end

          it 'caches downloaded resources' do
            index_uri = URI('http://example.com/resource-list-index.xml')
            index_data = File.read('spec/data/examples/resource-list-index.xml')
            expect(@helper).to receive(:fetch).with(uri: index_uri).and_return(index_data)

            list_1_uri = URI('http://example.com/resourcelist1.xml')
            list_1_data = File.read('spec/data/examples/resource-list-1.xml')
            expect(@helper).to receive(:fetch).with(uri: list_1_uri).once.and_return(list_1_data)

            list_1_uri = URI('http://example.com/resourcelist2.xml')
            list_1_data = File.read('spec/data/examples/resource-list-2.xml')
            expect(@helper).to receive(:fetch).with(uri: list_1_uri).once.and_return(list_1_data)

            list_1_uri = URI('http://example.com/resourcelist3.xml')
            list_1_data = File.read('spec/data/examples/resource-list-3.xml')
            expect(@helper).to receive(:fetch).with(uri: list_1_uri).once.and_return(list_1_data)

            index = @client.get_and_parse(index_uri)
            a1 = index.all_resources.to_a
            a2 = index.all_resources.to_a
            a1.each_with_index do |r, i|
              expect(r).to be(a2[i])
            end
          end
        end
      end
    end
  end
end
