#!/usr/bin/env ruby
# this script is only ever meant to be called via script/spin

require 'daemons'
Daemons.run(File.dirname(__FILE__) + '/../lib/schedule_deployments.rb', { :dir => File.dirname(__FILE__) + '/../../tmp/pids' } )

