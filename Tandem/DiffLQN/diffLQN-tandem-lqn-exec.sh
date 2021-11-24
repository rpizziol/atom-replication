#!/bin/bash

for f in *.lqn; do java -jar DiffLQN.jar $f; done
