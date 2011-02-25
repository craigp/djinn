#!/usr/bin/env ruby

# $:.unshift(File.join(File.dirname(__FILE__), "../lib"))
require 'rubygems'
require 'djinn'

class FileDjinn

  include Djinn

  djinn do
  
    configure do
      add :output_file do
        short_switch  "-o"
        long_switch   "--output-file"
        description   "File to output stuff to"
        required      true
      end
      
      add_flag :create_file do
        short_switch  "-c"
        long_switch   "--create-file"
        description   "Create output file if it doesn't exist"
      end
    end
  
    start do
      @file = unless File.exists?(config[:output_file])
        unless config[:create_file]
          log "File not found: #{config[:output_file]}"
          nil
        else
          File.open(config[:output_file], 'a')
        end
      else
        File.open(config[:output_file], 'a')
      end
      if @file
        log "Opening output file: #{File.expand_path(@file.path)}"
        loop do
          @file.puts "Writing to the file at #{Time.now}"
          @file.flush
          sleep(5)
        end
      end
    end

    exit do
      if @file
        log "Closing output file.."
        @file.close
      end
    end
  end

end

FileDjinn.djinnify do |djinn|
  puts "omfg, a djinn"
  puts djinn.config.inspect
end