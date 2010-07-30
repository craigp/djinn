module Djinn
  module Rails
    module Handlers
      
      require 'optparse'
      
      def djinnify_rails args=[]
        action = parse_args(args)
        self.new.__send__(action.intern) do
          load_rails unless %w(stop restart).include?(action)
        end
      end
            
      def go args=[]
        djinnify_rails(args)
      end
    
      private
  
        def load_rails
          puts "Loading Rails in #{ENV['RAILS_ENV']} environment"
          require File.join(RAILS_ROOT, 'config', 'environment')
        end
        
        def parse_args args
          action = "run" # this is the default
          environment = ENV["RAILS_ENV"] || "development"
          opts = OptionParser.new do |opts|
            opts.banner = "Usage: djinn_name [options] {start|stop|restart|run}"
            opts.on("-e", "--environment ENV", "Run in specific Rails environment") do |e|
              environment = e
            end
            opts.on_tail("-h", "--help", "Show this message") do
              puts opts
              exit
            end            
            action = opts.permute!(args)
            action = action.first || "run"
            (puts opts; exit(1)) unless %w(start stop restart run).include?(action)
          end
          opts.parse!(args)
          ENV["RAILS_ENV"] = environment
          action
        end
  
    end
  end
end