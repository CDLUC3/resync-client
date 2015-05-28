require 'spec_helper'

module Resync
  class Client
    describe HTTPHelper do

      describe '#fetch' do
        it 'gets a response'
        it 'sets the User-Agent header'
        it 'uses SSL for https requests'
        it 're-requests on receiving a 1xx'
        it 'redirects on receiving a 3xx'
        it 'only redirects a limited number of times'
        it 'fails on a 4xx'
        it 'fails on a 5xx'
      end

      describe '#fetch_to_file' do
        it 'returns the path to a file containing the response'
        it 'sets the User-Agent header'
        it 'uses SSL for https requests'
        it 're-requests on receiving a 1xx'
        it 'redirects on receiving a 3xx'
        it 'only redirects a limited number of times'
        it 'fails on a 4xx'
        it 'fails on a 5xx'
      end

    end
  end
end
