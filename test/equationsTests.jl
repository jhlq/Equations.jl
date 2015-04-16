###Equations
eq=equation(:x)
@test eq==Equation(:x,0)

#evaluate
eq=equation(1/:x-sqrt(:x))
@test evaluate(eq,[:x=>1])==(0,0)
m=matches(eq)
for tm in m
	l,r=evaluate(tm,[:x=>1])
	@test l==r
end

#matches
ex=3*:x^2-5*:x+1.5
m=matches(ex,quadratic)
@test evaluate(ex,[:x=>m[1].rhs])<1e-9 && evaluate(ex,[:x=>m[2].rhs])<1e-9
ex=:x*3*:x-5*:x*3+1.5
m=matches(ex,quadratic)
@test evaluate(ex,[:x=>m[1].rhs])<1e-9 && evaluate(ex,[:x=>m[2].rhs])<1e-9

#solve
eq=equation(:x+:z+:t)
sol=solve(eq)
for s in sol
	res=evaluate(eq,[s.lhs=>s.rhs])
	@test res[1]==res[2]
end
