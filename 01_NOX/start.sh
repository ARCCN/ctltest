#!/bin/bash
# NOX
thr=$1;
if [ $thr -lt 7 ] ;then
        cpuset="0-$(($thr-1))";
else
        cpuset="0-5,12-$((5+$thr))";
fi 
cd nox/src/
sudo taskset -c $cpuset ./nox_core -i ptcp:6633 switch -t $1
