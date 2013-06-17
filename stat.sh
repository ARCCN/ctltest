#!/bin/bash

log='stats';
while [ "1" -eq "1" ]; do

date >> $log;
uptime | awk '{print $8" "$9" "$10}' | sed -e "s/,//g" >> $log;
echo "us sy id" >> $log;
vmstat 1 4 | tail -1 | awk {'print $12" "$13" "$14'} >> $log;
echo "Memory in use:" >> $log;
free | awk '/Mem:/ {print $3}' >> $log;
echo "---------------------------------" >> $log;
sleep 9;
done
