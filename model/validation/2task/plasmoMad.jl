using MadNLP, Plasmo

graph = OptiGraph()
@optinode(graph,n1)
@optinode(graph,n2)
@variable(n1,0 <= x <= 2)
@variable(n1,0 <= y <= 3)
@constraint(n1,x+y <= 4)
@objective(n1,Min,x)
@variable(n2,x)
@NLconstraint(n2,exp(x) >= 2)
@linkconstraint(graph,n1[:x] == n2[:x])

set_optimizer(graph,MadNLP.Optimizer)
optimize!(graph;linear_solver=MadNLPMumps,max_iter=100000)
