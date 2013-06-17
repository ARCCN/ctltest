#!/bin/bash
# MUL controller

thr=$1;
if [ $thr -lt 7 ] ;then
        cpuset="0-$(($thr-1))";
else
        cpuset="0-5,12-$((5+$thr))";
fi
sudo ./mul-code-perf/mul/mul -d -S $1
sudo taskset -a -p -c $cpuset `pidof lt-mul`
