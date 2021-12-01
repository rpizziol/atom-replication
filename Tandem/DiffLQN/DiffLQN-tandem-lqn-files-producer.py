def writeLQNFile(nClients, nThreads):
   s = f"""# Processors declaration, with multiplicity 
P 0
p ProcClient f m {nClients} 
p ProcRouter f m 1
-1

# Tasks declaration
T 0
t ClientTask r BrowseEntry -1 ProcClient m {nClients}   # {nClients} client tasks running on client processors
t RouterTask n AddressEntry -1 ProcRouter m {nThreads}  #   {nThreads} server tasks running on server processors
-1

# Entries declaration
E 0
s BrowseEntry 1 -1     		        # entry BrowseEntry has time demand 1 time units
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

   with open(f"./lqns/{nClients}.lqn", "w") as text_file:
      text_file.write(s)


maxClients = 1001
steps = 10
stepSize = (maxClients-1)//steps

# Produce .lqn files varying number of clients
for nClients in range(stepSize, maxClients, stepSize):
    writeLQNFile(nClients, steps)
