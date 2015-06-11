require 'resync'
require_relative 'client/mixins'

module Resync
  class Link
    prepend Client::Mixins::Downloadable
  end

  class Augmented
    prepend Client::Mixins::LinkClientDelegate
  end

  class Resource
    prepend Client::Mixins::Downloadable
  end

  class BaseResourceList
    prepend Client::Mixins::ResourceClientDelegate
  end

  class ResourceDump
    prepend Client::Mixins::ZippedResourceList
  end

  class ChangeDump
    prepend Client::Mixins::ZippedResourceList
  end

  class ResourceDumpManifest
    prepend Client::Mixins::BitstreamResourceList
  end

  class ChangeDumpManifest
    prepend Client::Mixins::BitstreamResourceList
  end

  class CapabilityList
    prepend Client::Mixins::ListOfResourceLists
  end

  class ChangeListIndex
    prepend Client::Mixins::ListOfResourceLists
  end

  class ResourceListIndex
    prepend Client::Mixins::ListOfResourceLists
  end

  class SourceDescription
    prepend Client::Mixins::ListOfResourceLists
  end
end
