module Equations
#types
export Equation, EquationChain, Expression, Component, NonAbelian, Operator, Ex, Term, Factor, ╱,Div, Sqrt, Pow,Exp,Log, Der, Vec,Cross,Dot,Norm, Named,Oneable
#functions
export equation, solve, expression, ≖, evaluate, simplify, simplify!, componify, componify!, addparse, has, sumnum, sumsym, matches, getarg, findpows, indin, indsin, replace, findsyms, quadratic, complexity, terms, getargs, randeval, @equ
#relations
export relations

include("equations.jl")

end # module
