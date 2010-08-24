module Djinn
  module Rails
    module Handlers
      
      # Create an instance of your Djinn, interpret any command line switches
      # defined in your configuration block, loads Rails environment and starts
      # the Djinn in the background
      def djinnify_rails config={}
        djinn = new
        
        # handle rails environment
        env = Djinn::Base::Dsl::ConfigItem.new(:posix, :rails_env)
        env.short_switch "-e"
        env.long_switch "--environment"
        env.description "Run in specific Rails environment"
        @definition.config_helper.config_items << env
        
        @definition.prepare(djinn.config.update(config))
        
        unless djinn.config[:__stop]
          if djinn.config[:__daemonize]
            djinn.start do
              ENV["RAILS_ENV"] = djinn.config[:rails_env] || "development"
              load_rails
            end
          else
            djinn.run do
              ENV["RAILS_ENV"] = djinn.config[:rails_env] || "development"
              load_rails
            end
          end
        else
          djinn.stop
        end
      end

      private
  
        def load_rails
          puts "Loading Rails in #{ENV['RAILS_ENV']} environment"
          require File.join(RAILS_ROOT, 'config', 'environment')
        end
        
    end
  end
end