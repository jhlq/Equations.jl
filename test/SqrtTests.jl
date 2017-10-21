ex=sqrt(:a)*sqrt(:a)
@test length(Equations.unsqrt!(ex[1]))==1
ex=:b*sqrt(:a)*sqrt(:a)
@test length(Equations.unsqrt!(ex[1]))==2
ex=sqrt(:a)*sqrt(:b)*sqrt(:a)
@test length(Equations.unsqrt!(ex[1]))==2

eq=@equ fp=sqrt(a)
@test (eq^2).rhs==:a
