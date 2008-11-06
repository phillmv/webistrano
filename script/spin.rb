#!/usr/bin/env ruby
# script for 'spinning up' server
env = nil
ARGV.each_with_index { |a, i| 
  if a == "-e" || a == "--environment" 
    env = ARGV[i+1] 
  elsif a.index "--environment="
    env = a.sub "--environment=", ""
  end 
}
env ||= "development"


system "cd #{File.dirname(__FILE__)}/.. && ruby script/runner -e #{env} \"`cat lib/stage_capfile.rb`; Stage.find(:all).each { |stg| stg.write_capfile }\" &"
system "cd #{File.dirname(__FILE__)}/.. && ruby script/scheduler_control.rb start -- #{env} &"
require File.dirname(__FILE__) + '/../config/boot'
require 'commands/server'
