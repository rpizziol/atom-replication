import subprocess

def writeLQNFile(nClients):
    s = f"""G
"Tandem+"
0.01
10000000
1
0.5
-1    
    
# Processors declaration, with multiplicity 
P 0
p ProcA f m {nClients} 
p ProcB f m 10
-1

# Tasks declaration
T 0
t TaskA r EntryA -1 ProcA m {nClients}
t TaskB n EntryB1 EntryB2 -1 ProcB m 10
-1

# Entries declaration
E 0
s EntryA 1.0 -1
s EntryB1 0.0012 -1
s EntryB2 0.0037 -1
A TaskA source
y EntryA EntryB1 1.0 -1
y EntryA EntryB2 1.0 -1
-1

# Activities definition
A TaskA
 s source 0.01
 s choice1 0.01
 s choice2 0.01
 y choice1 EntryB1 1.0
 y choice2 EntryB2 1.0
:
 source -> (0.5)choice1 + (0.5)choice2;
 choice1[EntryA];
 choice2[EntryA]
-1

# DiffLQN settings, starting with #! 
# These will be ignored by LQNS

# 1. Solver settings
#! v 1.0e5             # fast rate to approximate instantaneous events
#! solver ode          # ODE analysis - solver sim will run simulation
#! stoptime 1000.0     # integration time horizon
#! confidence_level 0.95
#! confidence_percent_error 0.1

# 2. Output settings 
#! throughput: EntryA EntryB1 EntryB2 -1

# 3. Export settings
#! export csv"""

    with open(f"./lqns/tandem+-qn-c{nClients}.lqn", "w") as text_file:
        text_file.write(s)


# Produce .lqn files varying number of clients
for nClients in range(100, 1001, 100):
    writeLQNFile(nClients)

# Produce .lqn files varying number of threads
#for nThreads in range(3, 31, 3):
#    writeLQNFile(1000, nThreads)
