
#     This file is part of CasADi.
#
#     CasADi -- A symbolic framework for dynamic optimization.
#     Copyright (C) 2010-2014 Joel Andersson, Joris Gillis, Moritz Diehl,
#                             K.U. Leuven. All rights reserved.
#     Copyright (C) 2011-2014 Greg Horn
#
#     CasADi is free software; you can redistribute it and/or
#     modify it under the terms of the GNU Lesser General Public
#     License as published by the Free Software Foundation; either
#     version 3 of the License, or (at your option) any later version.
#
#     CasADi is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#     Lesser General Public License for more details.
#
#     You should have received a copy of the GNU Lesser General Public
#     License along with CasADi; if not, write to the Free Software
#     Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA
#
#
from casadi import *

T = 2 # Time horizon
N = 50 # number of control intervals

MU=[1,1000,1000]

# Declare model variables
x0 = MX.sym('x0')
x1 = MX.sym('x1')
x2 = MX.sym('x2')
x = vertcat(x0,x1, x2)
u1 = MX.sym('u1')
u2 = MX.sym('u2')
u =  vertcat(u1,u2)

# Model equations
xdot = vertcat(-MU[0]*x0+MU[2]*casadi.fmin(x2,u2),
                MU[0]*x0-MU[1]*casadi.fmin(x1,u1),
                MU[1]*casadi.fmin(x1,u1)-MU[2]*casadi.fmin(x2,u2)
                )

# Objective term
L = (x0-100)**2+(MU[2]*casadi.fmin(x2,u2)-100)**2+(MU[1]*casadi.fmin(x1,u1)-100)**2

# Formulate discrete time dynamics
if True:
    # CVODES from the SUNDIALS suite
    dae = {'x':x, 'p':u, 'ode':xdot, 'quad':L}
    opts = {'tf':T/N}
    F = integrator('F', 'cvodes', dae, opts)
else:
    # Fixed step Runge-Kutta 4 integrator
    M = 4 # RK4 steps per interval
    DT = T/N/M
    f = Function('f', [x, u], [xdot, L])
    X0 = MX.sym('X0', 3)
    U = MX.sym('U',2)
    X = X0
    Q = 0
    for j in range(M):
        k1, k1_q = f(X, U)
        k2, k2_q = f(X + DT/2 * k1, U)
        k3, k3_q = f(X + DT/2 * k2, U)
        k4, k4_q = f(X + DT * k3, U)
        X=X+DT/6*(k1 +2*k2 +2*k3 +k4)
        Q = Q + DT/6*(k1_q + 2*k2_q + 2*k3_q + k4_q)
    F = Function('F', [X0, U], [X, Q],['x0','p'],['xf','qf'])

# Evaluate at a test point
# Fk = F(x0=[0,100],p=10)
# print(Fk['xf'])
# print(Fk['qf'])

# Start with an empty NLP
w=[]
w0 = []
lbw = []
ubw = []
J = 0
g=[]
lbg = []
ubg = []

# "Lift" initial conditions
Xk = MX.sym('X0', 3)
w += [Xk]
lbw += [500, 0,0]
ubw += [500, 0,0]
w0 += [500, 0,0]

# Formulate the NLP
for k in range(N):
    # New NLP variable for the control
    Uk = MX.sym('U_' + str(k),2)
    w   += [Uk]
    lbw += [0]*2
    ubw += [200]*2
    w0  += [1]*2

    # Integrate till the end of the interval
    Fk = F(x0=Xk, p=Uk)
    Xk_end = Fk['xf']
    J=J+Fk['qf']

    # New NLP variable for state at end of interval
    Xk = MX.sym('X_' + str(k+1), 3)
    w   += [Xk]
    lbw += [0, 0,0]
    ubw += [  inf,  inf,inf]
    w0  += [0, 0,0]

    # Add equality constraint
    g   += [Xk_end-Xk]
    lbg += [0, 0,0]
    ubg += [0, 0,0]

# Create an NLP solver
prob = {'f': J, 'x': vertcat(*w), 'g': vertcat(*g)}
solver = nlpsol('solver', 'ipopt', prob)

# Solve the NLP
sol = solver(x0=w0, lbx=lbw, ubx=ubw, lbg=lbg, ubg=ubg)
w_opt = sol['x'].full().flatten()

# Plot the solution
x1_opt = w_opt[0::5]
x2_opt = w_opt[1::5]
x3_opt = w_opt[2::5]
u1_opt = w_opt[3::5]
u2_opt = w_opt[4::5]

tgrid = [T/N*k for k in range(N+1)]
import matplotlib.pyplot as plt
plt.figure(1)
plt.clf()
plt.plot(tgrid, x1_opt, '--')
plt.plot(tgrid, x2_opt, '-')
plt.plot(tgrid, x3_opt, '-')
plt.step(tgrid, vertcat(DM.nan(1), u1_opt), '-.')
plt.step(tgrid, vertcat(DM.nan(1), u2_opt), '-.')
plt.xlabel('t')
plt.legend(['x0','x1','x2','u1','u2'])
plt.grid()

#plt.show()
plt.savefig("casadiSS.pdf")
