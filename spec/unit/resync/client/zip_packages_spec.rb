require 'spec_helper'

module Resync
  class Client
    module Zip
      describe ZipPackages do
        it 'is lazy' do
          resources = Array.new(3) { |i| Resource.new(uri: "http://example.org/res#{i}") }

          zip_packages = ZipPackages.new(resources)

          zip_package = instance_double(ZipPackage)
          expect(resources[0]).not_to receive(:zip_package)
          expect(resources[1]).not_to receive(:zip_package)
          expect(resources[2]).to receive(:zip_package).and_return(zip_package)

          expect(zip_packages[2]).to be(zip_package)
        end

        it 'caches zip packages' do
          resources = Array.new(3) { |i| Resource.new(uri: "http://example.org/res#{i}") }

          zip_packages = ZipPackages.new(resources)

          zip_package = instance_double(ZipPackage)
          expect(resources[1]).to receive(:zip_package).once.and_return(zip_package)

          expect(zip_packages[1]).to be(zip_package)
          expect(zip_packages[1]).to be(zip_package)
        end

        it 'flatmaps' do
          resources = Array.new(6) { |i| Resource.new(uri: "http://example.org/res#{i}") }
          all_packages = Array.new(6) do |i|
            zip_package = instance_double(ZipPackage)
            expect(resources[i]).to receive(:zip_package).once.and_return(zip_package)
            zip_package
          end

          zip_packages_1 = ZipPackages.new(resources[0, 3])
          zip_packages_2 = ZipPackages.new(resources[3, 3])

          zrl1 = instance_double(Resync::Client::Mixins::ZippedResourceList)
          expect(zrl1).to receive(:zip_packages).twice.and_return(zip_packages_1)

          zrl2 = instance_double(Resync::Client::Mixins::ZippedResourceList)
          expect(zrl2).to receive(:zip_packages).twice.and_return(zip_packages_2)

          flat_mapped = [zrl1, zrl2].flat_map(&:zip_packages)
          expect(flat_mapped).to eq(all_packages)

          lazy_flat_mapped = [zrl1, zrl2].lazy.flat_map(&:zip_packages).to_a
          expect(lazy_flat_mapped).to eq(all_packages)
        end

        it 'supports lazy iteration' do
          manifests = Array.new(3) { instance_double(ChangeDumpManifest) }
          all_packages = Array.new(3) do |index|
            zip_package = instance_double(ZipPackage)
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

          zip_packages = ZipPackages.new(resources)
          zip_packages.each_with_index do |zip_package, index|
            expect(zip_package.manifest).to be(manifests[index])
            break if index >= 1
          end
        end
      end
    end
  end
end
