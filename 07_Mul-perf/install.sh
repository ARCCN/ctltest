#!/bin/bash
# MUL controller

sudo apt-get install libglib2.0-dev flex bison libwxgtk2.6-dev build-essential g++-multilib tofrodos zlib1g-dev gawk libffi-dev git pkg-config gettext make

git clone git://git.code.sf.net/p/mul/code mul-code-perf
cd mul-code-perf
cd SCRIPTS
sudo ./configure_ext_libs 
cd ..
		
# configure MUL
./configure  --with-l2sw=m --with-glib=/home/ctltest/mul-code-perf/common-libs/3rd-party/glib-2.32.0/ --with-libevent=/home/ctltest/mul-code-perf/common-libs/3rd-party/libevent-2.0.21-stable/

make
cd ..
