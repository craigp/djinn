#!/usr/bin/env ruby

$:.unshift(File.join(File.dirname(__FILE__), "../lib/"))

require 'djinn'
require 'rubygems'

class Basic
  
  include Djinn
  
  # not providing a "perform" method falls back to the
  # base method in Djinn..
  
  def handle_exit
    puts "Handling a nice graceful exit myself.."
    super
  end
  
end

puts "Running for 10 secs and then stopping.."

djinn = Basic.new
# djinn.run
djinn.start
sleep(10)
djinn.stop