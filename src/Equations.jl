module Equations
export Equation, EquationChain, Expression, Component, NonAbelian, Operator, Ex, Term, Factor, ╱,Div, Sqrt, Pow,Exp,Log,Cos,Sin,Cosh,Sinh, Der,DerOp, Vec,Cross,Dot,Norm,Mat, Named,Oneable, U,Physical, AbstractTensor,Ten,Up,Alt,Tensor,BraKet,Delta,⊗,TensorProduct, ∧,Wedge,D,Form,Trace,Commutator,Transp,Fun,PD,Abs,Inv
export equation, solve, expression, ≖, evaluate, simplify, simplify!, componify, componify!, addparse, has, sumnum, sumsym, matches, getarg, findpows, indin, indsin, replace, findsyms, quadratic, complexity, terms, getargs, randeval, expandindices,pushall!,sumconv,duplicates,ps,sample, @equ,@equs
export relations

include("equ.jl")

end # This may seem like the end but is actually a beginning.
