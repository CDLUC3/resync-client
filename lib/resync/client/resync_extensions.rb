require 'resync'
require_relative 'dump'

# Extensions to the core Resync classes to simplify retrieval
module Resync

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

  # Adds +get+, +get_raw+, and +get_file+ methods, delegating
  # to the injected client.
  #
  # @see Augmented#client
  class Resource

    # Delegates to {Client#get} to get the contents of
    # this resource
    def get
      client.get(uri)
    end

    # Delegates to {Client#get_raw} to get this link as
    # a {http://ruby-doc.org/stdlib-2.2.2/libdoc/net/http/rdoc/Net/HTTPResponse.html Net::HTTPResponse}
    def get_raw # rubocop:disable Style/AccessorMethodName
      client.get_raw(uri)
    end

    # Delegates to {Client#get_file} to download this
    # resource to a file.
    def get_file # rubocop:disable Style/AccessorMethodName
      client.get_file(uri)
    end
  end

  # Adds +get+, +get_raw+, and +get_file+ methods, delegating
  # to the injected client.
  #
  # @see Augmented#client
  class Link

    # Delegates to {Client#get} to get the contents of
    # this link
    def get
      client.get(href)
    end

    # Delegates to {Client#get_raw} to get this resource as
    # a {http://ruby-doc.org/stdlib-2.2.2/libdoc/net/http/rdoc/Net/HTTPResponse.html Net::HTTPResponse}
    def get_raw # rubocop:disable Style/AccessorMethodName
      client.get_raw(href)
    end

    # Delegates to {Client#get_file} to download this
    # link to a file.
    def get_file # rubocop:disable Style/AccessorMethodName
      client.get_file(href)
    end
  end

  # Includes the {Dump} module
  class ResourceDump
    include Dump
  end

  # Includes the {Dump} module
  class ChangeDump
    include Dump
  end
end
