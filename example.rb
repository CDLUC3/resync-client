#!/usr/bin/env ruby

fail Exception, 'resync-client requires Ruby 2.2' unless RUBY_VERSION =~ /^2.2/

# Note: This assumes we're running from the root of the resync-client project
$LOAD_PATH << File.dirname(__FILE__)
require 'lib/resync/client'

client = Resync::Client.new

source_desc_uri = 'http://localhost:8888/.well-known/resourcesync'
puts "Source: #{source_desc_uri}"
source_desc = client.get(source_desc_uri)

desc_ln = source_desc.links.find { |ln| ln.rel == 'describedby' }
puts "  Described by: #{desc_ln.href}"

cap_list_uri = source_desc.resources.find { |r| r.metadata.capability == 'capabilitylist' }.uri
puts "Capability list: #{cap_list_uri}"
cap_list = client.get(cap_list_uri)

change_list_uri = cap_list.resources.find { |r| r.metadata.capability == 'changelist' }.uri
puts "Change list: #{change_list_uri}"
change_list = client.get(change_list_uri)

puts "  from:  #{change_list.metadata.from_time}"
puts "  until: #{change_list.metadata.until_time}"
changes = change_list.resources
puts "  #{changes.size} total changes"

last = changes.size > 5 ? 5 : changes.size
puts "last #{last} changes:"
changes.slice(-last, last).each do |r|
  puts "  #{r.uri}"
  puts "    modified at: #{r.modified_time}"
  puts "    change type: #{r.metadata.change}"
  puts "    md5:         #{r.metadata.hash('md5')}"
end
