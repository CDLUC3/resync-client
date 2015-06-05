require 'spec_helper'

module Resync
  describe Client do
    describe 'example.rb' do
      it 'should work against "real" simulator data' do
        helper = instance_double(Client::HTTPHelper)
        client = Client.new(helper: helper)

        sourcedesc_uri = URI('http://localhost:8888/.well-known/resourcesync')
        sourcedesc_data = File.read('spec/data/simulator/source-description.xml')
        expect(helper).to receive(:fetch).with(uri: sourcedesc_uri).and_return(sourcedesc_data)

        cap_list_uri = URI('http://localhost:8888/capabilitylist.xml')
        cap_list_data = File.read('spec/data/simulator/capability-list.xml')
        expect(helper).to receive(:fetch).with(uri: cap_list_uri).and_return(cap_list_data)

        change_list_uri = URI('http://localhost:8888/changelist.xml')
        change_list_data = File.read('spec/data/simulator/change-list.xml')
        expect(helper).to receive(:fetch).with(uri: change_list_uri).and_return(change_list_data)

        update_uri = URI('http://localhost:8888/resources/19859')
        update_data = File.read('spec/data/simulator/update.txt')
        expect(helper).to receive(:fetch).with(uri: update_uri).and_return(update_data)

        source_desc = client.get_and_parse(sourcedesc_uri)
        expect(source_desc).to be_a(SourceDescription)
        cap_list_resource = source_desc.resource_for(capability: 'capabilitylist')
        expect(cap_list_resource.uri).to eq(cap_list_uri)

        cap_list = cap_list_resource.get_and_parse
        expect(cap_list).to be_a(CapabilityList)
        change_list_resource = cap_list.resource_for(capability: 'changelist')
        expect(change_list_resource.uri).to eq(change_list_uri)

        change_list = change_list_resource.get_and_parse
        expect(change_list).to be_a(ChangeList)

        changes = change_list.resources
        last_update = changes.select { |r| r.metadata.change == Resync::Types::Change::UPDATED }[-1]
        expect(last_update.uri).to eq(update_uri)
        expect(last_update.get).to eq(update_data)
      end
    end
  end
end
