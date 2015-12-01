[![Build Status](https://travis-ci.org/jhlq/Equations.jl.svg?branch=master)](https://travis-ci.org/jhlq/Equations.jl)

# Equations
Tensors are available! The summation convention applies automatically. See (the tensors file in examples)[https://github.com/jhlq/Equations.jl/blob/master/examples/tensors.jl] for usage.
```
Ten(:I,[:i,:i])&@equ I=eye(3) # 3
Ten(:A,[:i,:i])&@equ A=[:a 0;0 :b] # a+b
Ten(:A,:i)*Ten(:B,:j)&@equs(A=[1,2,3],B=[3,2,1], j=i)
Ten(:A,[:j,:i,:i])*Ten(:B,:j)&@equs(A=ones(3,3,3), B=[1,2,3]) # 18
Alt([:i,:j,:k])*Ten([:a1,:a2,:a3],:j)*Ten([:b1,:b2,:b3],:k)&@equ i=1
```

To install the latest version write:
```
Pkg.clone("Equations")
```

Calculate with symbols as numbers:
```
:x+:y
:x*:y
:x/:y
:x^3
sqrt(:x^2)
```

Specify equations conveniently with the equ macros:
```
x=@equ x=a*b^sqrt(y)+c/d
@assert (x&@equs(a=3, b=2, y=9, c=8, d=4)).rhs==3*2^sqrt(9)+8/4
```

Operate on equations:
```
tri=@equ c^2=a^2+b^2
print(sqrt(tri))
#c = √(a a + b b)
``` 

Substitute with & (see http://artai.co/Plasma.html for real usage examples):
```
energy=@equ E=m*c^2
c=@equ c=299792458
m=@equ m=3*n
n=@equ n=9
@assert (energy&c&m&n).rhs == 3*9*299792458^2
```

& also does pattern matching:
```
print((Der(:x^:n,:x)-Der(-0.1*:x^:m,:x)+1/:a*Der(:a*sqrt(:x),:x))&relations["Der"])
#n Pow(x,n + (-1)) + 0.1 m Pow(x,m + (-1)) + 0.5 Pow(x,(-0.5))
```

Write your own patterns as equations: 
```
relation=@equ Log(:a,:a)=1
Log(:e)&relation
Log(9,9)&relation
Log(:x+:y,:x+:y)&relation
```

Use the Oneable type for optional coefficients:
```
rel=@equ Oneable(a)*x*z=y
:q*:r&rel
```

& is overloaded to apply custom functions enabling chains of arbitrary behavior:
```
eq=3*:x^2-5*:x+1.5 ≖ 0
meq=eq&quadratic
@assert evaluate(eq.lhs,Dict(:x=>meq[1].rhs))==0
f1(ex::Expression)=ex[1][1]
f2(fac::Factor)=3*fac
@assert (:a+:b)&[f1,f2]==3*:a
```

To include units use the U type (sensitive to ordering, put unitless stuff last):
```
l=U(:l,:meter);t=U(:t,:second);v=l/t;print(v)
```

Equations can also be constructed without macros (the ≖ is written as \eqcirc+tab) and results derived by checking for matches:
```
rule=Der(:a*:x,:x)≖:a #equivalent to Equation(Der(:a*:x,:x),:a)
ex=Der(3*:x,:x)
m=matches(ex,rule)
```

For also combining factors and terms use:
```
simplify((:x+:y)^3)
simplify(:x*:y/:x)
simplify(sqrt(:x*:z*:y*:z*:y*:x))
```

Equations have a left hand side (lhs) and a right hand side (rhs) that when omitted defaults to 0. Custom matching can be accomplished by passing a function to matches that takes a equation and returns a list of matches.
```
eq=Equation(:x*:z+:y)
eq.rhs
matches(eq)
eq=Equation(:x^2,9)
matches(eq,Sqrt)
eq=3*:x^2-5*:x+1.5 ≖ 0
meq=matches(eq,quadratic)[1]
@assert evaluate(eq.lhs,Dict(:x=>meq.rhs))==0
```

If you try to evaluate an equation that has been constructed through division by setting one of the divided symbols to zero an error will be thrown:
```
meq=matches(:x^2+:a*:x≖0,Div)[1]
evaluate(meq,Dict(:x=>0))
```

To implement your own type make it descend from Component, you may also have to replace "using Equations" with "importall Equations". The first field of a Component is conventionally named x.
