from pyscipopt import Model

model = Model("Example")

jump=[  [-1,+1,+0,+0,+0,+0],
        [+0,-1,+1,+0,+0,+0],
        [+0,-1,+0,+0,+1,+0],
        [+1,-1,+0,+0,+0,+0],
        [+0,+0,-1,+1,+0,+0],
        [+0,+0,+0,-1,+1,+0],
        [+1,+0,+0,-1,+0,+0],
        [+0,+0,+1,-1,+0,+0],
        [+0,+0,+0,+0,-1,+1],
        [+1,+0,+0,+0,+0,-1],
        [+0,+0,+1,+0,+0,-1],
        [+0,+0,+0,+0,+1,-1]
        ]

def min(x,y):
    return ((x+y) - abs(x-y))/2

x = model.addVar("x",lb=0, ub=3)
y = model.addVar("y",lb=0, ub=20)
z = model.addVar("z",lb=None, ub=None)
model.addCons(z == min(x,y))
model.setObjective(z)
model.setMaximize()
model.optimize()
sol = model.getBestSol()
print("x: {}".format(sol[x]))
print("y: {}".format(sol[y]))
print("z: {}".format(sol[z]))