#!/bin/bash

sudo apt-get install git

CONTR=(01_NOX 02_POX 03_FloodLight 04_Trema 05_Beacon 07_Mul-perf 08_Maestro 10_Ryu)

echo "Install controllers..."
for CONTR_DIR in $CONTR ; do
	./$1/$CONTR_DIR/who.sh
	./$1/$CONTR_DIR/install.sh
done
