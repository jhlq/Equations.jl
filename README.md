# Equations
Calculate with symbols as numbers.
```
:x+:y
:x*:y
:x/:y
:x^3
sqrt(:x^2)
```

The resulting Expression is moderately human readable, multiplication is implied in adjacent components, in the case of several nested expressions readability can be improved with componify:
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

[![Build Status](https://travis-ci.org/jhlq/Equations.jl.svg?branch=master)](https://travis-ci.org/jhlq/Equations.jl)
