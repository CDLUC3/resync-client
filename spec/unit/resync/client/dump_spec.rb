require 'spec_helper'

module Resync
  module Extensions
    describe Dump do
      it 'transparently extracts bitstreams' do
        package_uri = URI('http://example.com/resourcedump.zip')
        client = instance_double(Client)
        expect(client).to receive(:download_to_temp_file).once.with(package_uri).and_return('spec/data/resourcedump/resourcedump.zip')

        resource_dump = XMLParser.parse(File.read('spec/data/resourcedump/resourcedump.xml'))
        resource_dump.client = client

        zip_packages = resource_dump.zip_packages
        expect(zip_packages.size).to eq(1)

        zip_package = zip_packages[0]
        expect(zip_package).to be_a(ZipPackage)

        bitstreams = zip_package.bitstreams
        expect(bitstreams.size).to eq(2)

        stream1 = bitstreams[0]
        expect(stream1.content).to eq(File.read('spec/data/resourcedump/resources/res1'))
      end
    end
  end
end
