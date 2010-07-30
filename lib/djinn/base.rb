dir = File.expand_path(File.dirname(__FILE__))
$:.unshift(dir) unless $:.include?(dir)

require 'base/tonic'
require 'base/pid_file'
require 'base/logging'

module Djinn
  # The base class from which all Djinn spring forth
  module Base
        
    include Djinn::Base::Tonic
    include Djinn::Base::Logging
        
    attr_reader :config
    
    def initialize
      @config = { :__daemonize => true }
    end
    
    # Base implementation does nothing worthwhile, you should override this 
    # in your own implementation.
    def perform config={}
      while
        log("[#{name}] Djinn is running.. and doing nothing worthwhile.")
        sleep(5)
      end 
    end

    # Override this with useful exit code if you need to, but remember to
    # call *super* or call *exit* yourself, or your Djinn will be immortal.
    # This is truly terrible code, and will be removed soon.
    def handle_exit
      __exit! if respond_to?(:__exit!)
      exit(0)
    end

    # Starts the Djinn in the background.
    def start config={}, &block
      @config.update(config).update(load_config)
      #@config = (config.empty?) ? load_config : config
      log "Starting #{name} in the background.."
      logfile = get_logfile(config)
      daemonize(logfile, get_pidfile(config)) do
        yield(self) if block_given?
        trap('TERM') { handle_exit }
        trap('INT')  { handle_exit }
        (respond_to?(:__start!)) ? __start! : perform(@config)
        # If this process doesn't loop or otherwise breaks out of 
        # the loop we still want to clean up after ourselves
        handle_exit
      end
    end

    # Starts the Djinn in the foreground, which is often useful for
    # testing or other noble pursuits.
    def run config={}, &block
      @config.update(config).update(load_config)
      # @config = (config.empty?) ? load_config : config
      log "Starting #{name} in the foreground.."
      trap('TERM') { handle_exit }
      trap('INT')  { handle_exit }
      yield(self) if block_given?
      (respond_to?(:__start!)) ? __start! : perform(@config)
      # If this process doesn't loop or otherwise breaks out of 
      # the loop we still want to clean up after ourselves
      handle_exit
    end

    # Convenience method, really just calls *stop* and then *start* for you :P
    def restart config={}
      stop
      start(config)
    end

    # Stops the Djinn, unless you change the location of the pid file, in 
    # which case its all about you and the *kill* command
    def stop config={}
      @config.update(config).update(load_config)
      # @config = (config.empty?) ? load_config : config
      yield(self) if block_given?
      __stop! if respond_to?(:__stop!)
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