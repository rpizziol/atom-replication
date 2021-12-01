#!/bin/bash

# First implementation with processes in background
# Run all .lqn files in parallel
for f in ./lqns/*.lqn
do
    java -jar DiffLQN.jar "$f" && mv ./lqns/*.csv csvs &
done

# Possible alternative implementation with 'parallel'
# parallel -j 4 java -jar DiffLQN.jar ::: ./lqns/*.lqn
# mv ./lqns/*.csv csvs
