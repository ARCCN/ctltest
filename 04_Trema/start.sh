#!/bin/bash
# Trema 
cd trema
thr=$1;
if [ $thr -lt 7 ] ;then
        cpuset="0-$(($thr-1))";
else
        cpuset="0-5,12-$((5+$thr))";
fi 
sudo taskset -c $cpuset ./trema run ./objects/examples/learning_switch/learning_switch  -c ./src/examples/learning_switch/learning_switch.conf
