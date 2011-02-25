require 'optparse'

module Djinn
  module Base
    # Defines the awesomesauce DSL defining your Djinn
    module Dsl
        
      # Start your Djinn definition
      def djinn &block
        @definition = DslDefinitionHelper.new(&block)
        @definition.actions.each do |action, proc|
          module_eval do
            define_method "__#{action}!".intern do |*args|
              instance_exec(&proc)
            end
          end
        end
      end
      
      # Create an instance of your Djinn, interpret any command line switches
      # defined in your configuration block, and starts the Djinn in the
      # background
      def djinnify config={}
        djinn = new
        @definition.prepare(djinn.config.update(config))
        unless djinn.config[:__stop]
          yield djinn if block_given?
          if djinn.config[:__daemonize]
            djinn.start
          else
            djinn.run
          end
        else
          djinn.stop
        end
      end
      
      # Used internally to read configuration blocks
      class ConfigHelper
        
        attr_accessor :config, :config_items
        
        def initialize &block
          @config_items = []
          instance_eval(&block) if block_given?
        end
        
        # Add a posix-style switch to your Djinn
        def add key, &block
          @config_items << ConfigItem.new(:posix, key, &block)
        end
        
        # Add a simple flag switch to your daemon
        def add_flag key, &block
          @config_items << ConfigItem.new(:flag, key, &block)
        end
        
        # Parses the configuration items created by executing the
        # configuration block
        def parse_config!(config, &block)
          options = OptionParser.new do |opts|
            opts.banner = "Usage: djinn_file [OPTIONS]"
            opts.on("--no-daemon", "Don't run in the background") do
              config[:__daemonize] = false
            end
            opts.on("--stop", "Stop the Djinn, if possible") do
              config[:__stop] = true
            end
            opts.on_tail("-h", "--help", "Prints this message") do
              puts opts
              exit(0)
            end
            @config_items.each { |c| c.parse!(opts, config) }
          end
          yield options if block_given?
          options.parse!
          #Apply defaults
          @config_items.each do |ci|
            config[ci.key] = ci.default_value if ci.has_default? unless config.include?(ci.key)
          end
          # Check for missing arguments
          @config_items.each do |ci|
            if ci.required?
              puts "Missing argument: #{ci.key}\n\n#{options}"
              exit(1)
            end unless config.include?(ci.key) or config.include?(:__stop)
          end
        rescue OptionParser::InvalidOption => e
          puts e.message
          exit(1)
        end
        
      end
      
      # A helper class to hold individual configuration items
      class ConfigItem
        
        attr_reader :key
        
        def initialize t, key, &block
          @type, @key = t, key
          instance_eval(&block) if block_given?
        end
        
        # Short configuration switch 
        def short_switch s
          @short_switch = s
          @short_switch = "-#{@short_switch}" unless @short_switch =~ /^-/
        end
        
        # Long configuration switch
        def long_switch s
          @long_switch = s
          @long_switch = "--#{@long_switch}" unless @long_switch =~ /^--/
        end
               
        # Description of the switch 
        def description d
          @description = d
        end
        
        # Sets whether the switch is required
        def required r
          @required = r
        end
        
        # Checks whether the switch is required
        def required?
          @required
        end
        
        def default d
          @default = d
        end
        
        def default_value; @default; end
        
        def has_default?
          !@default.nil?
        end
                
        # Parse the individual configuration option
        def parse! opts, config
          @long_switch = "#{@long_switch} #{@key.to_s.upcase}" if @type == :posix and \
            defined?(@key) && @key
          switches = []
          switches << (defined?(@short_switch) && @short_switch) ? @short_switch : nil
          switches << (defined?(@long_switch) && @long_switch) ? @long_switch : nil
          @description = "#{@description} (Default: #{@default})" if @default
          opts.on(switches[0], switches[1], @description) do |o|
            config[@key] = o
          end
        end
        
      end

      # A helper class for interpretting the definition block of a Djinn
      class DslDefinitionHelper
      
        attr_accessor :actions, :config_helper
      
        def initialize &block
          @actions = {}
          instance_eval(&block) if block_given?
          # create in case there was no configuration block
          @config_helper = ConfigHelper.new unless defined?(@config_helper)
        end
      
        # Define configuration for a Djinn, adding ARGV switches that
        # can be interpreted and acted on in your actions 
        def configure &block
          @config_helper = ConfigHelper.new(&block)
        end
                      
        # Runs when the Djinn starts
        def start &block
          @actions[:start] = block
        end
        
        # Runs when Djinn exits
        def exit &block
          @actions[:exit] = block
        end
        
        # Runs when the Djinn stops
        def stop &block
          @actions[:stop] = block
        end
        
        # Prepare the Djinn configuration based on informations passed in
        # in the configuration block
        def prepare(config)
          @config_helper.parse_config!(config)
        end
      
      end
    
      # This error means you screwed something up in your action definition 
      class DjinnActionError < Exception; end
  
    end
  end
end
