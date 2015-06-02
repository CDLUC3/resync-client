# resync-client

A gem providing a Ruby client for the [ResourceSync](http://www.openarchives.org/rs/1.0/resourcesync) web synchronization framework, based on the [resync](https://github.com/dmolesUC3/resync) gem and [Net::HTTP](http://ruby-doc.org/stdlib-2.2.2/libdoc/net/http/rdoc/Net/HTTP.html).

## Usage

Retrieving the [Source Description](http://www.openarchives.org/rs/1.0/resourcesync#wellknown) for a site:

```ruby
client = Resync::Client.new

source_desc_uri = 'http://example.org/.well-known/resourcesync'
source_desc = client.get_and_parse(source_desc_uri) # => Resync::SourceDescription
```

Retrieving a [Capability List](http://www.openarchives.org/rs/1.0/resourcesync#CapabilityList) from the source description:

```ruby
cap_list_resource = source_desc.resource_for(capability: 'capabilitylist')
cap_list = cap_list_resource.get_and_parse # => Resync::CapabilityList
```

Retrieving a [Change List](http://www.openarchives.org/rs/1.0/resourcesync#ChangeList) and downloading the latest revision of a known resource to a file

```ruby
change_list_resource = cap_list.resource_for(capability: 'changelist')
change_list = change_list_resource.get_and_parse # => Resync::ChangeList
latest_rev_resource = change_list.latest_for(uri: URI('http://example.com/my-resource'))
latest_rev_resource.download_to_file('/tmp/my-resource.txt')
```

Retrieving a [Change Dump](http://www.openarchives.org/rs/1.0/resourcesync#ChangeDump), searching through its manifests for changes to a specified URL, downloading the ZIP package containing that resource, and extracting it from the ZIP package:

```ruby
change_dump_resource = cap_list.resource_for(capability: 'changedump')
change_dump = change_dump_resource.get_and_parse # => Resync::ChangeDump
change_dump.resources.each do |package|
  manifest_link = package.link_for(rel: 'contents')
  if manifest_link
    manifest = manifest_link.get_and_parse # => Resync::ChangeDumpManifest
    latest_resource = manifest.latest_for(uri: URI('http://example.com/my-resource'))
    if latest_resource
      timestamp = latest_resource.modified_time.strftime('%s%3N')
      zip_package = package.zip_package # => Resync::ZipPackage (downloaded to temp file)
      bitstream = zip_package.bitstream_for(latest_resource) # => Resync::Bitstream
      content = bitstream.content # => String (extracted from ZIP file)
      File.open("/tmp/my-resource-#{timestamp}.txt") { |f| f.write(content) }
    end
  end
end
```

## Status

This is a work in progress -- bug reports and feature requests are welcome. It's still a prototype, and hasn't really been tested except with [resync-simulator](https://github.com/resync/resync-simulator) -- and that not much beyond what you'll find in [example.rb](example.rb). So expect some trouble. `:)`

