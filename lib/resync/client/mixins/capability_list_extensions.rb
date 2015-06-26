require 'resync'

module Resync
  class CapabilityList

    # Downloads and parses the document for the specified capability.
    # Subsequent calls will return the same parsed object.
    # @return [ResourceList, ResourceListIndex, ChangeList, ChangeListIndex, ResourceDump, ResourceDumpIndex, ChangeDump, ChangeDumpIndex, nil]
    #   the document, or +nil+ if this capability list does not provide that capability
    def document_for(capability)
      @documents ||= {}
      @documents[capability] ||= get_and_parse_resource_for(capability)
    end

    # Downloads and parses the resource list or resource list index.
    # Subsequent calls will return the same parsed object.
    # @return [ResourceList, ResourceListIndex, nil] the resource list, or +nil+ if this capability list does not
    #   provide one
    def resource_list
      document_for(ResourceList::CAPABILITY)
    end

    # Downloads and parses the change list or change list index.
    # Subsequent calls will return the same parsed object.
    # @return [ChangeList, ChangeListIndex, nil] the change list, or +nil+ if this capability list does not
    #   provide one
    def change_list
      document_for(ChangeList::CAPABILITY)
    end

    # Downloads and parses the resource dump or resource dump index.
    # Subsequent calls will return the same parsed object.
    # @return [ResourceDump, ResourceDumpIndex, nil] the resource dump, or +nil+ if this capability dump does not
    #   provide one
    def resource_dump
      document_for(ResourceDump::CAPABILITY)
    end

    # Downloads and parses the change dump or change dump index.
    # Subsequent calls will return the same parsed object.
    # @return [ChangeDump, ChangeDumpIndex, nil] the change dump, or +nil+ if this capability dump does not
    #   provide one
    def change_dump
      document_for(ChangeDump::CAPABILITY)
    end

    private

    def get_and_parse_resource_for(capability)
      resource = resource_for(capability: capability)
      resource.get_and_parse if resource
    end

  end
end
