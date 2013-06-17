#!/bin/bash
# How to run: sudo ./benchmark_latency.sh <path to dir with controller scripts dirs> <test duration>
# To run from current dir: ./benchmark_latency.sh . 10000
# Change cbench_server and contr_server variables to your IPs
# Manage the ssh keys on servers to avoid entering password each time cbench is run

cbench_server="127.0.0.1"; #ip of control network interface where cbench is run
contr_server="localhost"; #ip of control network interface to connect to controller

log="contr_log_lat"; #set logfile
stats="stats_lat";
duration=$2
d=`date`
echo "date: $d" >> $log

set -m

# Set reuse sockets in TIME_WAIT state
echo 1 | sudo tee /proc/sys/net/ipv4/tcp_tw_reuse;

HOMEDIR=$1
CONTR_DIR=(01_NOX 02_POX 03_FloodLight 05_Beacon 07_Mul-perf 08_Maestro 10_Ryu)
CONTR_NUM=${#CONTR_DIR[@]}
ml="07_Mul"
mlp="07_Mul-perf"

#params: controller id ($i), macs per swich, num of switches, mode (-t for thoroughput, '' for latency), number of threads
test_controller()
{
		# Cbench run loop
		for j in {0..2}; do
			echo "switches: $3, MACs: $2, threads 1  cbench run # $((j+1))" >> $stats;
			./$HOMEDIR/${CONTR_DIR[$1]}/start.sh 1 > /dev/null 2>>debug_log &
			gpid=`ps axu | grep start.sh | egrep -vi grep | awk '{print $2}'`;
			sleep 5;
			cdir=${CONTR_DIR[$1]};
			echo $cdir;
			echo "GPid is $gpid, id is $1";
			ssh $cbench_server "cbench -c $contr_server -m $duration -l 10 -M $2 $4 -s $3;" >> $log;
			# Kill start.sh and all child procs
			sudo kill -TERM -$gpid;
			if [$((CONTR_DIR[$1])) == 04_Trema]; then
				sudo killall ovs-openflowd switch switch_manager phost;
				sudo killall -9 switch;
			fi;
			if [ $cdir = $ml -o $cdir = $mlp ];
			then
                        	sudo killall lt-mul
                	fi;
			listen=`netstat -na | grep 6633 | grep LISTEN`;
			while [ "$listen" != '' ]
			do
				echo "Someone is still listening to 6633! Wait 5 sec";
				sleep 5;
				sudo killall -9 lt-nox_core;
				listen=`netstat -na | grep 6633 | grep LISTEN`;
			done
			echo "-------------------------------------------------------------" >> $stats;
		done
}

./stat.sh $stats &

# Set Beacon properties for latency testing
sed -i -e "s/controller.immediate=.*$/controller.immediate=true/" beacon-1.0.2/beacon.properties;

# Latency with fixed number of switches (1) and different number of MACs per switch
echo "Fixed 1 switch latency" >> $log;
echo "Fixed 1 switch latency" >> $stats;
for i in {0..${CONTR_NUM}} ; do
        ./$1/${CONTR_DIR[i]}/who.sh;
        ./$1/${CONTR_DIR[i]}/who.sh >> $log;
        ./$1/${CONTR_DIR[i]}/who.sh >> $stats;
        macs=100;
        for k in {1..5} ; do
                macs=$((macs*10));
                echo "MACs per switch: $macs" >> $log;
                test_controller $i $macs "1" "" 1;
        done
done

# Close stats log
echo "FINISH" >> $stats
sudo killall stat.sh
