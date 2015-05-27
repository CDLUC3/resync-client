require 'resync'
require_relative 'dump'

module Resync

  class Augmented
    attr_writer :client

    def client
      @client ||= Client.new
    end

    alias_method :base_links=, :links=
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

  class BaseResourceList
    alias_method :base_resources=, :resources=
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

  # TODO: abstract these into a module
  class Resource
    def get
      client.get(uri)
    end

    def get_raw # rubocop:disable Style/AccessorMethodName
      client.get_raw(uri)
    end

    def get_file # rubocop:disable Style/AccessorMethodName
      client.get_file(uri)
    end
  end

  class Link
    def get
      client.get(href)
    end

    def get_raw # rubocop:disable Style/AccessorMethodName
      client.get_raw(href)
    end

    def get_file # rubocop:disable Style/AccessorMethodName
      client.get_file(uri)
    end
  end

  class ResourceDump
    include Dump
  end

  class ChangeDump
    include Dump
  end
end
