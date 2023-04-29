###Expressions
ex=:x+:y
@test isa(ex,Expression)
@test has(ex,:x)
ex*=ex
@test has(ex,:x)

#addparse
ex=:x+:y
ap=terms(ex)
@test length(ap)==2
@test expression(ap)==ex #maybe have isequivalent instead to give addparse some room, maybe have == = isequivalent, equivalent=isequivalent?
let i=1
	for term in ex
		@test term==ap[i]
		i+=1
	end
end

#componify
ex=:x+1-(:x+1)
ex=componify(ex)
@test has(ex,:x)

#simplify
ex=(:x+:x)/2
@test simplify(ex)==:x
@test simplify(:x+:x)==2*:x

#evaluate


#original unsorted tests
ex1=simplify(1+:x*2-1)
ex2=push!(2,:x)
@test ex1==ex2

ex1=:x*:y
ex2=Equations.sumsym(-:x+:x*:y+:x)
@test ex1==ex2 

@test Equations.sumsym(1-:x+:x)==1
@test Equations.sumnum(1+:x-1)==:x

@test evaluate(:x+:z,Dict(:x=>3,:z=>4))==7

#Units
l=Physical(:l,:m);t=Physical(:t,:s);v=l/t;
@test v==Physical(:l/:t,:m/:s)

#Abs
a=abs(:x)
@test a&@equ(x=-1)==1
@test a&@equ(x=[1,0,1,0])==sqrt(2)
@test a&@equ(x=Ten([1,0,1,0],:i))==sqrt(2)
