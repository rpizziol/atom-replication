#
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
import matplotlib.pyplot as plt 

def solveQN(isRk4=False,T=5,N=30,X=None,US=None,MU=None,Props=None,Jumps=None,tgt=None,X0n=None):
    
    F=None
    
    xdot=casadi.mtimes(Jumps.T,Props)
    
    # Objective term
    L = (X[6]-tgt)**2
    
    # Formulate discrete time dynamics
    if not isRk4:
        # CVODES from the SUNDIALS suite
        sys = {'x':X, 'p':US, 'ode':xdot,'quad':L}
        opts = {'tf':T / N}
        F = integrator('F', 'cvodes', sys, opts)
    else:
        # Fixed step Runge-Kutta 4 integrator
        M = 4  # RK4 steps per interval
        DT = T / N / M
        f = Function('f', [X, US], [xdot, L])
        X0 = MX.sym('X0', len(X0n))
        U = MX.sym('U',US.size(1))
        X = X0
        Q = 0
        for j in range(M):
            k1, k1_q = f(X, U)
            k2, k2_q = f(X + DT / 2 * k1, U)
            k3, k3_q = f(X + DT / 2 * k2, U)
            k4, k4_q = f(X + DT * k3, U)
            X = X + DT / 6 * (k1 + 2 * k2 + 2 * k3 + k4)
            Q = Q + DT / 6 * (k1_q + 2 * k2_q + 2 * k3_q + k4_q)
        F = Function('F', [X0, U], [X, Q], ['x0', 'p'], ['xf', 'qf'])
    
    # Start with an empty NLP
    w = []
    w0 = []
    lbw = []
    ubw = []
    J = 0
    g = []
    lbg = []
    ubg = []
    
    # Formulate the NLP
    Xk = MX(X0n) #initial state for the optimization, posso farlo parametrico?
    for k in range(N):
        # New NLP variable for the control
        Uk = MX.sym('U_' + str(k),US.size(1))
        w += [Uk]
        lbw += [0]*US.size(1)
        ubw += [3000]*US.size(1)
        w0 += [1]*US.size(1)
    
        # Integrate till the end of the interval
        Fk = F(x0=Xk, p=Uk)
        Xk = Fk['xf']
        J = J + Fk['qf']
    
        # Add inequality constraint
        # g += [Xk[0]]
        # lbg += [-.25]
        # ubg += [inf]
    
        
    
    # Create an NLP solver
    prob = {'f': J, 'x': vertcat(*w), 'g': vertcat(*g)}
    solver = nlpsol('solver', 'ipopt', prob)
    
    # Solve the NLP
    sol = solver(x0=w0, lbx=lbw, ubx=ubw, lbg=lbg, ubg=ubg)
    w_opt = sol['x']
    
    return {"u_pt":w_opt,"F":F}


#X0=[0,0,0,0,0,0,1000]
N=30
T=1
tgt=100
delta=10**6
    
MU=[1,1,1,1,500,500,1]
Jumps=DM([[+1,  +1,  +0,  +0,  +0,  +0,  -1],
          [+0,  -1,  +1,  +1,  +0,  +0,  +0],
          [+0,  +0,  +0,  -1,  +1,  +0,  +0],
          [+0,  +0,  -1,  +0,  -1,  +1,  +0],
          [-1,  +0,  +0,  +0,  +0,  -1,  +1]])

X = SX.sym('X',Jumps.size(2))
U = SX.sym('U',2)
    
Props=SX.sym("T",Jumps.size(1))
Props[0]=MU[6]*X[6]
Props[1]=delta*X[1]
Props[2]=delta*X[3]
Props[3]=casadi.fmin(X[4],U[1])*MU[4]
Props[4]=casadi.fmin(X[5],U[0])*MU[5]

xdot=casadi.mtimes(Jumps.T,Props)
    
# Objective term
L = (X[6]-tgt)**2

# Formulate discrete time dynamics
# CVODES from the SUNDIALS suite
sys = {'x':X, 'p':U, 'ode':xdot,'quad':L}
opts = {'tf':T / N}
F = integrator('F', 'cvodes', sys, opts)
XS=[[0,0,0,0,0,0,1000]]
for i in range(1000):
    Fk = F(x0=XS[-1], p=[0.5,1])
    XS.append(Fk["xf"].elements())


XS=np.array(XS)

plt.figure()
plt.plot(XS)
plt.show()

print(XS)

#     sol=solveQN(isRk4=False, T=T, N=N, X=X, 
#                   US=U, MU=MU, Props=Props, 
#                   Jumps=Jumps, tgt=tgt, X0n=x_opt[-1])
#
#     #qui la misura dello statod
#     # Plot the solution
#     u_opt = sol["u_pt"]
#     F=sol["F"]
#     for k in range(N):
#         Fk = F(x0=x_opt[-1], p=u_opt[k])
#         x_opt += [Fk['xf'].full().flatten()]
#
#
#     Uopt+=u_opt.elements()
#
# import matplotlib.pyplot as plt
#
# Uopt=np.array(Uopt)
# Uopt=np.reshape(Uopt,[N*nsteps,2])
#
# tgrid = [(T*nsteps)/(N*nsteps)*k for k in range((N*nsteps)+1)]
# XS=np.array(x_opt)
# plt.figure(1)
# plt.clf()
# plt.plot(tgrid, XS[:,6], '--')
# plt.plot(tgrid, XS[:,4], '-')
# plt.plot(tgrid, XS[:,5], '-')
# plt.legend(['x0','x1', 'x2'])
# plt.grid()
# plt.xlabel('t')
#
# plt.figure(2)
# plt.step(tgrid[1:],Uopt[:,0],'-.')
# plt.step(tgrid[1:],Uopt[:,1],'-.')
# plt.xlabel('t')
# plt.legend(["u1","u2"])
# plt.grid()
#
#
# plt.show()


# plt.figure(1)
# plt.clf()
# plt.plot(tgrid, x1_opt, '--')
# plt.plot(tgrid, x2_opt, '-')
# plt.step(tgrid, vertcat(DM.nan(1), u_opt), '-.')
# plt.xlabel('t')
# plt.legend(['x1', 'x2', 'u'])
# plt.grid()
# plt.show()
