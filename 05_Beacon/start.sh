#!/bin/bash
# Beacon
sed -i -e "s/controller.threadCount=.*$/controller.threadCount=$1/" beacon-1.0.2/beacon.properties
cd beacon-1.0.2
thr=$1;
if [ $thr -lt 7 ] ;then
	cpuset="0-$(($thr-1))";
else
	cpuset="0-5,12-$((5+$thr))";
fi 
sudo taskset -c $cpuset nohup ./beacon -configuration configurationSwitch

