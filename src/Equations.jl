module Equations
#types
export Equation, EquationChain, Expression, Component, NonAbelian, Operator, Ex, Term, Factor, ╱,Div, Sqrt, Pow,Exp,Log,Cos,Sin,Cosh,Sinh, Der,DerOp, Vec,Cross,Dot,Norm,Mat, Named,Oneable, Physical, AbstractTensor,Ten,Up,Alt,Tensor,BraKet,Delta,⊗,TensorProduct,∧,Wedge,D,Form,Trace,Commutator
#functions
export equation, solve, expression, ≖, evaluate, simplify, simplify!, componify, componify!, addparse, has, sumnum, sumsym, matches, getarg, findpows, indin, indsin, replace, findsyms, quadratic, complexity, terms, getargs, randeval, expandindices,pushall!,sumconv,duplicates, @equ,@equs
#relations
export relations

include("equations.jl")

end # module
