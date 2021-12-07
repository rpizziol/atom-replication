def writeLQNFile(nClients, nThreads):
   with open('tritask-qn-template.lqn') as f:
      s = f.read().replace('{nClients}', str(nClients));

   with open(f"./lqns/{nClients}.lqn", "w") as text_file:
      text_file.write(s)

maxClients = 1001
steps = 5
stepSize = (maxClients-1)//steps

# Produce .lqn files varying number of clients
for nClients in range(stepSize, maxClients, stepSize):
    writeLQNFile(nClients, 10)
