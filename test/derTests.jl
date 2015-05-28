eq=Der(:a*:x,:x)≖:a
ex=Der(3*:x,:x)
md=matches(ex,eq.lhs)
@test !isempty(md)
m=matches(ex,eq)
@test m[1]==3

ex=Der(3*:x,:y)
md=matches(ex,eq.lhs)
@test isempty(md)

c1=Der(3,:x);pat1=Equation(Der(:a,:x),0)
@test c1&pat1==0
c2=Der(3*:x,:x);pat2=Der(:a*:x,:x)≖:a
@test c2&pat2==3
d=Der(:x^3,:x);pat=relations["Der"][3];
@test d&pat==3*Pow(:x,2)
