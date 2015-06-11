require 'spec_helper'

module Resync
  class Client
    module Mixins
      describe ListOfZippedResourceLists do
        before(:each) do
          @helper = instance_double(Client::HTTPHelper)
          @client = Client.new(helper: @helper)
        end

        describe '#all_zip_packages' do
          it 'flattens the child resourcelists' do
            resources = Array.new(6) { instance_double(ZippedResource) }
            all_zip_packages = Array.new(6) do |i|
              zip_package = instance_double(Zip::ZipPackage)
              expect(resources[i]).to receive(:zip_package).once.and_return(zip_package)
              allow(resources[i]).to receive(:client_delegate=)
              zip_package
            end

            dump1 = ResourceDump.new(resources: resources[0, 3])
            dump2 = ResourceDump.new(resources: resources[3, 3])

            dump1_resource = instance_double(Resource)
            allow(dump1_resource).to receive(:client_delegate=)
            expect(dump1_resource).to receive(:get_and_parse).and_return(dump1)

            dump2_resource = instance_double(Resource)
            allow(dump2_resource).to receive(:client_delegate=)
            expect(dump2_resource).to receive(:get_and_parse).and_return(dump2)

            index = ResourceDumpIndex.new(resources: [dump1_resource, dump2_resource])
            all_packages = index.all_zip_packages

            expect(all_packages.to_a).to eq(all_zip_packages)
          end

          it 'is lazy enough not to download anything till it\'s iterated' do
            dump1_resource = instance_double(Resource)
            allow(dump1_resource).to receive(:client_delegate=)
            expect(dump1_resource).not_to receive(:get_and_parse)

            dump2_resource = instance_double(Resource)
            allow(dump2_resource).to receive(:client_delegate=)
            expect(dump2_resource).not_to receive(:get_and_parse)

            index = ResourceDumpIndex.new(resources: [dump1_resource, dump2_resource])
            index.all_zip_packages
          end

          it 'is lazy enough not to download resources it doesn\'t need' do
            resources = Array.new(3) { instance_double(ZippedResource) }
            resources.each do |r|
              allow(r).to receive(:client_delegate=)
              zip_package = instance_double(Zip::ZipPackage)
              expect(r).to receive(:zip_package).once.and_return(zip_package)
            end

            dump1 = ResourceDump.new(resources: resources[0, 3])

            dump1_resource = instance_double(Resource)
            allow(dump1_resource).to receive(:client_delegate=)
            expect(dump1_resource).to receive(:get_and_parse).and_return(dump1)

            dump2_resource = instance_double(Resource)
            allow(dump2_resource).to receive(:client_delegate=)
            expect(dump2_resource).not_to receive(:get_and_parse)

            index = ResourceDumpIndex.new(resources: [dump1_resource, dump2_resource])
            index.all_zip_packages.each_with_index do |_, i|
              break if i >= 2
            end
          end

          it 'caches downloaded resources' do
            resources = Array.new(6) { instance_double(ZippedResource) }
            resources.each do |r|
              allow(r).to receive(:client_delegate=)
              zip_package = instance_double(Zip::ZipPackage)
              expect(r).to receive(:zip_package).once.and_return(zip_package)
            end

            dump1 = ResourceDump.new(resources: resources[0, 3])
            dump2 = ResourceDump.new(resources: resources[3, 3])

            dump1_resource = instance_double(Resource)
            allow(dump1_resource).to receive(:client_delegate=)
            expect(dump1_resource).to receive(:get_and_parse).once.and_return(dump1)

            dump2_resource = instance_double(Resource)
            allow(dump2_resource).to receive(:client_delegate=)
            expect(dump2_resource).to receive(:get_and_parse).once.and_return(dump2)

            index = ResourceDumpIndex.new(resources: [dump1_resource, dump2_resource])
            all_packages = index.all_zip_packages

            a1 = all_packages.to_a
            a2 = all_packages.to_a
            a1.each_with_index do |pkg, i|
              expect(pkg).to be(a2[i])
            end
          end
        end
      end
    end
  end
end
