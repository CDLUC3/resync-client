#!/usr/bin/env ruby

# Note: This assumes we're running from the root of the resync-client project
$LOAD_PATH << File.dirname(__FILE__)
require 'lib/resync/client'

client = Resync::Client.new

# Note: this URI is from resync-simulator: https://github.com/resync/resync-simulator
source_desc_uri = 'http://localhost:8888/.well-known/resourcesync'
puts "Source: #{source_desc_uri}"
source_desc = client.get_and_parse(source_desc_uri) # Resync::SourceDescription

cap_list_resource = source_desc.resource_for(capability: 'capabilitylist')
cap_list = cap_list_resource.get_and_parse # Resync::CapabilityList

change_list_resource = cap_list.resource_for(capability: 'changelist')
change_list = change_list_resource.get_and_parse # Resync::ChangeList
puts "  from:    #{change_list.metadata.from_time}"
puts "  until:   #{change_list.metadata.until_time}"

changes = change_list.resources # Array<Resync::Resource>
puts "  changes: #{changes.size}"
puts

n = changes.size > 5 ? 5 : changes.size
puts "last #{n} changes of any kind:"
changes.slice(-n, n).each do |r|
  puts "  #{r.uri}"
  puts "    modified at: #{r.modified_time}"
  puts "    change type: #{r.metadata.change}"
  puts "    md5:         #{r.metadata.hash('md5')}"
end

last_update = changes.select { |r| r.metadata.change == Resync::Types::Change::UPDATED }[-1]
puts 'last update:'
puts "  #{last_update.uri}"
puts "    modified at: #{last_update.modified_time}"
puts "    change type: #{last_update.metadata.change}"
puts "    md5:         #{last_update.metadata.hash('md5')}"

last_update_response = last_update.get
puts last_update_response.class
puts "    content:     #{last_update_response}"

last_update_file = last_update.download_to_temp_file
puts "    as file:     #{last_update_file}"
