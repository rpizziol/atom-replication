#!/bin/bash

for f in ./lqns/*.lqn
do
    java -jar DiffLQN.jar $f
done
mv ./lqns/*.csv csvs
