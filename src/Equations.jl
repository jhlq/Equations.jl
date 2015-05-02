module Equations
#types
export Equation, Expression, Component, Ex, Term, Factor, ╱,Div, Sqrt, Pow, Der
#functions
export equation, solve, expression, ≖, evaluate, simplify, simplify!, componify, componify!, addparse, has, sumnum, sumsym, matches, getarg, findpows, indin, indsin, replace, findsyms, quadratic, complexity, terms

include("equations.jl")

end # module
