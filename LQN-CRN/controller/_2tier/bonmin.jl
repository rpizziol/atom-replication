using JuMP, AmplNLWriter, Bonmin_jll

function min_int(X,model)
    if(length(X)!=2)
        error("supperted only two sided minimum")
    end
    d=@variable(model,binary = true)
    dmin=@variable(model)
    @constraints(model, begin
           dmin<=X[1]
           dmin<=X[2]
           dmin>=X[1]-20000*(d)
           dmin>=X[2]-20000*(1-d)
    end)
    return dmin
end

model = Model(() -> AmplNLWriter.Optimizer(Bonmin_jll.amplexe))

#min_(x,y)=-(-x-y+((-x+y)^2+10^-20)^(1/2))/2.0
#register(model, :min_, 2, min_, autodiff=true)

@variable(model,X[i=1:3]>=0)
@constraint(model,X.<=100)
@constraint(model,X[1]==min_int([X[2],X[3]],model))
@objective(model,Max,X[1])
JuMP.optimize!(model)

println(value.(X))
