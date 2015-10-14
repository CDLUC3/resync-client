Dir.glob(File.expand_path('../mixins/*.rb', __FILE__)).sort.each(&method(:require))
