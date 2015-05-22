# A Ruby client for the {http://www.openarchives.org/rs/1.0/resourcesync ResourceSync} web synchronization framework.
module Resync
  module Client
    Dir.glob(File.expand_path('../client/*.rb', __FILE__), &method(:require))
  end
end
