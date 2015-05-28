require 'spec_helper'

module Resync
  class Client
    describe HTTPHelper do

      # ------------------------------------------------------------
      # Fixture

      attr_writer :user_agent

      def user_agent
        @user_agent ||= 'elvis'
      end

      attr_writer :helper

      def helper
        @helper ||= HTTPHelper.new(user_agent: user_agent)
      end

      # ------------------------------------------------------------
      # Tests

      describe '#fetch' do

        # ------------------------------
        # Fixture

        before(:each) do
          @http = instance_double(Net::HTTP)
          allow(Net::HTTP).to receive(:new).and_return(@http)
          allow(@http).to receive(:start).and_yield(@http)
          @success = Net::HTTPOK.allocate
        end

        # ------------------------------
        # Tests

        it 'requests the specified URI' do
          uri = URI('http://example.org/')
          expect(@http).to receive(:request).with(request_for(uri: uri)).and_return(@success)
          helper.fetch(uri)
        end

        it 'gets a response' do
          expect(@http).to receive(:request).and_return(@success)
          expect(helper.fetch(URI('http://example.org/'))).to be(@success)
        end

        it 'sets the User-Agent header' do
          agent = 'Not Elvis'
          helper = HTTPHelper.new(user_agent: agent)
          expect(@http).to receive(:request).with(request_for(headers: { 'User-Agent' => agent })).and_return(@success)
          helper.fetch(URI('http://example.org/'))
        end

        it 'uses SSL for https requests' do
          uri = URI('https://example.org/')
          expect(Net::HTTP).to receive(:start).with(uri.hostname, uri.port, use_ssl: true).and_call_original
          expect(@http).to receive(:request).and_return(@success)
          helper.fetch(uri)
        end

        it 're-requests on receiving a 1xx' do
          uri = URI('http://example.org/')
          @info = Net::HTTPContinue.allocate
          expect(@http).to receive(:request).with(request_for(uri: uri, headers: { 'User-Agent' => user_agent })).and_return(@info, @success)
          expect(helper.fetch(uri)).to be(@success)
        end

        it 'redirects on receiving a 3xx' do
          uri = URI('http://example.org/')
          uri2 = URI('http://example.org/new')
          @redirect = Net::HTTPMovedPermanently.allocate
          allow(@redirect).to receive(:[]).with('location').and_return(uri2.to_s)
          expect(@http).to receive(:request).with(request_for(uri: uri, headers: { 'User-Agent' => user_agent })).and_return(@redirect)
          expect(@http).to receive(:request).with(request_for(uri: uri2, headers: { 'User-Agent' => user_agent })).and_return(@success)
          expect(helper.fetch(uri)).to be(@success)
        end

        it 'only redirects a limited number of times' do
          uri = URI('http://example.org/')
          @redirect = Net::HTTPMovedPermanently.allocate
          allow(@redirect).to receive(:[]).with('location').and_return(uri.to_s)
          expect(@http).to receive(:request).with(request_for(uri: uri, headers: { 'User-Agent' => user_agent })).exactly(HTTPHelper::DEFAULT_MAX_REDIRECTS).times.and_return(@redirect)
          expect { helper.fetch(uri) }.to raise_error
        end

        it 'fails on a 4xx' do
          @error = Net::HTTPForbidden
          allow(@error).to receive(:code).and_return(403)
          allow(@error).to receive(:message).and_return('Forbidden')
          expect(@http).to receive(:request).and_return(@error)
          uri = URI('http://example.org/')
          expect { helper.fetch(uri) }.to raise_error
        end

        it 'fails on a 5xx' do
          @error = Net::HTTPServerError
          allow(@error).to receive(:code).and_return(500)
          allow(@error).to receive(:message).and_return('Internal Server Error')
          expect(@http).to receive(:request).and_return(@error)
          uri = URI('http://example.org/')
          expect { helper.fetch(uri) }.to raise_error
        end
      end

      describe '#fetch_to_file' do

        # ------------------------------
        # Fixture

        before(:each) do
          @path = nil
          @http = instance_double(Net::HTTP)
          allow(Net::HTTP).to receive(:new).and_return(@http)
          allow(@http).to receive(:start).and_yield(@http)

          @data = (0...100).map { ('a'..'z').to_a[rand(26)] }.join
          @success = Net::HTTPOK.allocate
          allow(@success).to receive(:[]).with('Content-Type').and_return('text/plain')
          stub = allow(@success).to receive(:read_body)
          (0...10).each do |i|
            chunk = @data[10 * i, 10]
            stub = stub.and_yield(chunk)
          end
        end

        after(:each) do
          File.delete(@path) if @path
        end

        # ------------------------------
        # Tests

        it 'requests the specified URI' do
          uri = URI('http://example.org/')
          expect(@http).to receive(:request).with(request_for(uri: uri)).and_return(@success)
          @path = helper.fetch_to_file(uri)
        end

        it 'returns the path to a file containing the response' do
          uri = URI('http://example.org/')
          expect(@http).to receive(:request).with(request_for(uri: uri)).and_return(@success)
          @path = helper.fetch_to_file(uri)
          expect(File.read(@path)).to eq(@data)
        end

        it 'sets the User-Agent header' do
          agent = 'Not Elvis'
          helper = HTTPHelper.new(user_agent: agent)
          expect(@http).to receive(:request).with(request_for(headers: { 'User-Agent' => agent })).and_return(@success)
          @path = helper.fetch_to_file(URI('http://example.org/'))
        end

        it 'uses SSL for https requests' do
          uri = URI('https://example.org/')
          expect(Net::HTTP).to receive(:start).with(uri.hostname, uri.port, use_ssl: true).and_call_original
          expect(@http).to receive(:request).and_return(@success)
          @path = helper.fetch_to_file(uri)
        end

        it 're-requests on receiving a 1xx' do
          uri = URI('http://example.org/')
          @info = Net::HTTPContinue.allocate
          expect(@http).to receive(:request).with(request_for(uri: uri, headers: { 'User-Agent' => user_agent })).and_return(@info, @success)
          @path = helper.fetch_to_file(uri)
          expect(File.read(@path)).to eq(@data)
        end

        it 'redirects on receiving a 3xx' do
          uri = URI('http://example.org/')
          uri2 = URI('http://example.org/new')
          @redirect = Net::HTTPMovedPermanently.allocate
          allow(@redirect).to receive(:[]).with('location').and_return(uri2.to_s)
          expect(@http).to receive(:request).with(request_for(uri: uri, headers: { 'User-Agent' => user_agent })).and_return(@redirect)
          expect(@http).to receive(:request).with(request_for(uri: uri2, headers: { 'User-Agent' => user_agent })).and_return(@success)
          @path = helper.fetch_to_file(uri)
          expect(File.read(@path)).to eq(@data)
        end

        it 'only redirects a limited number of times' do
          uri = URI('http://example.org/')
          @redirect = Net::HTTPMovedPermanently.allocate
          allow(@redirect).to receive(:[]).with('location').and_return(uri.to_s)
          expect(@http).to receive(:request).with(request_for(uri: uri, headers: { 'User-Agent' => user_agent })).exactly(HTTPHelper::DEFAULT_MAX_REDIRECTS).times.and_return(@redirect)
          expect { @path = helper.fetch_to_file(uri) }.to raise_error
          expect(@path).to be_nil
        end

        it 'fails on a 4xx' do
          @error = Net::HTTPForbidden
          allow(@error).to receive(:code).and_return(403)
          allow(@error).to receive(:message).and_return('Forbidden')
          expect(@http).to receive(:request).and_return(@error)
          uri = URI('http://example.org/')
          expect { @path = helper.fetch_to_file(uri) }.to raise_error
          expect(@path).to be_nil
        end

        it 'fails on a 5xx' do
          @error = Net::HTTPServerError
          allow(@error).to receive(:code).and_return(500)
          allow(@error).to receive(:message).and_return('Internal Server Error')
          expect(@http).to receive(:request).and_return(@error)
          uri = URI('http://example.org/')
          expect { helper.fetch_to_file(uri) }.to raise_error
        end
      end

    end
  end
end
