require 'djinn/base'

module Djinn

  include Djinn::Base

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
