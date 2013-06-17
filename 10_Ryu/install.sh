#!/bin/bash
# Ryu
# apt-get install python-pip
# pip install ryu

# from source code
sudo apt-get install python-setuptools python-bobo
git clone git://github.com/osrg/ryu.git
cd ryu
sudo python ./setup.py install
