#!/usr/bin/env bash

# load rvm ruby
source /usr/local/rvm/environments/ruby-1.9.3-p125@avro

cd /opt/apirally/api-rally/avro/src/ruby
./serv.rb $@
