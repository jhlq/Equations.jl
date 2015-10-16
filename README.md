[![Build Status](https://travis-ci.org/jhlq/Equations.jl.svg?branch=master)](https://travis-ci.org/jhlq/Equations.jl)

# Equations
To install the latest version write:
```
Pkg.clone("Equations")
```

Calculate with symbols as numbers (symbol names starting with 3 underscores are reserved for internal use):
```
:x+:y
:x*:y
:x/:y
:x^3
sqrt(:x^2)
```

To include units use the Physical type:
```
l=Physical(:l,:meter);t=Physical(:t,:second);v=l/t;print(v)
```

Specify equations conveniently with the equ macro:
```
x=@equ x=a*b^sqrt(y)+c/d
```

Substitute with & (see http://artai.co/Plasma.html for real usage examples):
```
energy=@equ E=m*c^2
c=@equ c=299792458
m=@equ m=3*n
n=@equ n=9
print(energy&c&m&n)
#E ≖ 2426638982589407628
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
rel=@equ Oneable(a)*x=y
:q&rel
```

Operate on equations:
```
tri=@equ c^2=a^2+b^2
print(sqrt(tri))
#c ≖ Sqrt(a a + b b)
``` 

Equations can also be constructed without macros (the ≖ is written as \eqcirc+tab) and results derived by checking for matches:
```
rule=Der(:a*:x,:x)≖:a
ex=Der(3*:x,:x)
m=matches(ex,rule)
```

The Expression and Equation types can be sent to print for generating an output more in line with mathematical treatments, multiplication is implied in adjacent components, in the case of several nested expressions readability can be improved with componify:
```
ex=:x^2-:x*:y+:y*:x-:y^2
componify(ex)
ex=(:a+:b)*(:c+:d)*(:e+:f)
componify(ex)
```

For also combining factors and terms use:
```
simplify((:x+:y)^3)
simplify(:x*:y/:x)
simplify(sqrt(:x*:z*:y*:z*:y*:x))
```

Equations have a left hand side and a right hand side that when omitted defaults to zero.
```
eq=equation(:x*:z+:y)
eq.rhs
matches(eq)
eq=Equation(:x^2,9)
matches(eq,Sqrt)
ex=3*:x^2-5*:x+1.5
meq=matches(ex,quadratic)[1]
evaluate(ex,[:x=>mat.rhs])
```

If you try to evaluate an equation that has been constructed through division by setting one of the divided symbols to zero an error will be thrown:
```
meq=matches(:x^2+:a*:x,Div)[1]
evaluate(meq,[:x=>0])
```

Types currently implemented to various degrees include Div, Sqrt, Pow, Der and soon Integral (∫). To implement your own type make it descend from Component and define custom simplify and matches along with type specific functionality, the first field of your custom type should be named x although that convention is being phased out in favor of getarg(c,argn).

