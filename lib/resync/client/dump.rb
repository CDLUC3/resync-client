require_relative 'zip_packages'

module Resync
  # Extends {ChangeDump} and {ResourceDump} to provide
  # transparent access to the linked bitstream packages
  module Dump
    # Injects a +:zip_package+ method into each resource,
    # downloading the (presumed) bitstream package to a
    # temp file and returning it as a {ZipPackage}
    def resources=(value)
      super
      resources.each do |r|
        def r.zip_package
          @zip_package ||= ZipPackage.new(download_to_temp_file)
        end
      end
    end

    # A list (downloaded lazily) of the {ZipPackage}s for each resource
    # @return [ZipPackages] the zip packages for each resource
    def zip_packages
      @zip_packages ||= ZipPackages.new(resources)
    end
  end

end
