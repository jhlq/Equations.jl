consts=@equs(c=3e8, G=6.67e-11, massSun=2e30)
E=@equ m*v^2/2=G*M*m/R
R=E*:R/:m/:v^2*2
R_BH=R&@equs(v=c, M=massSun)&consts 
@test floor(R_BH.rhs)==2964
R=U(6.67e-11,:m^3/:s^2/:kg)*U(2e30,:kg)/U(3e8,:m/:s)/U(3e8,:m/:s)*2
@test R.units==:m


include("../examples/LQG.jl")
