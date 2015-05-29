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
@test randeval(d&pat)==randeval(3*Pow(:x,2))
@test randeval((Der(:x^:n,:x)-Der(-0.1*:x^:m,:x)+1/:a*Der(:a*sqrt(:x),:x))&relations["Der"])==randeval(:n*Pow(:x,:n-1) + 0.1*:m* Pow(:x,:m -1) + 0.5*Pow(:x,-0.5))
