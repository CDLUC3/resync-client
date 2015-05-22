require 'resync'

Dir.glob(File.expand_path('../client/*.rb', __FILE__), &method(:require))
