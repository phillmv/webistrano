#!/usr/bin/env ruby

require 'optparse'
# so we need to import a rails env to start up the thingy. Maybe wrap it in a daemonise script? write that one first.

env = nil
ARGV.clone.options do |opts|
  opts.on("-e",
	  "--environment=name",
	  String,
	  "specifies the env to run this server under (test/development/production)",
	  "Default: development") { |v| env = v }
  opts.parse!
end

system "cd #{File.dirname(__FILE__)}/.. && ./script/foo.rb #{env} &"
require File.dirname(__FILE__) + '/../config/boot'
require 'commands/server'
