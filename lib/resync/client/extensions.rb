require_relative 'mixins'

module Resync
  class Link
    prepend Downloadable
  end

  class Augmented
    prepend LinkClientDelegate
  end

  class Resource
    prepend Downloadable
  end

  class BaseResourceList
    prepend ResourceClientDelegate
  end

  class ResourceDump
    prepend ZippedResourceList
  end

  class ChangeDump
    prepend ZippedResourceList
  end

  class ResourceDumpManifest
    prepend BitstreamResourceList
  end

  class ChangeDumpManifest
    prepend BitstreamResourceList
  end
end
