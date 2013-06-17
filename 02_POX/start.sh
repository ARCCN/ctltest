#!/bin/bash
# POX 
cd pox
thr=$1;
if [ $thr -lt 7 ] ;then
        cpuset="0-$(($thr-1))";
else
        cpuset="0-5,12-$((5+$thr))";
fi
sudo taskset -c $cpuset ./pox.py --no-cli openflow.of_01 --port=6633 forwarding.l2_learning
