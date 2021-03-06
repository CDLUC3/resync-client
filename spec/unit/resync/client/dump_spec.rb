require 'spec_helper'

module Resync
  # TODO: introduce shared examples
  describe ResourceDump do
    describe '#zip_packages' do
      it 'transparently exposes bitstreams' do
        path = 'spec/data/resourcedump/resourcedump.xml'
        package_uri = URI('http://example.com/bitstream-package.zip')

        client = instance_double(Client)
        expect(client).to receive(:download_to_temp_file).once.with(package_uri).and_return('spec/data/resourcedump/bitstream-package.zip')

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

        flat_mapped = [zrl1, zrl2].flat_map(&:zip_packages)
        expect(flat_mapped).to eq(all_packages)

        lazy_flat_mapped = [zrl1, zrl2].lazy.flat_map(&:zip_packages).to_a
        expect(lazy_flat_mapped).to eq(all_packages)
      end

      it 'supports lazy iteration ' do
        manifests = Array.new(3) { instance_double(ChangeDumpManifest) }
        all_packages = Array.new(3) do |index|
          zip_package = instance_double(Client::Zip::ZipPackage)
          allow(zip_package).to receive(:manifest).and_return(manifests[index])
          zip_package
        end
        resources = Array.new(3) do |index|
          resource = Resource.new(uri: "http://example.org/res#{index}")
          if index > 1
            expect(resource).not_to receive(:zip_package)
          else
            expect(resource).to receive(:zip_package).and_return(all_packages[index])
          end
          resource
        end

        zip_packages = ResourceDump.new(resources: resources).zip_packages
        zip_packages.each_with_index do |zip_package, index|
          expect(zip_package.manifest).to be(manifests[index])
          break if index >= 1
        end
      end
    end

    describe '#all_zip_packages' do
      it 'delegates to #zip_packages, lazily' do
        path = 'spec/data/resourcedump/resourcedump.xml'
        package_uri = URI('http://example.com/bitstream-package.zip')

        client = instance_double(Client)
        expect(client).to receive(:download_to_temp_file).once.with(package_uri).and_return('spec/data/resourcedump/bitstream-package.zip')

        dump = XMLParser.parse(File.read(path))
        dump.client = client

        all_zip_packages = dump.all_zip_packages
        expect(all_zip_packages).to be_a(Enumerator::Lazy)

        all_zip_packages_array = all_zip_packages.to_a
        expect(all_zip_packages_array.size).to eq(1)
        expect(all_zip_packages_array[0]).to be_a(Client::Zip::ZipPackage)

        bitstreams = all_zip_packages_array[0].bitstreams
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
        expect(client).to receive(:download_to_temp_file).once.with(package_uri).and_return('spec/data/resourcedump/bitstream-package.zip')

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

      it 'supports lazy iteration ' do
        manifests = Array.new(3) { instance_double(ChangeDumpManifest) }
        all_packages = Array.new(3) do |index|
          zip_package = instance_double(Client::Zip::ZipPackage)
          allow(zip_package).to receive(:manifest).and_return(manifests[index])
          zip_package
        end
        resources = Array.new(3) do |index|
          resource = Resource.new(uri: "http://example.org/res#{index}")
          if index > 1
            expect(resource).not_to receive(:zip_package)
          else
            expect(resource).to receive(:zip_package).and_return(all_packages[index])
          end
          resource
        end

        zip_packages = ChangeDump.new(resources: resources).zip_packages
        zip_packages.each_with_index do |zip_package, index|
          expect(zip_package.manifest).to be(manifests[index])
          break if index >= 1
        end
      end
    end

    describe '#all_zip_packages' do
      it 'delegates to #zip_packages, lazily' do
        path = 'spec/data/resourcedump/changedump.xml'
        package_uri = URI('http://example.com/changedump.zip')

        client = instance_double(Client)
        expect(client).to receive(:download_to_temp_file).once.with(package_uri).and_return('spec/data/resourcedump/bitstream-package.zip')

        dump = XMLParser.parse(File.read(path))
        dump.client = client

        all_zip_packages = dump.all_zip_packages
        expect(all_zip_packages).to be_a(Enumerator::Lazy)

        all_zip_packages_array = all_zip_packages.to_a
        expect(all_zip_packages_array.size).to eq(1)
        expect(all_zip_packages_array[0]).to be_a(Client::Zip::ZipPackage)

        bitstreams = all_zip_packages_array[0].bitstreams
        expect(bitstreams.size).to eq(2)
        expect(bitstreams[0].content).to eq(File.read('spec/data/resourcedump/resources/res1'))
        expect(bitstreams[1].content).to eq(File.read('spec/data/resourcedump/resources/res2'))
      end
    end
  end
end
