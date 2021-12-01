import os
import csv

# TODO add this file to the main Python script
maxClients = 1001
steps = 10
stepSize = (maxClients-1)//steps

# Merge all data in one file
for nClients in range(stepSize, maxClients, stepSize):
   filename = './csvs/' + str(nClients) + '.csv' 
   with open(filename, newline='') as f:
      reader = csv.reader(f)
      row = next(reader)
      newCsvRow = [nClients, row[3]]
      with open('./csvs/max' + str(maxClients-1) + 'steps' + str(steps) + '.csv','a') as fd:
         writer = csv.writer(fd)
         writer.writerow(newCsvRow)
   # Delete all useless files
   os.remove(filename)
