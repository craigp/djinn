module Djinn
  # Defines the awesomesauce DSL for a whole new generation of Djinn
  module Dsl
  
    # Start your Djinn definition
    def djinn &block
      @dsl_helper = DslHelper.new(&block)
      @dsl_helper.actions.each do |action, proc|
        module_eval do
          define_method "__#{action}!".intern do |*args|
            instance_exec(&proc)
          end
        end
      end
    end

    class DslHelper
      
      attr_accessor :actions
      
      def initialize &block
        @actions = {}
        instance_eval(&block)
      end
      
      # Define an action that will be performed by a Djinn
      def on action, &block
        acceptable_actions = %w(start stop exit)
        raise DslActionError.new("\"#{action}\" is unrecognized, please use one of: #{acceptable_actions.join(', ')}") \
          unless acceptable_actions.include?(action.to_s)
        @actions[action] = block
      end
      
    end
    
    # This error means you screwed something up in your action definition 
    class DslActionError < Exception; end
  
  end
end