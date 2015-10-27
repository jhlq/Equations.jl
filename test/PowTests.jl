ex=:x^3
@test simplify(ex,Pow)==Pow(:x,3)
ex=:x*3*:x*:x
@test simplify(ex,Pow)==Expression(Any[3,Pow(:x,3)])
ex=:x*:y*3*:y*:x
@test simplify(ex,Pow)==Expression(Any[3,Pow(Expression(Any[:x,:y]),2)])
@test simplify(:x^3*:y^2*:x*3*:y,Pow)==Expression(Any[3,:x,Pow(Expression(Any[:x,:y]),3)]) #You are right dear Equations, that is simpler than the previous suggestion of Expression({3,Pow(Expression({:x,:x,:y}),2),:y})
@test simplify(:x^5,Pow)==Pow(:x,5)
