module Djinn
  module Base
    # Logging Helper Class of Awesomeness
    module Logging
      
      # Log something to STDOUT, or wherever it's been redirected to
      def log msg
        puts "#{Time.now.strftime("%m/%d/%Y %H:%M:%S")}: #{msg}"
        STDOUT.flush
      end
  
      # Make some text *green*
      def green text
        colorize 32, text
      end

      # Make some text *red*
      def red text
        colorize 31, text
      end
  
      # Make some text *cyan*
      def cyan text
        colorize 36, text
      end

      private

        def colorize color, text
          "\033[#{color}m#{text}\033[0m"
        end
  
    end
  end
end
