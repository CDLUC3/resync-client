require 'rspec/core'
require 'resync'

# List of TODO items in spec form
describe Resync do

  describe 'library' do
    describe 'change lists' do
      it 'can get the set of all resource URIs (collapsing URIs with multiple changes)'
      it 'can find the most recent change for a given URI'
    end

    it 'enforces the required/forbidden time attribute table in appendix a of the spec'
  end

  describe 'client' do
    describe 'discovery' do
      it 'retrieves a Source Description from a URI'
    end

    describe 'capability lists' do
      it 'retrieves a Capability List from a URI'
    end

    describe 'resource lists' do
      it 'retrieves a Resource List from a URI'
    end

    describe 'resource list indices' do
      it 'retrieves a Resource List Index from a URI'
    end

    describe 'resource dumps' do
      it 'retrieves a Resource Dump from a URI'
      describe 'bitstream packages' do
        it 'can download and cache a bitstream package'
        it 'can extract a resource dump manifest from a ZIP bitstream package'
        it 'can extract a resource from a ZIP bitstream package based on a path in a manifest'
      end
    end

    describe 'resource dump manifests' do
      it 'retrieves a Resource Dump Manifest from a URI'
    end

    describe 'change lists' do
      it 'retrieves a Change List from a URI'
    end

    describe 'change list indices' do
      it 'retrieves a Change List Index from a URI'
    end

    describe 'change dumps' do
      it 'retrieves a Change Dump from a URI'
      describe 'bitstream packages' do
        it 'gets the "contents" link URI for the change dump manifest, if present'
        it 'can download and cache a bitstream package'
        it 'can extract a change dump manifest from a ZIP bitstream package'
        it 'can extract a resource from a ZIP bitstream package based on a path in a manifest'
      end
    end

    describe 'change dump manifests' do
      it 'retrieves a Change Dump Manifest from a URI'
    end

    describe 'error handling' do
      it 'handles server errors gracefully'
    end

    it 'does something clever for mirrors, alternate representations, and related resources'

  end

end
