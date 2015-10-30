ex=Ten([1,2,3],:i)*Ten([90,80,70],:i)
@test simplify(ex,Ten)==460

ex=Ten(:A,:i)*Ten(:A,:j)
@test simplify(ex&@equs(A=[1,2,3], j=i),Ten)==14

ex=Alt([:i,:j,:k])*Ten(:a,:j)*Ten(:b,:k)
a=[1,2,3]
b=[90,80,70]
c=cross(a,b)
ex=ex&Equation(:a,a)&Equation(:b,b)
#@test c[1]==ex&@equ(i=1)
#@test c[2]==ex&@equ(i=2)
#@test c[3]==ex&@equ(i=3)

ex=Ten([1,2,3],:i)*Ten([3,2,1],:i)
@test sumconv(ex)==10
ex=:c+Ten([:a1,:a2,:a3],:i)*Ten([:b1,:b2,:b3],:i)+:c;nex=sumconv(ex)
@test nex==simplify(2*:c+:a1*:b1+:a2*:b2+:a3*:b3)
