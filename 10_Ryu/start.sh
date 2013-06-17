#!/bin/bash
# POX 
cd ryu/ryu/app
thr=$1;
if [ $thr -lt 7 ] ;then
        cpuset="0-$(($thr-1))";
else
        cpuset="0-5,12-$((5+$thr))";
fi
sudo taskset -c $cpuset ryu-manager simple_switch.py 
