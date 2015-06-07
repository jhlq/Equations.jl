###Equations
eq=equation(:x)
@test eq==Equation(:x,0)

eq1=:a≖:b*:c;eq2=:c≖:d*:e;
eq3=eq1&eq2
@test eq3==(:a≖:b*:d*:e)

energy=@equ E=m*c^2
c=@equ c=299792458
m=@equ m=3*n
n=@equ n=9
@test (energy&c&m&n).rhs==2426638982589407628

tri=@equ c^2=a^2+b^2
@test randeval(sqrt(tri).rhs)==randeval(sqrt(:a^2+:b^2))

rel=@equ Oneable(a)*x=y
@test :q&rel==:y

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
