require 'spec_helper'

module Resync
  describe ZippedResourceList do
    it "works for #{ResourceDump}" do
      path = 'spec/data/resourcedump/resourcedump.xml'
      package_uri = URI('http://example.com/resourcedump.zip')

      client = instance_double(Client)
      expect(client).to receive(:download_to_temp_file).once.with(package_uri).and_return('spec/data/resourcedump/resourcedump.zip')

      dump = XMLParser.parse(File.read(path))
      dump.client = client

      zip_packages = dump.zip_packages
      expect(zip_packages.size).to eq(1)

      zip_package = zip_packages[0]
      expect(zip_package).to be_a(ZipPackage)

      bitstreams = zip_package.bitstreams
      expect(bitstreams.size).to eq(2)

      stream1 = bitstreams[0]
      expect(stream1.content).to eq(File.read('spec/data/resourcedump/resources/res1'))

      stream2 = bitstreams[1]
      expect(stream2.content).to eq(File.read('spec/data/resourcedump/resources/res2'))
    end

    it "works for #{ChangeDump}" do
      path = 'spec/data/resourcedump/changedump.xml'
      package_uri = URI('http://example.com/changedump.zip')

      client = instance_double(Client)
      expect(client).to receive(:download_to_temp_file).once.with(package_uri).and_return('spec/data/resourcedump/resourcedump.zip')

      dump = XMLParser.parse(File.read(path))
      dump.client = client

      zip_packages = dump.zip_packages
      expect(zip_packages.size).to eq(1)

      zip_package = zip_packages[0]
      expect(zip_package).to be_a(ZipPackage)

      bitstreams = zip_package.bitstreams
      expect(bitstreams.size).to eq(2)

      stream1 = bitstreams[0]
      expect(stream1.content).to eq(File.read('spec/data/resourcedump/resources/res1'))

      stream2 = bitstreams[1]
      expect(stream2.content).to eq(File.read('spec/data/resourcedump/resources/res2'))
    end
  end

end
