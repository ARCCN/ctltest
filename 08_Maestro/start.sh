#!/bin/bash
# Maestro
cd Maestro-0.2.0
thr=$1;
if [ $thr -gt 8 ]; then
	thr=8
fi;

if [ $thr -lt 7 ] ;then
        cpuset="0-$(($thr-1))";
else
        cpuset="0-5,12-$((5+$thr))";
fi

sed -i -e "s/numThreads .*$/numThreads $thr/" conf/openflow.conf
sudo taskset -c $cpuset java -cp build/ sys.Main conf/openflow.conf conf/routing.dag 0
