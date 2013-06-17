#!/bin/bash
# MUL controller
# ѕоддержка русского €зыка
# dpkg-reconfigure console-setup
# UTF-8 -> KOI8-R -> VGA ->16 -> 8

# installing MUL
sudo apt-get install libglib2.0-dev flex bison libwxgtk2.6-dev build-essential g++-multilib tofrodos zlib1g-dev gawk libffi-dev git pkg-config gettext make

git clone git://git.code.sf.net/p/mul/code mul-code
cd mul-code
cd SCRIPTS
sudo ./configure_ext_libs 
cd ..
		
# дл€ повышени€ производительности
#apt-get install libtcmalloc-minimal0
#export LD_PRELOAD=/usr/lib/libtcmalloc_minimal.so.0

# configure MUL
./configure  --with-glib=/home/ctltest/mul-code/common-libs/3rd-party/glib-2.32.0/ --with-libevent=/home/ctltest/mul-code/common-libs/3rd-party/libevent-2.0.21-stable/
# дл€ повышени€ производительности добавить --with-l2sw=m

# build
make
cd ..
