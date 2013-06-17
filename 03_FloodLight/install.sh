#!/bin/bash
# FloodLight
sudo apt-get install build-essential default-jdk ant python-dev eclipse
git clone git://github.com/floodlight/floodlight.git
cd floodlight
sed -i -e "s/floodlight.modules = .*$/floodlight.modules = net.floodlightcontroller.learningswitch.LearningSwitch,net.floodlightcontroller.counter.NullCounterStore,net.floodlightcontroller.perfmon.NullPktInProcessingTime/" src/main/resources/floodlightdefault.properties
sed -i -e "s/^net.*,.*$//" src/main/resources/floodlightdefault.properties
sudo ant
