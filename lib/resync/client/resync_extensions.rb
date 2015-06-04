require 'resync'
require_relative 'extensions'

# Extensions to the core Resync classes to simplify retrieval
module Resync

  # ------------------------------------------------------------
  # Base classes

  # Injects a {Client} that subclasses can use to fetch
  # resources and links
  class Augmented
    include Extensions::WithClient

    alias_method :base_links=, :links=
    private :base_links=

    # Adds a +:client+ method to each link, delegating
    # to {Extensions::WithClient#client}
    def links=(value)
      self.base_links = value
      links.each do |l|
        class << l
          include Extensions::WithClientDelegate
        end
        l.client_delegate = self
      end
    end
  end

  # Adds a +:client+ method to each resource, delegating
  # to {Extensions::WithClient#client}
  class BaseResourceList
    alias_method :base_resources=, :resources=
    private :base_resources=

    # Adds a +:client+ method to each resource, delegating
    # to {Extensions::WithClient#client}
    def resources=(value)
      self.base_resources = value
      resources.each do |r|
        class << r
          include Extensions::WithClientDelegate
        end
        r.client_delegate = self
      end
    end
  end

  # ------------------------------------------------------------
  # Resource and Link

  # Includes the {Downloadable} module
  class Resource
    include Extensions::Downloadable
  end

  # Includes the {Link} module
  class Link
    include Extensions::Downloadable
  end

  # ------------------------------------------------------------
  # ResourceDump and ChaneDump

  # Includes the {Dump} module
  class ResourceDump
    include Extensions::Dump
  end

  # Includes the {Dump} module
  class ChangeDump
    include Extensions::Dump
  end
end
