#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'sinatra/cross_origin'

set :bind, '0.0.0.0'
set :port, '9092'


use Rack::Auth::Basic, "Restricted Area" do |username, password|
    [username, password] == [ '<user>', '<pass>']
end

get '/' do
  'apty_uploader_v0.1'
end

post '/packages' do
    # upload deb shenanigans
    cross_origin
        name = params[:name]
        my_file = params[:my_file]
        unless params[:my_file] && (tmpfile = params[:my_file][:tempfile])
          @error = "No file selected"
          return haml(:upload)
        end
        STDERR.puts "Uploading file, original name #{name}"
        directory = "<incoming_deb_path>"
        path = File.join(directory, name)
        File.open(path, 'wb') do |f|
            while chunk = tmpfile.read(65536)
                f.write(chunk)
            end
        tmpfile.close
        end
        # aptly sequence
        add_deb = `/usr/bin/aptly repo add <repo_name> <incoming_deb_path>/#{name} > /dev/null 2>&1`
        puts "#{add_deb}"
        drop_repo = `/usr/bin/aptly publish drop <repo_name> > /dev/null 2>&1`
        puts "#{drop_repo}"
        publish_repo = `/usr/bin/aptly publish -batch -passphrase="<gpg_pass_repo>" -distribution="<dist_name>" repo <repo_name> > /dev/null 2>&1`
        puts "#{publish_repo}"
        "Upload complete\n"
    end
