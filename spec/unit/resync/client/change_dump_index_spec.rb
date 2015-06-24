require 'spec_helper'

module Resync
  describe ChangeDumpIndex do
    before(:each) do
      @change_dump_index = ChangeDumpIndex.load_from_xml(XML.element(
        "<sitemapindex xmlns='http://www.sitemaps.org/schemas/sitemap/0.9' xmlns:rs='http://www.openarchives.org/rs/terms/'>
          <rs:md capability='changedump'/>
          <sitemap>
            <loc>http://example.com/20130101-changedump.xml</loc>
            <rs:md from='2013-01-01T00:00:00Z' until='2013-01-02T00:00:00Z'/>
          </sitemap>
          <sitemap>
            <loc>http://example.com/20130102-changedump.xml</loc>
            <rs:md from='2013-01-02T00:00:00Z' until='2013-01-03T00:00:00Z'/>
          </sitemap>
          <sitemap>
            <loc>http://example.com/20130103-changedump.xml</loc>
            <rs:md from='2013-01-03T00:00:00Z' until='2013-01-04T00:00:00Z'/>
          </sitemap>
        </sitemapindex>"))

      @change_dumps = [
        "<urlset xmlns='http://www.sitemaps.org/schemas/sitemap/0.9' xmlns:rs='http://www.openarchives.org/rs/terms/'>
          <rs:md capability='changedump'/>
          <url>
            <loc>http://example.com/20130101-changedump-0.zip</loc>
            <rs:md modified='2013-01-01T11:59:59Z' from='2013-01-01T00:00:00Z' until='2013-01-01T12:00:00Z'/>
          </url>
          <url>
            <loc>http://example.com/20130101-changedump-1.zip</loc>
            <rs:md modified='2013-01-01T23:59:59Z' from='2013-01-01T12:00:00Z' until='2013-01-02T00:00:00Z'/>
          </url>
        </urlset>",
       "<urlset xmlns='http://www.sitemaps.org/schemas/sitemap/0.9' xmlns:rs='http://www.openarchives.org/rs/terms/'>
          <rs:md capability='changedump'/>
          <url>
            <loc>http://example.com/20130102-changedump-0.zip</loc>
            <rs:md modified='2013-01-02T11:59:59Z' from='2013-01-02T00:00:00Z' until='2013-01-02T12:00:00Z'/>
          </url>
          <url>
            <loc>http://example.com/20130102-changedump-1.zip</loc>
            <rs:md modified='2013-01-02T23:59:59Z' from='2013-01-02T12:00:00Z' until='2013-01-03T00:00:00Z'/>
          </url>
        </urlset>",
        "<urlset xmlns='http://www.sitemaps.org/schemas/sitemap/0.9' xmlns:rs='http://www.openarchives.org/rs/terms/'>
          <rs:md capability='changedump'/>
          <url>
            <loc>http://example.com/20130103-changedump-0.zip</loc>
            <rs:md modified='2013-01-03T11:59:59Z' from='2013-01-03T00:00:00Z' until='2013-01-03T12:00:00Z'/>
          </url>
          <url>
            <loc>http://example.com/20130103-changedump-1.zip</loc>
            <rs:md modified='2013-01-03T23:59:59Z' from='2013-01-03T12:00:00Z' until='2013-01-04T00:00:00Z'/>
          </url>
        </urlset>"
      ].map { |xml| ChangeDump.load_from_xml(XML.element(xml)) }

      @all_package_resources = []
      @all_zip_packages = []
      @change_dumps.each do |d|
        d.resources.each do |r|
          @all_package_resources << r
          zp = instance_double(Resync::Client::Zip::ZipPackage)
          allow(r).to receive(:zip_package) { zp }
          @all_zip_packages << zp
        end
      end

      @change_dump_resources = []
      @change_dump_index.resources.each_with_index do |r, i|
        @change_dump_resources << r
        allow(r).to receive(:get_and_parse) { @change_dumps[i] }
      end
    end

    describe '#all_zip_packages' do
      it 'should accept an optional time range' do
        range = Time.utc(2013, 1, 1)..Time.utc(2013, 1, 2, 6)
        all_packages = @change_dump_index.all_zip_packages(in_range: range).to_a
        expect(all_packages).to eq(@all_zip_packages[0, 3])
      end

      it 'should not download unnecessary dumps or packages' do
        expect(@change_dump_resources[2]).not_to receive(:get_and_parse)
        @all_package_resources[3, 3].each do |r|
          expect(r).not_to receive(:zip_package)
        end
        @change_dump_index.all_zip_packages(in_range: Time.utc(2013, 1, 1)..Time.utc(2013, 1, 2, 6)).to_a
      end

      it 'should not require a time range' do
        all_packages = @change_dump_index.all_zip_packages.to_a
        expect(all_packages).to eq(@all_zip_packages)
      end
    end

  end
end
