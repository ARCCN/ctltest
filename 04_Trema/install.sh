#!/bin/bash
# Trema

sudo apt-get install gem ruby1.9.1 rubygems sqlite3 libsqlite3-ruby1.9.1 libsqlite3-dev ruby-dev libpcap-dev
git clone https://github.com/trema/trema
cd trema
sudo gem install trema
sudo ./build.rb
bundle install
