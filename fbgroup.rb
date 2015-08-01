#!/usr/bin/env ruby

require "commander/import"
require "json"
require "fb_graph2"
require "zlib"

program :version, "0.0.2"
program :description, "Facebook group archiving tool"

command :list do |c|
  c.syntax = "fbgroup.rb list -a [access-token]"
  c.description = "Lists all groups available for a given access token"
  c.option "-a STRING", String, "Facebook Graph API access token"

  c.action do |args, options|
    abort "access token required" if options.a.blank?

    groups = FbGraph2::User.me(options.a).fetch.groups

    groups.each do |g|
      puts "#{g.name}: #{g.id}"
    end
  end
end

command :get do |c|
  c.syntax = "fbgroup.rb get -a [access-token] -g [group-id] -d [filename] -e [filename] -f [filename] -m [filename]"
  c.description = "Saves a group to JSON"
  c.option "-a STRING", String, "Facebook Graph API access token"
  c.option "-g STRING", String, "Facebook group ID"
  c.option "-d STRING", String, "Output filename for group documents"
  c.option "-e STRING", String, "Output filename for group events"
  c.option "-f STRING", String, "Output filename for group feed"
  c.option "-m STRING", String, "Output filename for group members"
  c.option "-z", "Compress output with Zlib"

  c.action do |args, options|
    abort "access token required" if options.a.blank?
    abort "group ID required" if options.g.blank?

    options.z.blank? ? zlib = false : zlib = true

    me = FbGraph2::User.me(options.a).fetch
    group = FbGraph2::Page.search(options.g, options.a)
    group = group.first
    group.access_token = options.a

    def write_json json, file, zlib
      if zlib
        Zlib::GzipWriter.open file do |f|
          f.write JSON.pretty_generate(JSON.parse(json))
        end
      else
        File.open file, "w" do |f|
          f.write JSON.pretty_generate(JSON.parse(json))
        end
      end

      File.size(file)
    end

    def edge_to_json edge
      output = Array.new

      while edge.any? do
        output << edge
        edge = edge.next
      end

      output.to_json
    end

    unless options.d.blank?
      print "* Getting group documents... "
      size = write_json edge_to_json(group.docs), options.d, zlib
      puts "done (#{size} bytes)"
    end

    unless options.e.blank?
      print "* Getting group events... "
      size = write_json edge_to_json(group.events), options.e, zlib
      puts "done (#{size} bytes)"
    end

    unless options.f.blank?
      print "* Getting group feed... "
      size = write_json edge_to_json(group.feed), options.f, zlib
      puts "done (#{size} bytes)"
    end

    unless options.m.blank?
      print "* Getting group members... "
      size = write_json edge_to_json(group.members), options.m, zlib
      puts "done (#{size} bytes)"
    end
  end
end
