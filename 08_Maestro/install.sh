#!/bin/bash
# Maestro
sudo apt-get install openjdk-6-jdk ant unzip
wget http://maestro-platform.googlecode.com/files/Maestro-0.2.0.zip
unzip Maestro-0.2.0.zip
cd Maestro-0.2.0
sudo ant
