module Djinn

  require 'djinn/tonic'
  require 'djinn/pid_file'
  require 'djinn/logging_helpers'

  include Djinn::Tonic
  include Djinn::LoggingHelpers
  
  attr_reader :config

  def log msg
    puts "#{Time.now.strftime("%m/%d/%Y %H:%M:%S")}: #{msg}"
    STDOUT.flush
  end

  def perform
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
    log "Starting #{underscore(name)} in the background.."
    logfile = get_logfile(config)
    daemonize(logfile, get_pidfile(config)) do
      trap('TERM') { handle_exit }
      trap('INT')  { handle_exit }
      perform
    end
  end

  def run config={}
    @config = (config.empty?) ? load_config : config.empty?
    log "Starting #{underscore(name)} in the foreground.."
    trap('TERM') { handle_exit }
    trap('INT')  { handle_exit }
    perform
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
  
    def name
      self.class
    end

    def get_pidfile config
      pid_file_path = config[:pid_file_path] || 
        File.join(Dir.pwd, "#{underscore(name)}.pid")
      PidFile.new(pid_file_path)
    end

    def get_logfile config
      log_file_path = config[:log_file_path] || 
        File.join(Dir.pwd, "#{underscore(name)}.log")
      log_file_path
    end

    def load_config
      config_path = File.join(Dir.pwd, "#{underscore(name)}.yml")
      if File.exists?(config_path)
        YAML.load_file(config_path)
      else
        {}
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
