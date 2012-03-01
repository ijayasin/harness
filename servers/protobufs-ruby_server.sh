#!/usr/bin/env bash

# load rvm ruby
source /usr/local/rvm/environments/ruby-1.9.3-p125@protobuf

cd /opt/apirally/api-rally/protobuf/server_ruby
ruby server.rb $@
