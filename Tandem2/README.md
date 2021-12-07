# Tandem

Subproject that models a tandem network both using CRNs and DiffLQN.


## Usage
1. To generate the lqns files for DiffLQN, run the Python code inside the folder DiffLQN:
```
python diffLQN-tandem-lqn-producer.py
```

2. Then run DiffLQN and generate the results in the csvs folder by running the bash script inside DiffLQN:
```
./diffLQN-tandem-lqn-exec.sh
```

3. Now you are ready to run the Matlab code that will produce also the comparison plots between DiffLQN and the CRNs approach.

## Authors

* **Roberto Pizziol** - *Tandem LQN Project* - [rpizziol](https://github.com/rpizziol/)


