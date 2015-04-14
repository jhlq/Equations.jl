#using Base.Test
#include("equations.jl")

eq=equation(:x+:z+:t)
sol=solve(eq)
for s in sol
	res=evaluate(eq,[s.lhs=>s.rhs])
	@test res[1]==res[2]
end
