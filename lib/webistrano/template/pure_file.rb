module Webistrano
  module Template
    module PureFile
      
      CONFIG = Webistrano::Template::Base::CONFIG.dup.merge({
      }).freeze
      
      DESC = <<-'EOS'
        Template for use with non-rails projects that just update 'pure' files.
        The basic (re)start/stop tasks of Capistrano are overrided with NOP tasks.
      EOS
      
      TASKS = Webistrano::Template::Base::TASKS + <<-'EOS'
      EOS
    
    end
  end
end
