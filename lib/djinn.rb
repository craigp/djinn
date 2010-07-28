$:.unshift(File.dirname(__FILE__))

require 'yaml'
require 'djinn/base'
require 'djinn/dsl'

# In Arabian mythology a Djinn is a supernatural creature which occupies a 
# parallel world to that of mankind
module Djinn

  include Djinn::Base
  
  def self.included(base)
    base.extend Djinn::Dsl
  end

  private
  
    def get_pidfile config
      pid_file_path = config['pid_file_path'] || 
        File.join(Dir.pwd, "#{name}.pid")
      PidFile.new(pid_file_path)
    end

    def get_logfile config
      log_file_path = config['log_file_path'] || 
        File.join(Dir.pwd, "#{name}.log")
      log_file_path
    end

    def load_config
      config_path = File.join(Dir.pwd, "#{name}.yml")
      if File.exists?(config_path)
        YAML.load_file(config_path)
      else
        {}
      end
    end

end
