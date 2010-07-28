$:.unshift(File.dirname(__FILE__))

require 'yaml'
require 'djinn/base'
require 'djinn/dsl'

# This is a base implementation which handles looking for config
# files and sets up the default locations for pid and log files
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
