@test simplify(:x/:x,Div)==1

E=@equ E=sqrt(p^2*c^2+m^2*c^4)
vars=@equs p=sqrt(2)*1e6/c m=0.5e6/c^2
r=E&vars[2]
@test r.rhs==Equations.Sqrt(:p*:p*:c*:c+2.5e11)
