import subprocess

def writeLQNFile(nClients, nThreads):
    s = f"""# Processors declaration, with multiplicity 
P 0
p ProcClient f m {nClients} 
p ProcRouter f m 1
-1

# Tasks declaration
T 0
t ClientTask r BrowseEntry -1 ProcClient m {nClients} # {nClients} client tasks running on client processors
t RouterTask n AddressEntry -1 ProcRouter m {nThreads}  #   {nThreads} server tasks running on server processors
-1

# Entries declaration
E 0
s BrowseEntry 1 -1     		    # entry BrowseEntry has time demand 1 time units
y BrowseEntry AddressEntry 1.0 -1   # entry BrowseEntry makes a synchronous call to AddressEntry 
s AddressEntry 0.0012 -1            # entry AddressEntry has time demand 0.0012 time units
-1

# DiffLQN settings, starting with #! 
# These will be ignored by LQNS

# 1. Solver settings
#! v 1.0e5           # fast rate to approximate instantaneous events
#! solver sim        # ODE analysis - solver sim will run simulation
#! stoptime 100.0     # integration time horizon
#! confidence_level 0.99
#! confidence_percent_error 0.1

# 2. Output settings 
#! throughput: BrowseEntry -1 # AddressEntry

# 3. Export settings
#! export csv"""

    with open(f"./tandem-files/tandem-qn-c{nClients}-t{nThreads}.lqn", "w") as text_file:
        text_file.write(s)


# Produce .lqn files varying number of clients
for nClients in range(100, 1001, 100):
    writeLQNFile(nClients, 10)

# Produce .lqn files varying number of threads
for nThreads in range(3, 31, 3):
    writeLQNFile(1000, nThreads)    
    
# Execute DiffLQN in all .lqn files (thus producing all csv files)    
bashCommand = "for f in *.lqn; do java -jar DiffLQN.jar $f; done"
process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
output, error = process.communicate()