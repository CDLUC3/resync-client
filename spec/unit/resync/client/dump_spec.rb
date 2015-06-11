require 'spec_helper'

module Resync
  describe ResourceDump do
    describe '#zip_packages' do
      it 'transparently exposes bitstreams' do
        path = 'spec/data/resourcedump/resourcedump.xml'
        package_uri = URI('http://example.com/resourcedump.zip')

        client = instance_double(Client)
        expect(client).to receive(:download_to_temp_file).once.with(package_uri).and_return('spec/data/resourcedump/resourcedump.zip')

        dump = XMLParser.parse(File.read(path))
        dump.client = client

        zip_packages = dump.zip_packages
        expect(zip_packages.size).to eq(1)
        expect(zip_packages[0]).to be_a(Client::Zip::ZipPackage)

        bitstreams = zip_packages[0].bitstreams
        expect(bitstreams.size).to eq(2)
        expect(bitstreams[0].content).to eq(File.read('spec/data/resourcedump/resources/res1'))
        expect(bitstreams[1].content).to eq(File.read('spec/data/resourcedump/resources/res2'))
      end
    end

    describe '#all_zip_packages' do
      it 'is an alias for #zip_packages' do
        path = 'spec/data/resourcedump/resourcedump.xml'
        package_uri = URI('http://example.com/resourcedump.zip')

        client = instance_double(Client)
        expect(client).to receive(:download_to_temp_file).once.with(package_uri).and_return('spec/data/resourcedump/resourcedump.zip')

        dump = XMLParser.parse(File.read(path))
        dump.client = client

        all_zip_packages = dump.all_zip_packages
        expect(all_zip_packages.size).to eq(1)
        expect(all_zip_packages[0]).to be_a(Client::Zip::ZipPackage)

        bitstreams = all_zip_packages[0].bitstreams
        expect(bitstreams.size).to eq(2)
        expect(bitstreams[0].content).to eq(File.read('spec/data/resourcedump/resources/res1'))
        expect(bitstreams[1].content).to eq(File.read('spec/data/resourcedump/resources/res2'))
      end
    end
  end

  describe ChangeDump do
    describe '#zip_packages' do
      it 'transparently exposes bitstreams' do
        path = 'spec/data/resourcedump/changedump.xml'
        package_uri = URI('http://example.com/changedump.zip')

        client = instance_double(Client)
        expect(client).to receive(:download_to_temp_file).once.with(package_uri).and_return('spec/data/resourcedump/resourcedump.zip')

        dump = XMLParser.parse(File.read(path))
        dump.client = client

        zip_packages = dump.zip_packages
        expect(zip_packages.size).to eq(1)
        expect(zip_packages[0]).to be_a(Client::Zip::ZipPackage)

        bitstreams = zip_packages[0].bitstreams
        expect(bitstreams.size).to eq(2)
        expect(bitstreams[0].content).to eq(File.read('spec/data/resourcedump/resources/res1'))
        expect(bitstreams[1].content).to eq(File.read('spec/data/resourcedump/resources/res2'))
      end
    end

    describe '#all_zip_packages' do
      it 'is an alias for #zip_packages' do
        path = 'spec/data/resourcedump/changedump.xml'
        package_uri = URI('http://example.com/changedump.zip')

        client = instance_double(Client)
        expect(client).to receive(:download_to_temp_file).once.with(package_uri).and_return('spec/data/resourcedump/resourcedump.zip')

        dump = XMLParser.parse(File.read(path))
        dump.client = client

        zip_packages = dump.all_zip_packages
        expect(zip_packages.size).to eq(1)
        expect(zip_packages[0]).to be_a(Client::Zip::ZipPackage)

        bitstreams = zip_packages[0].bitstreams
        expect(bitstreams.size).to eq(2)
        expect(bitstreams[0].content).to eq(File.read('spec/data/resourcedump/resources/res1'))
        expect(bitstreams[1].content).to eq(File.read('spec/data/resourcedump/resources/res2'))
      end
    end
  end
end
