module Djinn
  module Rails
    class Base

      require 'yaml'
      require 'daemon'
      require 'pid_file'
      require 'daemon_logging'

      extend Djinn::Daemon
      include Djinn::LoggingHelpers
  
      def log m
        DaemonBase.log m
      end
    
      class << self
    
        def log m
          puts "#{Time.now.strftime("%m/%d/%Y %H:%M:%S")}: #{m}"
          STDOUT.flush
        end
    
        def perform config
          raise "Not implemented"
        end
  
        def start
          log "Starting #{underscore(self.name)} in the background.."
          config = load_config
          logfile = get_logfile(config)
          daemonize(config, logfile, get_pidfile(config)) do
            load_rails
            self.new(config).do_stuff
          end
        end
  
        def run
          log "Starting #{underscore(self.name)} in the foreground.."
          load_rails
          self.new(load_config).do_stuff
        end
  
        def restart
          stop
          start
        end
  
        def stop
          pidfile = get_pidfile(load_config)
          log 'No such process' and exit unless pidfile.pid
          begin
            log "Sending TERM signal to process #{pidfile.pid}"
            Process.kill("TERM", pidfile.pid)
          rescue
            log 'Could not find process'
          ensure
            pidfile.remove
          end
        end
    
        private
    
        def get_pidfile(config)
          PidFile.new(File.join(File.dirname(__FILE__), '..', '..', 'log', config['pid_file']))
        end
    
        def get_logfile(config)
          File.join(File.dirname(__FILE__), '..', '..', 'log', config['log_file'])
        end
    
        def load_rails
          log "Loading Rails in #{ENV['RAILS_ENV']} environment"
          require File.join(File.dirname(__FILE__), '..', '..', 'config', 'environment')
        end
    
        def load_config
          path = File.join(File.dirname(__FILE__), '..', '..', 'config', "#{underscore(self.name)}.yml")
          unless File.exists?(path)
            log "No config file for daemon: #{path}"
            exit(1)
          else
            YAML.load_file(path)[ENV['RAILS_ENV']]
          end
        end
    
        def underscore(camel_cased_word)
          camel_cased_word.to_s.gsub(/::/, '/').
            gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
            gsub(/([a-z\d])([A-Z])/,'\1_\2').
            tr("-", "_").
            downcase
        end
      
      end
  
    end
  end
end