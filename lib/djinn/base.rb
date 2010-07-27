$:.unshift(File.dirname(__FILE__))

require 'tonic'
require 'pid_file'
require 'logging'

module Djinn
  # The base class from which all Djinn spring forth
  module Base
    
    include Djinn::Tonic
    include Djinn::Logging
    
    attr_reader :config
    
    # Base implementation does nothing worthwhile, you should override this 
    # in your own implementation 
    def perform config={}
      trap('TERM') { handle_exit }
      trap('INT')  { handle_exit }
      while true
        log("[#{name}] Djinn is running..")
        sleep(5)
      end 
    end

    # Override this with useful exit code if you need to, but remember to
    # call *super* or call *exit* yourself, or your Djinn will be immortal 
    def handle_exit
      exit(0)
    end

    # Starts the Djinn in the background
    def start config={}, &block
      @config = (config.empty?) ? load_config : config
      log "Starting #{name} in the background.."
      logfile = get_logfile(config)
      daemonize(logfile, get_pidfile(config)) do
        yield if block_given?
        trap('TERM') { handle_exit }
        trap('INT')  { handle_exit }
        perform(@config)
      end
    end

    # Starts the Djinn in the foreground, which is often useful for
    # testing or other noble pursuits
    def run config={}, &block
      @config = (config.empty?) ? load_config : config
      log "Starting #{name} in the foreground.."
      trap('TERM') { handle_exit }
      trap('INT')  { handle_exit }
      yield if block_given?
      perform(@config)
    end

    # Convenience method, really just calls *stop* and then *start* for you :P
    def restart config={}
      stop
      start(config)
    end

    # Stops the Djinn, unless you change the location of the pid file, in 
    # which case its all about you and the *kill* command
    def stop config={}
      @config = (config.empty?) ? load_config : config
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
    
      # The name used to identify the Djinn, for pid and log file
      # naming, as well as finding default config files
      def name
        underscore(self.class.name)
      end
    
    private
    
      # Shamelessly stolen from the Rails source
      def underscore(camel_cased_word)
        camel_cased_word.to_s.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase
      end
    
  end
end