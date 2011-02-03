require 'eventmachine'
require 'djinn/rails'

class BookDjinn
  
  BOOK_WORKER_INTERVAL = 5
  
  include Djinn::Rails
  
  djinn do
    
    start do
      EM.run do
        log "Workers will run every #{BOOK_WORKER_INTERVAL} secs"
        EM::PeriodicTimer.new(BOOK_WORKER_INTERVAL) do
          log "There are #{green(Book.count)} book(s) in the database"
          log "Updating read counts for all books.."
          Book.all.each &:read!
        end
      end
    end
    
    stop do
      log "Do something useful on stop.."
    end
    
    exit do
      log "Shutting down eventmachine"
      EM.stop
    end
  
  end
  
end