#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'sinatra/cross_origin'
require 'ftools'
require 'fileutils'
require 'aptly'

set :bind, '0.0.0.0'
set :port, '9092'

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
        # aptly sequence
        add_deb = `/usr/bin/aptly repo add <repo_name> <incoming_deb_path>/#{name}`
        puts "#{add_deb}"
        drop_repo = `/usr/bin/aptly publish drop <repo_name>`
        puts "#{drop_repo}"
        publish_repo = `/usr/bin/aptly publish -passphrase="<gpg_pass_repo>" -distribution="<dist_name>" repo <repo_name> `
        puts "#{publish_repo}"
        end
        "Upload complete\n"
    end