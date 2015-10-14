Dir.glob(File.expand_path('../zip/*.rb', __FILE__)).sort.each(&method(:require))
