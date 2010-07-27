#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "../lib/"))

require 'djinn'

class Basic
  
  include Djinn
  
  # not providing a "perform" method falls back to the
  # base method in Djinn..
  
  def handle_exit
    puts "Handling a nice graceful exit.."
    super
  end
  
end

djinn = Basic.new
djinn.run

# puts "Running for 10 secs in the background and then stopping.."
# djinn.start
# sleep(10)
# djinn.stop
