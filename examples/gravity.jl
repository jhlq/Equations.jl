using Equations

consts=@equs(c=3e8, G=6.67e-11, massSun=2e30)

F1=-:G*:M*:m/:r^2
F2=:m*:v^2/:r
orbit=Equation(F2,F1)
v=sqrt(orbit/:m*:r) #orbital velocity

a=-:G*:M/:R^2

#Black holes
E=@equ m*v^2/2=G*M*m/R
R=E*:R/:m/:v^2*2
R_BH=R&@equs(v=c, M=massSun)&consts 
