module Djinn
  module Base
    # This play on words kills me everytime. I'm that lame.
    module Tonic
  
      # Send your Djinn off to frolic in the ether
      def daemonize(logfile, pidfile, &block)
        pidfile.ensure_empty
        puts "Djinn is leaving process #{$$}"
      
        srand # split rand streams between spawning and daemonized process
      
        fork do
          puts "Daemonizing on process #{$$}" 
          # puts system("ps aux | grep #{$$}")
    
          #Dir.chdir "/" # release old working directory
          File.umask 0000 # ensure sensible umask
    
          # Making sure all file descriptors are closed
          ObjectSpace.each_object(IO) do |io|
            unless [STDIN, STDOUT, STDERR].include?(io)
              begin
                io.close unless io.closed?
              rescue ::Exception
              end
            end
          end
        
          pidfile.create # write PID file
        
          # detach from controlling terminal
          unless sess_id = Process.setsid
            raise 'Cannot detach from controlling terminal'
          end
    
          # redirect IO
          STDIN.reopen('/dev/null')
          STDOUT.reopen(logfile, 'a')
          STDERR.reopen(STDOUT)
    
          yield
    
        end
    
      end
  
    end
  end
end

