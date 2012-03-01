#!/usr/bin/env bash

# load rvm ruby
source /usr/local/rvm/environments/ruby-1.8.7-p358@rest_json_c

cd /opt/apirally/api-rally/rest_json_c
#./client.rb -o site_placement -f data/siteplacement.json -h localhost:6060 -n 1000 -c 5
./client.rb -o site_placement -f data/siteplacement.json -c 5 $@
