require 'spec_helper'

module Resync
  describe ChangeDump do
    before(:each) do
      @resources = [
        Resource.new(
          uri: URI('http://example.com/20130101-changedump.zip'),
          modified_time: Time.utc(2013, 1, 1, 23, 59, 59),
          metadata: Metadata.new(
            from_time: Time.utc(2013, 1, 1),
            until_time: Time.utc(2013, 1, 2)
          )
        ),
        Resource.new(
          uri: URI('http://example.com/20130102-changedump.zip'),
          modified_time: Time.utc(2013, 1, 2, 23, 59, 59),
          metadata: Metadata.new(
            from_time: Time.utc(2013, 1, 2),
            until_time: Time.utc(2013, 1, 3)
          )
        ),
        Resource.new(
          uri: URI('http://example.com/20130103-changedump.zip'),
          modified_time: Time.utc(2013, 1, 3, 23, 59, 59),
          metadata: Metadata.new(
            from_time: Time.utc(2013, 1, 3),
            until_time: Time.utc(2013, 1, 4)
          )
        )
      ]
      @dump = ChangeDump.new(resources: @resources)

      @zip_packages = []
      @resources.each_with_index do |r, i|
        @zip_packages[i] = instance_double(Resync::Client::Zip::ZipPackage)
        allow(r).to receive(:zip_package) { @zip_packages[i] }
      end
    end

    describe '#zip_packages' do
      it 'should accept an optional time range' do
        packages = @dump.zip_packages(in_range: Time.utc(2013, 1, 3)..Time.utc(2013, 1, 4))
        expect(packages.size).to eq(2)
        expect(packages.to_a).to eq([@zip_packages[1], @zip_packages[2]])
      end

      it 'should not require a time range' do
        packages = @dump.zip_packages
        expect(packages.to_a).to eq(@zip_packages)
      end
    end

    describe '#all_zip_packages' do
      it 'should delegate to #zip_packages' do
        packages = @dump.all_zip_packages
        expect(packages.to_a).to eq(@zip_packages)
      end
    end
  end

end
