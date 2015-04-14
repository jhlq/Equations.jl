# Equations
Calculate with symbols as numbers.
```:x+:y
:x*:y
:x/:y
:x^3
sqrt(:x^2)```

The resulting Expression is moderately human readable, multiplication is implied in adjacent components, however in the case of several nested expressions readability can be improved with componify:
```ex=:x^2-:x*:y+:y*:x-:y^2
componify(ex)```

For also combining factors and terms use:
```simplify((:x+:y)^3)```

[![Build Status](https://travis-ci.org/jhlq/Equations.jl.svg?branch=master)](https://travis-ci.org/jhlq/Equations.jl)
