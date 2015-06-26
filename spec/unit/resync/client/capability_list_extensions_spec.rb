require 'spec_helper'

module Resync
  describe CapabilityList do
    doc_types = [ResourceList, ResourceDump, ChangeList, ChangeDump]

    before(:each) do
      @client = instance_double(Resync::Client)
      allow(@client).to receive(:client) { @client }
      @cap_list = XMLParser.parse(File.read('spec/data/examples/capability-list.xml'))
      @cap_list.client_delegate = @client
    end

    describe '#document_for' do
      it 'downloads and parses documents by capability' do
        doc_types.each do |doc_type|
          capability = doc_type::CAPABILITY
          class_name = doc_type.name.split('::').last
          uri = URI("http://example.com/dataset1/#{class_name.downcase}.xml")
          doc = instance_double(doc_type)
          expect(@client).to receive(:get_and_parse).once.with(uri) { doc }
          expect(@cap_list.document_for(capability)).to be(doc)
          expect(@cap_list.document_for(capability)).to be(@cap_list.document_for(capability))
        end
      end

      it 'caches downloaded resources' do
        doc_types.each do |doc_type|
          capability = doc_type::CAPABILITY
          class_name = doc_type.name.split('::').last
          uri = URI("http://example.com/dataset1/#{class_name.downcase}.xml")
          doc = instance_double(doc_type)
          expect(@client).to receive(:get_and_parse).once.with(uri) { doc }
          expect(@cap_list.document_for(capability)).to be(@cap_list.document_for(capability))
        end
      end
    end

    doc_types.each do |doc_type|
      class_name = doc_type.name.split('::').last
      method_name = class_name.gsub(/(.)([A-Z])/, '\1_\2').downcase

      describe "##{method_name}" do
        it "downloads and parses the #{class_name}" do
          uri = URI("http://example.com/dataset1/#{class_name.downcase}.xml")
          doc = instance_double(doc_type)
          expect(@client).to receive(:get_and_parse).once.with(uri) { doc }
          expect(@cap_list.send(method_name.to_sym)).to be(doc)
        end

        it "caches the downloaded/parsed #{class_name}" do
          uri = URI("http://example.com/dataset1/#{class_name.downcase}.xml")
          doc = instance_double(doc_type)
          expect(@client).to receive(:get_and_parse).once.with(uri) { doc }
          expect(@cap_list.send(method_name.to_sym)).to be(@cap_list.send(method_name.to_sym))
        end
      end
    end

  end
end
