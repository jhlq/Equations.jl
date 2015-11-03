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

@test simplify(Ten(eye(3,3),[:i,:i]))==3
@test simplify(Ten(eye(4,4),[:i,:i]))==4
@test simplify(Ten(eye(5,5),[:i,:i]))==5

#print(simplify(Ten([1,2],:j)*Ten([3 2;1 -1],[:i,:j]))) == [3,1](i) + 2 [2,-1](i)
#print(simplify(Ten([1,2],:j)*Ten([3 2;1 -1],[:j,:i]))) == [3 2](i) + 2 [1 -1](i)

@test duplicates([1,2,3,4,2])==[2,5]
@test duplicates([1,2,3,4,2,2])==[5,6]
@test duplicates([1,2,3],[0,3,0])==[3,2]
@test duplicates([1,3,3],[3,3,3])==[3,3]
@test duplicates([1,3,5],[12,241,13,3],[3,1,1])==([1,2],[2,4])
@test duplicates([1,3,55],[12,241,13],[33,1324,5,6,1])==([1,3],[1,5])
