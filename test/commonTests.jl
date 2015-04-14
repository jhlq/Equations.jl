#using Base.Test
#include("common.jl")

ex=:x+:y-3
@test expression(addparse(ex))==ex

ex1=simplify(1+:x*2-1)
ex2=push!(2,:x)
@test ex1==ex2

ex1=:x*:y
ex2=Equations.sumsym(-:x+:x*:y+:x)
@test ex1==ex2 

@test Equations.sumsym(1-:x+:x)==1
@test Equations.sumnum(1+:x-1)==:x

@test evaluate(:x+:z,[:x=>3,:z=>4])==7
