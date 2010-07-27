$:.unshift(File.join(File.dirname(__FILE__), "../lib/"))

require 'djinn'
require 'rubygems'
require 'eventmachine'

WORKER_INTERVAL = 5

class Worker

  include EM::Deferrable
  
  def do_stuff
    puts "Worker doing stuff.."
    succeed(Time.now)
  rescue => e
    fail(e)    
  end

end

class EventMachineDjinn
  
  include Djinn
  
  def perform config
    
    worker = EM.spawn do
      worker = Worker.new
      worker.callback { |time| puts "Worker completed at: #{time}" }
      worker.errback { |ex| puts "Twitter worker failed: #{ex}" }
      worker.do_stuff
    end
    
    EM.run do
      log "Workers will run every #{WORKER_INTERVAL} secs"
      EM::PeriodicTimer.new(WORKER_INTERVAL) do
        worker.notify
      end
    end

  end
  
  def handle_exit
    EM.stop
    super
  end
  
end

puts "Running for 30 secs and then stopping.."

djinn = EventMachineDjinn.new
djinn.start
sleep(30)
djinn.stop


