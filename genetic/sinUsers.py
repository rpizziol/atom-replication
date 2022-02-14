from time import sleep, time
from math import sin, pi, floor

def fsin(t, mod, period, shift):
    return sin(t/(period/(2*pi)))*mod+shift
	
def updateFile(infile, outfile, now):
    nusers = floor(fsin(now, 1500, 6000, 1510))
    with open(infile, 'r') as file:
        data = file.read()
        data = data.replace('{{nuser}}', str(nusers))
        data = data.replace('{{time}}', str(now))
    with open(outfile, 'w') as file:
        file.write(data)
	
	
start = time()
while True:
    sleep(600) # change here the sampling time (600 = 10 minutes)
    now = time() - start
    updateFile('./res/atom-full_template5.lqnx', './res/atom-full_template6.lqnx', now)
