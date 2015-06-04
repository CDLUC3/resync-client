require_relative 'client'
require_relative 'zip_package'
require_relative 'zip_packages'

module Resync
  module Extensions

    # Injects a {Client} that subclasses can use to fetch
    # resources and links
    #
    # @!attribute [rw] client
    #   @return [Client] the injected {Client}. Defaults to
    #     a new {Client} instance.
    module WithClient
      attr_writer :client

      def client
        @client ||= Client.new
      end
    end

    # Allows a delegate to provide a {Client}. The delegate
    # can be any object with a +:client+ method.
    #
    # @!attribute [rw] client
    #   @return [Client] the delegate's {Client}.
    module WithClientDelegate
      attr_writer :client_delegate

      def client
        @client_delegate.client
      end
    end

    # Adds +get+, +get_raw+, and +get_file+ methods, delegating
    # to the injected client.
    #
    # @see Augmented#client
    module Downloadable
      include WithClient

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

    module WithZipPackages
      # A list (downloaded lazily) of the {ZipPackage}s for each resource
      # @return [ZipPackages] the zip packages for each resource
      def zip_packages
        @zip_packages ||= ZipPackages.new(resources)
      end
    end

    module WithZipPackage
      include Downloadable

      # Gets this {Downloadable} as a {ZipPackage}. The zip package
      # is downloaded only once.
      # @return [ZipPackage] a {ZipPackage} wrapping the contents of this
      #   {Downloadable}.
      def zip_package
        @zip_package ||= ZipPackage.new(download_to_temp_file)
      end
    end

    module Dump
      include Extensions::WithZipPackages

      # Injects a +:zip_package+ method into each resource,
      # downloading the (presumed) bitstream package to a
      # temp file and returning it as a {ZipPackage}
      def resources=(value)
        # TODO: why does this work?
        # TODO: why don't we need alias_method cf. resync_extensions.rb?
        super
        resources.each do |r|
          class << r
            include Extensions::WithZipPackage
          end
          # r.define_singleton_method(:zip_package) do
          #   @zip_package ||= ZipPackage.new(download_to_temp_file)
          # end
        end
      end

      # A list (downloaded lazily) of the {ZipPackage}s for each resource
      # @return [ZipPackages] the zip packages for each resource
      # def zip_packages
      #   @zip_packages ||= ZipPackages.new(resources)
      # end
    end

  end
end
