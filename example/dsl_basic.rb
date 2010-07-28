#!/usr/bin/env ruby

require 'rubygems'
require 'djinn'

class DslBasic
  
  include Djinn
  
  djinn do
    
    on :start do
      puts config.inspect
      while
        log "ZOMG! A Djinn is running!"
        sleep(5)
      end
    end
        
    on :stop do
      log "Djinn is stopping.."
    end
    
    on :exit do
      log "Handling a nice graceful exit.."
    end
    
  end  
  
end

opts = { :this => "rocks" }

djinn = DslBasic.new
djinn.run(opts) do |djinn|
  djinn.config[:omghax] = "Groovy, baby"
  puts djinn.config.inspect
  puts "Running the Djinn.."
end
# djinn.start
# sleep(10)
# djinn.stop do
#   puts "Stopping the Djinn.."
# end
