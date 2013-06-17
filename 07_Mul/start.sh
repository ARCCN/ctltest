#!/bin/bash
# MUL controller

# Executable will be built as mul-core/mul
   # - You need to run using sudo or as admin.
    # Options to use -
    # mul -d      : Daemon mode
        # -S <n>  : Num of switch threads
        # -A <n>  : Num of app threads
# [Optional if you opt for modules to run as a separate process]

    # > cd application/l2switch/

    # Executable :  mull2sw
sudo ./mul-code/mul/mul -d -S $1
sudo taskset -a -p -c 0-$(($1-1)) `pidof lt-mul` 
sudo taskset -c 0-$(($1-1)) ./mul-code/application/l2switch/mull2sw 
#sudo taskset -a -p -c 1 `pidof lt-mul`
#sudo taskset -a -p -c 1 `pidof lt-mull2sw` 
