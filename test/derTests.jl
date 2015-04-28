eq=Der(:a*:x,:x)≖:a
ex=Der(3*:x,:x)
md=matches(ex,eq.lhs)
@test !isempty(md)

ex=Der(3*:x,:y)
md=matches(ex,eq.lhs)
@test isempty(md)

m=matches(ex,eq)
@test m[1].rhs==3
