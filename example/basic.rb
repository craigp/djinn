#!/usr/bin/env ruby

$:.unshift("../lib")

require 'djinn'
require 'rubygems'

class Basic
  
  include Djinn
  
  # Not providing a "perform" method falls back to the base method 
  # in Djinn, which does nothing useful. Make sure your method accepts
  # a config hash, even if it doesn't use it.
  def perform options
    while(true)
      log "ZOMG! A Djinn?"
      sleep(5)
    end
  end
  
  # Strictly optional, lets you do stuff when the Djinn daemon stops.
  # The call to "super" is required, or your daemon will never die
  def handle_exit
    log "Handling a nice graceful exit.."
    super
  end
  
end

djinn = Basic.new
djinn.run

# Runs for 10 secs in the background and then stops
# djinn.start
# sleep(10)
# djinn.stop
