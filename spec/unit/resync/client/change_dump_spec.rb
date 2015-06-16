require 'spec_helper'

module Resync
  describe ChangeDump do
    describe '#zip_packages' do
      it 'should accept an optional time range'
    end

    describe '#all_zip_packages' do
      it 'should delegate to #zip_packages'
    end
  end

  describe ChangeDumpIndex do
    describe '#all_zip_packages' do
      it 'should accept an optional time range'
    end
  end

end
