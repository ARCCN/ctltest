#!/bin/bash
# How to run: sudo ./benchmark_throughput.sh <path to dir with controller scripts dirs> <test duration>
# To run from current dir: ./benchmark_throughput.sh . 10000
# Change cbench_server and contr_server variables to your IPs
# Manage the ssh keys on servers to avoid entering password each time cbench is run

if [ $1 == '-h' ] ; then
    echo "script for throughput benchmarking"
                        echo " "
                        echo "./benchmark_latency [options]"
                        echo " "
                        echo "options:"
                        echo "-h       show this help message"
                        echo "-d       path to dir with controllers (.)"
                        echo "-S       username@ip for Cbench server (127.0.0.1)"
                        echo "-c       ip for Controllers server (localhost)"
                        echo "-r       number of Cbench runs for each testcase (3)"
                        echo "-t       number of CPU cores (12)"
                        echo "-m       one Cbench test duration (for Cbench), msec (10000)"
                        echo "-l       number of test loops (for Cbench) (10)"
                        echo "-s       list of switches (for Cbench) ('1 4 16 32 64 256')"
                        echo "-M       list of MACs per switch (for Cbench) ('1000 10000 100000 1000000 10000000')"
                        echo "-f       fixed MACs for switch number iterating (100000)"
                        echo "-x       fixed number of switches for MACs iterating (32)"
                        exit 0
fi;

cbench_server="127.0.0.1"; #ip of control network interface where cbench is run
contr_server="localhost"; #ip of control network interface to connect to controller
HOMEDIR="."
THR_NUM=12
LOOP=10
DUR=10000
SWITCHES='1 4 16 32 64 256'
MACS='1000 10000 100000 1000000 10000000'
RUN=3
FIX_MAC=100000
FIX_SWITCH=32

while getopts d:S:c:r:t:m:l:M:s:h: option ; do
        case "${option}"
        in
                d) HOMEDIR=${OPTARG};;
                S) cbench_server=${OPTARG};;
                c) contr_server=${OPTARG};;
                r) RUN=${OPTARG};;
                t) THR_NUM=${OPTARG};;
                m) DUR =${OPTARG};;
                l) LOOP=${OPTARG};;
                M) MACS=${OPTARG};;
                s) SWITCHES=${OPTARG};;
                f) FIX_MAC=${OPTARG};;
                x) FIX_SWITCH=${OPTARG};;    
        esac
done

log="contr_log_th"; #set logfile
stats="stats_th";

echo "$FIX_MAC $FIX_SWITCH $THR_NUM" >> $log

d=`date`
echo "date: $d" >> $log

set -m

# Set reuse sockets in TIME_WAIT state
echo 1 | sudo tee /proc/sys/net/ipv4/tcp_tw_reuse;

CONTR_DIR=(01_NOX 02_POX 03_FloodLight 05_Beacon 07_Mul-perf 08_Maestro 10_Ryu)
CONTR_NUM=${#CONTR_DIR[@]}

CONTR_NUM=$((CONTR_NUM-1))
RUN=$((RUN-1))

ml="07_Mul"
mlp="07_Mul-perf"

#params: controller id ($i), macs per swich, num of switches, mode (-t for thoroughput, '' for latency), number of threads
test_controller()
{
	# Threads num loop
	for threads in {1..$THR_NUM} ; do
		echo "Threads: $threads" >> $log;
		echo "Threads: $threads" >> $stats;
		# Cbench run loop
		for j in $(seq 0 1 $RUN) ; do
			echo "switches: $3, MACs: $2, threads $threads  cbench run # $((j+1))" >> $stats;
			./$HOMEDIR/${CONTR_DIR[$1]}/start.sh $threads > /dev/null 2>>debug_log &
			gpid=`ps axu | grep start.sh | egrep -vi grep | awk '{print $2}'`;
			sleep 5;
			cdir=${CONTR_DIR[$1]};
			echo $cdir;
			echo "GPid is $gpid, id is $1";
			ssh $cbench_server "cbench -c $contr_server -m $DUR -l $LOOP -M $2 $4 -s $3;" >> $log;
			# Kill start.sh and all child procs
			sudo kill -TERM -$gpid;
			if [ ${CONTR_DIR[$1]} == 04_Trema ]; then
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
		echo "-------------------------------------------------------------" >> $log;
	done
}

./stat.sh $stats &

# Set Beacon properties for throughput testing
sed -i -e "s/controller.immediate=.*$/controller.immediate=false/" beacon-1.0.2/beacon.properties;
	
# Throughput with fixed MACs per switch and different number of switches
echo "Fixed MACs per switch throughput" >> $log;
echo "Fixed MACs per switch throughput" >> $stats;
for i in $(seq 0 1 $CONTR_NUM) ; do
	./$HOMEDIR/${CONTR_DIR[i]}/who.sh;
	./$HOMEDIR/${CONTR_DIR[i]}/who.sh >> $log;
	./$HOMEDIR/${CONTR_DIR[i]}/who.sh >> $stats;
	for NUMSWITCH in $SWITCHES ; do
		echo "switches: $NUMSWITCH" >> $log;
		test_controller $i $FIX_MAC $NUMSWITCH "-t" $THR_NUM;
	done
done
	
# Throughput with fixed number of switches (32) and different number of MACs per switch
echo "Fixed 32 switches throughput" >> $log;
echo "Fixed 32 switches throughput" >> $stats;
for i in $(seq 0 1 $CONTR_NUM) ; do
	./$HOMEDIR/${CONTR_DIR[i]}/who.sh;
	./$HOMEDIR/${CONTR_DIR[i]}/who.sh >> $log;
	./$HOMEDIR/${CONTR_DIR[i]}/who.sh >> $stats;
	#macs=100;
	for MAC in $MACS ; do
		#macs=$((macs*10));
		echo "MACs per switch: $MAC" >> $log;
		test_controller $i $MAC $FIX_SWITCH "-t" $THR_NUM;
	done
done

# Close stats log
echo "FINISH" >> $stats
sudo killall stat.sh
