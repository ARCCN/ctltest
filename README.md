Collection of tests for OpenFlow controllers testing using Cbench tool
June, 2013


Description
=======

  The project contains the following scripts:

    * Installation and running of popular open source OpenFlow controllers
      (NOX, POX, Floodlight, Trema, Beacon, MuL, Maestro, Ryu)
    * install_contr.sh : script to install all the controllers
    * benchmark_thrpughput.sh : script for benchmarking the throughput of the
      controllers with Cbench
    * benchmark_latency.sh : script for benchmarking the latency of the 
      controllers with Cbench
    * stat.sh : script for collecting statistics of CPU and memory usage
      while running the controllers
    * parser.py : script for parsing the logs of Cbench throughput test
      and plotting the figures via gnulot
      
  All scripts were used for benchmaring controllers under Debian/Ubuntu
  (tested with Ubuntu 12.04 LTS).


Install Controllers
=======

  To install all the controllers run install_contr.sh script, which takes
  one parameter - the path to the directory where they should be installed.
  
  To install the controllers to the current directory:

    ./install_contr.sh .
 
  
Run Benchmarks
=======

  To run benchmarks you need to get Cbench tool:
  
  http://docs.projectfloodlight.org/display/floodlightcontroller/Cbench

  First, install the controllers (see "Install Controllers" section).
  To benchmark throughput or latency of all the installed controllers
  use benchmark_thrpughput.sh and benchmark_latency.sh scripts.

  By default it is assumed that you run the controllers on the same host
  with Cbench. If you want to benchmark the controllers running on a
  remote host, change IP adresses of control network interface at the 
  Cbnech server and the Controllers server in the both scripts, e.g.:

    cbench_server="username@192.168.1.42"
    contr_server="192.168.1.41"

  Note that you need to fill the user name which will be used for SSH
  connection to the Cbench server (also we advise to manage the SSH keys
  on both servers to avoid entering password each time Cbench is run).
  All scripts are run on the Controllers server.
  
  Both scripts take two parameters: the path to the directory where
  the controllers are installed and the duration of one Cbench test.
  If you have installed the controllers into the current directory, run:
  
    ./benchmark_throughput.sh . 10000
    ./benchmark_latency.sh . 10000

  Each script starts the controllers on the Controller server and then
  runs Cbench on the Cbench server via SSH. Controllers are run with
  different number of avaliable cores. Cbench is run in throughput or
  latency mode and vrying the number of switches and MACs.
  
  The Cbench logs are written to contr_log_th and contr_log_lat.

  The stat.sh script is run automaticaly in the background. The log is
  written to stats_th and stats_lat.

  Note that by default Trema controller is not included in the test, as it
  doesn't work properly under Cbench workload with 10 sec test duration.
  To include Trema, add 04_Trema to the CONTR_DIR lists in
  benchmark_throughput.sh and benchmark_latency.sh scripts. You also need to
  set a smaller test duration, e.g.:
  
    ./benchmark_throughput.sh . 5000
    ./benchmark_latency.sh . 5000

  To plot the results of throughput testing run:
  
    ./parser.py contr_log_th

    
Add Your Controller
=======

  To test your own controller you need to create a directory containing
  the following scripts:
  
    * who.sh : echo the controller's name (for debug purposes)
    * install.sh : script which describes how to install your contrioller
    * start.sh : script for running the controller, can take one parameter - 
      the number of CPU cores to use.
  
  For scripts examples see the existing controllers' scripts.
  
  Then add the name of your directory to the CONTR_DIR list in each script:
  intall_contr.sh, benchmark_throughput.sh and benchmark_latency.sh.
  Now you can run the scripts as described above, your controller will be
  added to the tests.
