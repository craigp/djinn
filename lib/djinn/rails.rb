$:.unshift(File.join(File.dirname(__FILE__)))

require 'yaml'

require 'base'
require 'rails/handlers'
require 'dsl'

module Djinn
  # The basis for all Djinn that want to soar among the Rails stars
  module Rails
    
    include Djinn::Base

    def self.included(base)
      base.__send__(:extend, Djinn::Rails::Handlers)
      base.__send__(:extend, Djinn::Dsl)
    end
        
    RAILS_ROOT = File.expand_path(Dir.pwd) unless defined?(RAILS_ROOT)
    
    private
        
      def get_pidfile(config)
        pid_file = config['pid_file'] || "#{name}.pid"
        PidFile.new(File.join(RAILS_ROOT, 'log', pid_file))
      end

      def get_logfile(config)
        log_file = config['log_file'] || "#{name}.log"
        File.join(RAILS_ROOT, 'log', log_file)
      end

      def load_config
        path = File.join(RAILS_ROOT, 'config', "#{underscore(self.name)}.yml")
        if File.exists?(path)
          YAML.load_file(path)[ENV['RAILS_ENV']]
        else
          log "No config file found for djinn"
          {}          
        end
      end
      
  end
end