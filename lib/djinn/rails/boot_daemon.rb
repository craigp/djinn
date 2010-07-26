#!/usr/bin/env ruby

$:.unshift(File.dirname(__FILE__))

require 'rubygems'
require 'optparse'

environment = ENV["RAILS_ENV"] || "development"
@action = "run"

OptionParser.new do |opts|
  opts.banner = "Usage: social_daemon [options] {start|stop|restart|run}"
  
  opts.on("-e", "--environment ENV", "Run in specific Rails environment") do |e|
    environment = e
  end

  @action = opts.permute!(ARGV)
  # (puts opts; exit(1)) unless action.size == 1

  @action = @action.first || "run"
  (puts opts; exit(1)) unless %w(start stop restart run).include?(@action)
  
end.parse!

ENV["RAILS_ENV"] = environment

require 'daemon_base'

