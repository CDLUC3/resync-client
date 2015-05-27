require 'resync'

module Resync

  class Augmented
    attr_writer :client

    def client
      @client ||= Client.new
    end

    alias_method :base_links=, :links=
    def links=(value)
      self.base_links = value
      links.each do |l|
        l.instance_variable_set('@container', self)
        def l.client
          @container.client
        end
      end
    end
  end

  class BaseResourceList
    alias_method :base_resources=, :resources=
    def resources=(value)
      self.base_resources = value
      resources.each do |r|
        r.instance_variable_set('@container', self)
        def r.client
          @container.client
        end
      end
    end
  end

  class Resource
    def get
      client.get(uri)
    end

    def get_raw # rubocop:disable Style/AccessorMethodName
      client.get_raw(uri)
    end
  end

  class Link
    def get
      client.get(href)
    end

    def get_raw # rubocop:disable Style/AccessorMethodName
      client.get_raw(href)
    end
  end

end
