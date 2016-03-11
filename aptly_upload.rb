#!/usr/bin/env ruby
require 'rubygems'
require 'daemons'

pwd = File.dirname(File.expand_path(__FILE__)) # the current directory
file = pwd + '/upload.rb'

options = {
    :app_name    =>"aptly_upload",
    :multiple   => true,
    :mode       => :load,
    :log_output => true,
    :monitor    => true
}

DOMAIN        = ARGV[-4]
PORT        = ARGV[-3]
SECRET         = ARGV[-2]
VALIDATOR     = ARGV[-1]

Daemons.run_proc('upload',options) do

    exec "ruby #{file} -o #{DOMAIN} -p #{PORT} #{SECRET} #{VALIDATOR}"

end
