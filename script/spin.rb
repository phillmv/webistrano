#!/usr/bin/env ruby
# script for 'spinning up' server
# USAGE - script/spin.rb up [flags passed to mongrel]
# script/spin.rb down

if (first = ARGV.shift) == "up"

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
elsif first == "down"
  printf "Sending SIGKILL to mongrel... "
  if system "cd #{File.dirname(__FILE__)}/.. && kill -9 `cat tmp/pid/mongrel.pid` && rm tmp/pid/mongrel.pid" then 
    puts "done." 
  else 
    puts "unsuccesful." 
  end
  printf "Stopping scheduler daemon... "
  if system "cd #{File.dirname(__FILE__)}/.. && ruby script/scheduler_control.rb stop" then
    puts "done."
  else
    puts "unsuccesful."
  end
else
  puts "USAGE:\nscript/spin.rb up [flags passed to script/server]\nscript/spin.rb down"
end





