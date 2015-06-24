require 'spec_helper'

module Resync
  class Client
    module Mixins
      describe DumpIndex do
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
            zip_packages = Array.new(3) { instance_double(Zip::ZipPackage) }
            resources.each_with_index do |r, i|
              allow(r).to receive(:client_delegate=)
              if i <= 1
                expect(r).to receive(:zip_package).once.and_return(zip_packages[i])
              else
                expect(r).not_to receive(:zip_package)
              end
            end

            dump1 = ResourceDump.new(resources: resources[0, 3])

            dump1_resource = instance_double(Resource)
            allow(dump1_resource).to receive(:client_delegate=)
            expect(dump1_resource).to receive(:get_and_parse).and_return(dump1)

            dump2_resource = instance_double(Resource)
            allow(dump2_resource).to receive(:client_delegate=)
            expect(dump2_resource).not_to receive(:get_and_parse)

            index = ResourceDumpIndex.new(resources: [dump1_resource, dump2_resource])
            index.all_zip_packages.each_with_index do |zp, i|
              expect(zp).to be(zip_packages[i])
              break if i >= 1
            end
          end
        end
      end
    end
  end
end
