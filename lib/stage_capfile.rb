module StageCapfile

  require "#{RAILS_ROOT}/app/helpers/stages_helper.rb"
  require 'ftools'

  include StagesHelper
  include ERB::Util

  def write(stage) 
    begin
      b = binding
      @stage = stage
      @template = ERB.new(File.open("#{RAILS_ROOT}/app/views/stages/capfile.html.erb") { |io| io.read })
      result = @template.result(b)
      dir = "#{RAILS_ROOT}/capfile/#{@stage.project.name}/#{@stage.name}" 
      FileUtils.mkdir_p dir 
      File.open("#{dir}/Capfile", "w") { |io| io.puts result }
      result
    rescue => msg
      nil
    end
  end

  def delete(stage)
    @stage = stage
    FileUtils.rm_rf("#{RAILS_ROOT}/capfile/#{@stage.project.name}/#{@stage.name}")
  end

  module_function :write
  module_function :capfile_cast
  module_function :h
  module_function :delete

end
