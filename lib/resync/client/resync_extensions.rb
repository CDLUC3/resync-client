require 'resync'
require_relative 'downloadable'
require_relative 'dump'

# Extensions to the core Resync classes to simplify retrieval
module Resync

  # ------------------------------------------------------------
  # Base classes

  # Injects a {Client} that subclasses can use to fetch
  # resources and links
  #
  # @!attribute [rw] client
  #   @return [Client] the injected {Client}. Defaults to
  #     a new {Client} instance.
  class Augmented
    attr_writer :client

    def client
      @client ||= Client.new
    end

    alias_method :base_links=, :links=
    private :base_links=

    # Adds a +:client+ method to each link, delegating
    # to {#client}
    def links=(value)
      self.base_links = value
      self.base_links = value
      parent = self
      links.each do |l|
        l.define_singleton_method(:client) do
          parent.client
        end
      end
    end
  end

  # Adds a +:client+ method to each resource, delegating
  # to {Augmented#client}
  class BaseResourceList
    alias_method :base_resources=, :resources=
    private :base_resources=

    # Adds a +:client+ method to each resource, delegating
    # to {Augmented#client}
    def resources=(value)
      self.base_resources = value
      parent = self
      resources.each do |r|
        r.define_singleton_method(:client) do
          parent.client
        end
      end
    end
  end

  # ------------------------------------------------------------
  # Resource and Link

  # Includes the {Downloadable} module
  class Resource
    include Downloadable
  end

  # Includes the {Link} module
  class Link
    include Downloadable
  end

  # ------------------------------------------------------------
  # ResourceDump and ChaneDump

  # Includes the {Dump} module
  class ResourceDump
    include Dump
  end

  # Includes the {Dump} module
  class ChangeDump
    include Dump
  end
end
