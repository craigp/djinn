$:.unshift(File.dirname(__FILE__))

require 'tonic'
require 'pid_file'
require 'logging'

module Djinn
  module Base
    
    include Djinn::Tonic
    include Djinn::Logging
    
    attr_reader :config
    
    def perform config={}
      # base implementation does nothing worthwhile
      trap('TERM') { handle_exit }
      trap('INT')  { handle_exit }
      while true
        log("[#{name}] Djinn is running..")
        sleep(5)
      end 
    end

    def handle_exit
      # override this with useful exit code if you need it
      exit(0)
    end

    def start config={}
      @config = (config.empty?) ? load_config : config.empty?
      log "Starting #{name} in the background.."
      logfile = get_logfile(config)
      daemonize(logfile, get_pidfile(config)) do
        trap('TERM') { handle_exit }
        trap('INT')  { handle_exit }
        perform(config)
      end
    end

    def run config={}
      @config = (config.empty?) ? load_config : config.empty?
      log "Starting #{name} in the foreground.."
      trap('TERM') { handle_exit }
      trap('INT')  { handle_exit }
      perform(config)
    end

    def restart config={}
      stop
      start(config)
    end

    def stop config={}
      @config = (config.empty?) ? load_config : config.empty?
      pidfile = get_pidfile(@config)
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
    
    protected
    
      def name
        underscore(self.class.name)
      end
    
    private
    
      def underscore(camel_cased_word)
        camel_cased_word.to_s.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
      end
    
  end
end