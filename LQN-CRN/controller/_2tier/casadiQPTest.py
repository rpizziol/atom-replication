'''
Created on 29 dic 2021

@author: emilio
'''

from casadi import *


# Objective function
obj = 0

# Variables
x = []

# Variable bounds
lbx = []
ubx = []

# Constraints
g = []

# Constraint bounds
lbg = []
ubg = []

x1 = SX.sym("x1")
x2 = SX.sym("x2")
x3 = SX.sym("x3")

x += [x1,x2,x3]
lbx += [-inf, 2,0]
ubx += [inf, 2,10]

g.append(x1-x2*x3)
lbg.append(0)
ubg.append(0)

obj+=x1

# Formulate QP
qp = {'x':vertcat(*x), 'f':obj, 'g':vertcat(*g)}

# Solve with IPOPT
solver = qpsol('solver', 'qpoases', qp, {'sparse':False})
#solver = qpsol('solver', 'gurobi', qp)
#solver = nlpsol('solver', 'ipopt', qp)

# Get the optimal solution
sol = solver(lbx=lbx, ubx=ubx, lbg=lbg, ubg=ubg)

x_opt = sol['x']
f_opt = sol['f']
print('f_opt = ', f_opt)
print(x_opt)