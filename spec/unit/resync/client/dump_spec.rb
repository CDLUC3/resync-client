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

      it 'is lazy' do
        resources = Array.new(3) { |i| Resource.new(uri: "http://example.org/res#{i}") }
        dump = ResourceDump.new(resources: resources)
        zip_packages = dump.zip_packages
        zip_package = instance_double(Client::Zip::ZipPackage)

        expect(resources[0]).not_to receive(:zip_package)
        expect(resources[1]).not_to receive(:zip_package)
        expect(resources[2]).to receive(:zip_package).and_return(zip_package)

        expect(zip_packages[2]).to be(zip_package)
      end

      it 'flatmaps' do
        resources = Array.new(6) { |i| Resource.new(uri: "http://example.org/res#{i}") }
        all_packages = Array.new(6) do |i|
          zip_package = instance_double(Client::Zip::ZipPackage)
          expect(resources[i]).to receive(:zip_package).once.and_return(zip_package)
          zip_package
        end

        zrl1 = ResourceDump.new(resources: resources[0, 3])
        zrl2 = ResourceDump.new(resources: resources[3, 3])

        lazy_flat_mapped = [zrl1, zrl2].lazy.flat_map(&:zip_packages).to_a
        expect(lazy_flat_mapped).to eq(all_packages)

        flat_mapped = [zrl1, zrl2].flat_map(&:zip_packages)
        expect(flat_mapped).to eq(all_packages)
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

      it 'is lazy' do
        resources = Array.new(3) { |i| Resource.new(uri: "http://example.org/res#{i}") }
        dump = ChangeDump.new(resources: resources)
        zip_packages = dump.zip_packages
        zip_package = instance_double(Client::Zip::ZipPackage)

        expect(resources[0]).not_to receive(:zip_package)
        expect(resources[1]).not_to receive(:zip_package)
        expect(resources[2]).to receive(:zip_package).and_return(zip_package)

        expect(zip_packages[2]).to be(zip_package)
      end

      it 'flatmaps' do
        resources = Array.new(6) { |i| Resource.new(uri: "http://example.org/res#{i}") }
        all_packages = Array.new(6) do |i|
          zip_package = instance_double(Client::Zip::ZipPackage)
          expect(resources[i]).to receive(:zip_package).once.and_return(zip_package)
          zip_package
        end

        zrl1 = ChangeDump.new(resources: resources[0, 3])
        zrl2 = ChangeDump.new(resources: resources[3, 3])

        lazy_flat_mapped = [zrl1, zrl2].lazy.flat_map(&:zip_packages).to_a
        expect(lazy_flat_mapped).to eq(all_packages)

        flat_mapped = [zrl1, zrl2].flat_map(&:zip_packages)
        expect(flat_mapped).to eq(all_packages)
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
