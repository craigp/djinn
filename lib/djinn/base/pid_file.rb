module Djinn
  module Base
    # pid files are what bind your Djinn to the material plane
    class PidFile

      attr_reader :file

      def initialize(file)
        @file = file 
      end

      def pid
        File.exists?(@file) and IO.read(@file).to_i
      end

      def remove
        File.unlink(@file) if pid
      end

      def create
        File.open(@file, "w") { |f| f.write($$) }
      end

      def ensure_empty
        _pid = self.pid
        if _pid
          $stdout.puts <<-MSG
It looks like this Djinn is already running, not starting.
Alternatively, you could just have an orphaned pid file,
try running this command to check:

    ps aux | grep #{_pid}
            MSG
          exit 1
        end
      end

    end
  end
end

