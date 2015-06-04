require 'resync'
require_relative 'client'
require_relative 'zip_package'

module Resync

  # An object that delegates to another to provide a {Client} for downloading
  # resources and links.
  #
  # @!attribute [rw] client_delegate
  #   @return [#client] The client provider.
  module ClientDelegator
    attr_accessor :client_delegate
    def client
      client_delegate.client
    end

    # Creates a one-off delegate wrapper around the specified {Client}
    # @param value [Client] the client
    def client=(value)
      @client_delegate = ClientDelegate.new(value)
    end

    # Minimal 'delegate' wrapper around a specified {Client}
    class ClientDelegate
      # @return [#client] the client
      attr_reader :client

      # Creates a new {ClientDelegate} wrapping the specified {Client}
      # @param client The client to delegate to
      def initialize(client)
        @client = client
      end
    end
  end

  # A downloadable resource or link.
  module Downloadable
    prepend ClientDelegator

    # Delegates to {Client#get_and_parse} to get the contents of
    # +:uri+ as a ResourceSync document
    def get_and_parse # rubocop:disable Style/AccessorMethodName
      client.get_and_parse(uri)
    end

    # Delegates to {Client#get} to get the contents of this +:uri+
    def get # rubocop:disable Style/AccessorMethodName
      client.get(uri)
    end

    # Delegates to {Client#download_to_temp_file} to download the
    # contents of +:uri+ to a file.
    def download_to_temp_file # rubocop:disable Style/AccessorMethodName
      client.download_to_temp_file(uri)
    end

    # Delegates to {Client#download_to_file} to download the
    # contents of +:uri+ to the specified path.
    # @param path [String] the path to download to
    def download_to_file(path)
      client.download_to_file(uri: uri, path: path)
    end
  end

  # A resource that refers to a zipped bitstream package.
  module ZippedResource
    prepend Downloadable

    # Provides the contents of this resource as a {ZipPackage}, downloading
    # it to a temporary file if necessary.
    # @return [ZipPackage] the zipped contents of this resource
    def zip_package
      @zip_package ||= ZipPackage.new(download_to_temp_file)
    end
  end

  # A list of resources each of which refers to a zipped bitstream package.
  module ZippedResourceList
    # Makes each provided resource a {ZippedResource}
    # @param value [Array<Resource>] the resources for this list
    def resources=(value)
      super
      resources.each do |r|
        class << r
          prepend ZippedResource
        end
      end
    end

    # A list (downloaded lazily) of the {ZipPackage}s for each resource
    # @return [ZipPackages] the zip packages for each resource
    def zip_packages
      @zip_packages ||= ZipPackages.new(resources)
    end
  end

  # A resource that refers to a bitsream within a zipped bitstream package.
  #
  # @!attribute [rw] zip_package_delegate
  #   @return [ZipPackage] the provider of the containing package,
  #   e.g. its manifest
  module BitstreamResource
    attr_accessor :zip_package_delegate

    # @return [ZipPackage] the package containing the bitstream for this resource
    def containing_package
      @zip_package_delegate.zip_package
    end

    # @return [Bitstream] the bitstream for this resource
    def bitstream
      containing_package.bitstream_for(self)
    end
  end

  # A list of resources within a single zipped bitstream package, e.g. as provided
  # by the package manifest.
  #
  # @!attribute [rw] zip_package
  #   @return [ZipPackage] the package.
  module BitstreamResourceList
    attr_accessor :zip_package

    # Makes each provided resource a {BitstreamResource}
    # @param value [Array<Resource>] the resources for this list
    def resources=(value)
      super
      resources.each do |r|
        class << r
          prepend BitstreamResource
        end
        r.zip_package_delegate = self
      end
    end
  end

  # A resource container that is capable of providing those resources with a {Client}
  module ResourceClientDelegate
    prepend ClientDelegator

    # Sets this object as the client provider delegate for each resource.
    # @param value [Array<Resource>] the resources for this list
    def resources=(value)
      super
      resources.each { |r| r.client_delegate = self }
    end
  end

  # A link container that is capable of providing those resources with a {Client}
  module LinkClientDelegate
    prepend ClientDelegator

    # Sets this object as the client provider delegate for each link.
    # @param value [Array<Link>] the links for this list
    def links=(value)
      super
      links.each { |l| l.client_delegate = self }
    end
  end
end
