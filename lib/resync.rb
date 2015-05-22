# A Ruby gem for working with the {http://www.openarchives.org/rs/1.0/resourcesync ResourceSync} web synchronization framework.
module Resync
  Dir.glob(File.expand_path('../resync/*.rb', __FILE__), &method(:require))
end
