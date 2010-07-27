module Djinn
  module Logging
    
    def djinn_log msg
      puts "#{Time.now.strftime("%m/%d/%Y %H:%M:%S")}: #{msg}"
      STDOUT.flush
    end
  
    def log msg
      puts "#{Time.now.strftime("%m/%d/%Y %H:%M:%S")}: #{msg}"
      STDOUT.flush
    end
  
    def green text
      colorize 32, text
    end

    def red text
      colorize 31, text
    end
  
    def cyan text
      colorize 36, text
    end

    def colorize color, text
      "\033[#{color}m#{text}\033[0m"
    end
  
  end
end
