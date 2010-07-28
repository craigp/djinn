module Djinn
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

    def ensure_empty(msg = nil)
      if self.pid
        $stdout.puts msg if msg
        exit 1
      end
    end

  end
end
