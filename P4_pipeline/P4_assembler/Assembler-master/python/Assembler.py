import sys
import os.path, subprocess

java_file = 'Driver.java'
cmd = '/usr/bin/javac ' + java_file 
proc = subprocess.Popen(cmd, shell=True)
java_class = 'Driver ' + sys.argv[0]
cmd = '/usr/bin/java ' + java_class
proc = subprocess.Popen(cmd, shell=True)
