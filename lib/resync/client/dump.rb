require_relative 'zip_package'

module Resync
  module Dump
    def resources=(value)
      super
      resources.each do |r|
        def r.zip_package
          @zip_package ||= ZipPackage.new(get_file)
        end
      end
    end

    def zip_packages
      resources.map(&:zip_package)
    end
  end
end
