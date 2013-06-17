#!/bin/bash
# NOX 
sudo apt-get install autoconf automake g++ libtool swig make git-core libboost-dev libboost-test-dev libboost-filesystem-dev libssl-dev libpcap-dev python-twisted python-simplejson python-dev
sudo apt-get install libboost-all-dev libtbb-dev
sudo cd /etc/apt/sources.list.d
sudo wget http://openflowswitch.org/downloads/debian/nox.list
sudo apt-get update
sudo apt-get install nox-dependencies
cd `pwd`
git clone http://noxrepo.org/git/nox
cd nox
./boot.sh
./configure
make -j 
