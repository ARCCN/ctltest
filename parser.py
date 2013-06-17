#!/usr/bin/python

import sys
import re
import os

def main():

    # Parse log file
    
    log_filename = sys.argv[1]
    logfile = open(log_filename, 'r');
    
    avgmax = 0
    count = 0
    results = {}
    results['sw'] = {}
    results['mac'] = {}
    
    for line in logfile:
        if line[0] == '-' and count != 0:
        
            if not (controller in results[testcase]) :
                results[testcase][controller] = {}
                for i in range(1,13) :
                    results[testcase][controller][i] = {}
            if testcase == 'sw' :  
                results[testcase][controller][threads][switches] = avgmax/count
            else :
                results[testcase][controller][threads][macs] = avgmax/count
            avgmax = 0
            count = 0
            continue
                
        fields = line.split(' ')
        
        if len(fields) <= 1 : continue

        if fields[1][0:10] == 'controller' :
            controller = fields[0]
            continue
            
        if fields[0] == 'switches:' :
            switches = int(fields[1])
                
        if fields[1] == 'MACs' :
            testcase = 'sw'
            continue

        if fields[0] == "MACs" :
            macs = int(fields[3])
            
        if len(fields) > 2 and fields[0] == 'Fixed' and fields[2] == 'switches' :
            testcase = 'mac'
            continue
                
        if fields[0] == 'Threads:' :
            threads = int(fields[1])
            continue
                
        if fields[0] == 'RESULT:' :
            count += 1
            avgmax += float(fields[-2].split('/')[0])
    
    #print results
    
    logfile.close()        
    
    # Output stats to files
    sw_files = {}
    mac_files = {}
    thr_stats = open('sw_threads', 'w')
    sw_stats = open('switches', 'w')
    mac_stats = open('macs', 'w')
    
    for controller in sorted(results['sw'].keys()) :
        sw_files[controller] = open('sw_' + controller, 'w')
    for controller in sorted(results['mac'].keys()) :
        mac_files[controller] = open('mac_' + controller, 'w')
    
    # Switch testcase
    #thr_stats.write('threads')
    #sw_stats.write('threads')
    for controller in sorted(results['sw'].keys()) :
        #thr_stats.write(' ' + controller)
        #sw_stats.write(' ' + controller)

        for threads in sorted(results['sw'][controller].keys()) :
            #if threads == 1 :
                #sw_files[controller].write('threads')
                #for sw in sorted(results['sw'][controller][threads].keys()) :
                #    sw_files[controller].write(' ' + str(sw))
                #sw_files[controller].write('\n')
                 
            sw_files[controller].write(str(threads))
            for sw, flows in sorted(results['sw'][controller][threads].items()) :
                sw_files[controller].write(' ' + str(flows))
            sw_files[controller].write('\n')

    #thr_stats.write('\n')
    threads_pool = sorted(results['sw'][controller].keys())
    for threads in threads_pool :
        thr_stats.write(str(threads))
        for controller in sorted(results['sw'].keys()) :
            thr_stats.write(' ' + str(results['sw'][controller][threads][32]))
        thr_stats.write('\n')

    #sw_stats.write('\n')
    switches_pool = sorted(results['sw'][controller][threads].keys())
    for switches in switches_pool :
        sw_stats.write(str(switches))
        for controller in sorted(results['sw'].keys()) :
            sw_stats.write(' ' + str(results['sw'][controller][8][switches]))
        sw_stats.write('\n')
        
    for f in sw_files.keys() :
        sw_files[f].close()

    # Macs testcase 
    #mac_stats.write('threads')
    for controller in sorted(results['mac'].keys()) :
        #mac_stats.write(' ' + controller)

        for threads in sorted(results['mac'][controller].keys()) :
            #if threads == 1 :
                #mac_files[controller].write('threads')
                #for mac in sorted(results['mac'][controller][threads].keys()) :
                #    mac_files[controller].write(' ' + str(mac))
                #mac_files[controller].write('\n')
                 
            mac_files[controller].write(str(threads))
            for mac, flows in sorted(results['mac'][controller][threads].items()) :
                mac_files[controller].write(' ' + str(flows))
            mac_files[controller].write('\n')

    #mac_stats.write('\n')
    mac_pool = sorted(results['mac'][controller][threads].keys())
    for mac in mac_pool :
        mac_stats.write(str(mac))
        for controller in sorted(results['mac'].keys()) :
            mac_stats.write(' ' + str(results['mac'][controller][8][mac]))
        mac_stats.write('\n')

    for f in mac_files.keys() :
        mac_files[f].close()
    
    thr_stats.close()
    sw_stats.close()
    mac_stats.close()
    
    # Plot
    def_header = """
#! /usr/bin/gnuplot -persist
set terminal png size 640, 320 enhanced
set key right outside
set size ratio 0.5
set format y "%2.0t{/Symbol \\327}10^{%L}
set ylabel "Flows/sec"
"""
    # Threads
    plotscript = open('plotscript.graph', 'w')
    
    plotscript.write(def_header + """
set xrange [1:]
set output "threads.png"
set xlabel "Threads"
""")
    numcontr = len(results['sw'])
    for i in range(1,numcontr) :
        plotscript.write('set style line %d lt 1 lw 2 pt %d linecolor %d\n' % (i, i, i))   

    i = 0
    plotscript.write('plot ')
    for controller in sorted(results['sw'].keys()) :
        i += 1
        plotscript.write('"threads" using 1: %d with linespoints linestyle %d title "%s"' % (i+1, i, controller))
        if i != len(results['sw'].keys()) :
             plotscript.write(', ')
        
    plotscript.close()
        
    os.system('cat plotscript.graph | gnuplot')
    
    # Switches
    plotscript = open('plotscript.graph', 'w')
    
    plotscript.write(def_header + """
set xrange [0:]
set output "switches.png"
set xlabel "Switches"
set xtics ("1" 0, "4" 1, "16" 2, "32" 3, "64" 4, "256" 5)
""")
    plotscript.write('')
    numcontr = len(results['sw'])
    for i in range(1,numcontr+1) :
        plotscript.write('set style line %d lt 1 lw 2 pt %d linecolor %d\n' % (i, i, i))   

    i = 0
    plotscript.write('plot ')
    for controller in sorted(results['sw'].keys()) :
        i += 1
        plotscript.write('"switches" using %d with linespoints linestyle %d title "%s"' % (i+1, i, controller))
        if i != len(results['sw'].keys()) :
             plotscript.write(', ')
        
    plotscript.close()
        
    os.system('cat plotscript.graph | gnuplot')
    
    # MACs
    plotscript = open('plotscript.graph', 'w')
    
    plotscript.write(def_header + """
set xrange [0:]
set output "macs.png"
set xlabel "MACs per switch"
set xtics ("10^{3}" 0, "10^{4}" 1, "10^{5}" 2, "10^{6}" 3, "10^{7}" 4)
""")
    numcontr = len(results['mac'])
    for i in range(1,numcontr+1) :
        plotscript.write('set style line %s lt 1 lw 2 pt %d linecolor %d\n' % (i, i, i))   

    i = 0
    plotscript.write('plot ')
    for controller in sorted(results['mac'].keys()) :
        i += 1
        plotscript.write('"macs" using %d with linespoints linestyle %d title "%s"' % (i+1, i, controller))
        if i != len(results['mac'].keys()) :
             plotscript.write(', ')
        
    plotscript.close()
        
    os.system('cat plotscript.graph | gnuplot')
    
    # Controllers
    switches = ['1','4','16','32','64', '256']
    macs = ['10^{3}','10^{4}','10^{5}','10^{6}','10^{7}']
    for testcase in ['sw','mac'] :
        for controller in sorted(results[testcase].keys()) :
            plotscript = open('plotscript.graph', 'w')
            
            plotscript.write(def_header + 'set output "' + testcase + '_' + controller + '.png"\n' + """
set xlabel "Threads"
set xrange [1:]
set yrange [0:7000000]
""")
            if testcase == 'sw' :
                title = 'Switches: '
                rge = switches
            else :
                title = 'MACs per switch: '
                rge = macs
                
            for i in range(1,len(rge)+1) :
                plotscript.write('set style line %d lt 1 lw 2 pt %d linecolor %d\n' % (i, i, i))   

            plotscript.write('plot ')
            fname = testcase + '_' + controller
            for i in range(0,len(rge)) :
                plotscript.write('"%s" using 1:%d with linespoints linestyle %d title "%s%s"' % (fname, i+2, i+1, title, rge[i]))
                if i != len(rge) -1 :
                     plotscript.write(', ')
                
            plotscript.close()
                
            os.system('cat plotscript.graph | gnuplot')
            
    # Table
    table = open('table.html', 'w')
    table.write("""
<html>    
<body>
<table width="500" border cellspacing="0">
<tr>
<th>Controller</th>
<th>Max Throughput,<br>Flows/sec</th>
<th>Threads</th>
</tr>
""")
    
    for controller in sorted(results['sw'].keys()) :
        table.write('<tr><td>%s</td>' % (controller))
        
        maxthrough = 0
        maxthread = 1
        for threads in sorted(results['sw'][controller].keys()) :
            if results['sw'][controller][threads][32] > maxthrough :
                maxthrough = results['sw'][controller][threads][32]
                maxthread = threads
        
        table.write('<td>%.2f</td><td>%d</td></tr>\n' % (maxthrough, maxthread))

    table.write("""
</table>
</body>
</html>
""")
    table.close()
        

if __name__ == '__main__':
    main()
