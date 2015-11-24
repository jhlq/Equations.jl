ex=Ten([1,2,3],:i)*Ten([90,80,70],:i)
@test simplify(ex)==460

ex=Ten(:A,:i)*Ten(:A,:j)
@test simplify(ex&@equs(A=[1,2,3], j=i))==14

a=Alt([:i,:j])
@test a.x[1,2]==1
@test a.x[2,1]==-1
a=Alt([:i,:j,:k])
@test a.x[1,2,3]==1
@test a.x[3,2,1]==-1
a=Alt([:i,:j,:k,:l])
@test a.x[1,2,3,4]==1
@test a.x[4,2,3,1]==-1

ex=Alt([:i,:j,:k])*Ten(:a,:j)*Ten(:b,:k);a=[5,123,-12];b=[90,80,70];ex=ex&Equation(:a,a)&Equation(:b,b)
@test ex==Ten(Any[9570.0,-1430.0,-10670.0],Any[:i])
c=cross(a,b)
@test c[1]==ex&@equ(i=1)
@test c[2]==ex&@equ(i=2)
@test c[3]==ex&@equ(i=3)
ex=Alt([1,2,:k])*Ten([1,2,3],2)*Ten([90,80,70],:k);sex=simplify(ex)
@test sex==140
ex=Alt([1,3,:k])*Ten([1,2,3],3)*Ten([90,80,70],:k);sex=simplify(ex)
@test sex==-240
ex=Alt([1,:j,:k])*Ten([1,2,3],:j)*Ten([90,80,70],:k);sex=simplify(ex)
@test sex==-100
r=Alt([:i,:j,:k])*Ten([:a1,:a2,:a3],:j)*Ten([:b1,:b2,:b3],:k)&@equ i=1
@test r==simplify(:a2*:b3+-1.0*:a3*:b2)

ex=:c+Ten([:a1,:a2,:a3],:i)*Ten([:b1,:b2,:b3],:i)+:c;nex=simplify(ex)
@test nex==simplify(2*:c+:a1*:b1+:a2*:b2+:a3*:b3)

@test simplify(Ten(eye(3,3),[:i,:i]))==3
@test simplify(Ten(eye(4,4),[:i,:i]))==4
@test simplify(Ten(eye(5,5),[:i,:i]))==5
r=Ten(:A,[:i,:i])&@equ A=[:a 0;0 :b]
@test r==:a+:b

io=IOBuffer()
print(io,simplify(Ten([1,2],:j)*Ten([3 2;1 -1],[:i,:j]))) 
str=takebuf_string(io)
#@test str=="Any[3,1](i) + 2 [2,-1](i)"
io=IOBuffer()
print(io,simplify(Ten([1,2],:j)*Ten([3 2;1 -1],[:j,:i]))) 
str=takebuf_string(io)
#@test str=="Any[3 2](i) + 2 [1 (-1)](i)"

@test duplicates([1,2,3,4,2])==[2,5]
@test duplicates([1,2,3,4,2,2])==[5,6]
@test duplicates([1,2,3],[0,3,0])==[3,2]
@test duplicates([1,3,3],[3,3,3])==[3,3]
@test Equations.arrduplicates([1,3,5],[12,241,13,3],[3,1,1])==([1,2],[2,4])
@test Equations.arrduplicates([1,3,55],[12,241,13],[33,1324,5,6,1])==([1,3],[1,5])

ex=Ten(:A,[:j,:i,:i])*Ten(:B,:j);r=ex&@equs(A=ones(3,3,3), B=[1,2,3])
@test r==18

ex=Ten(:A,[:i,:i]);eq=@equ A=eye(3,3);r=ex&eq
@test r==3


r=simplify(Ten([1,0],:i)+Ten([0,1],:i))
@test r==Ten([1,1],:i)
r=simplify(Ten([:c,:d],:i)+Ten([:a,:b],:i))
@test r==Ten(Any[:c+:a,:d+:b],Any[:i])
r=simplify(Alt([:i,:j,:k])*Ten([:a1,:a2,:a3],:j)*Ten([:b1,:b2,:b3],:k))

tt=Term[Factor[3,Ten([:a,:b],:i)],Factor[5,Ten([:c,:d],:i)]];stt=Equations.sumlify(tt)
@test stt[1][1].x[1]==simplify(Any[3*:a+5*:c,3*:b+5*:d][1]) 
@test stt[1][1].x[2]==simplify(Any[3*:a+5*:c,3*:b+5*:d][2]) 
#stt==simplify(Term[Factor[Equations.Ten(Any[3*:a+5*:c,3*:b+5*:d],Any[:i])]])

ex=Equations.sumlify(Equations.untensify!(sumconv(Alt([:i,:j])*Ten([10,100],:j)).terms))
@test ps(ex[1][1])=="Equations.Ten(Any[100.0,-10.0],Any[:i])"
#ex==Term[Factor[Equations.Ten(Any[100.0,-10.0],Any[:i]),10]]

ex=Alt([:i,:j,:k])*Ten([1,0,0],:j)*Ten([0,0,1],:k);ex=sumconv(ex);ex=sumconv(ex);tt=Equations.untensify!(ex.terms);ttt=Equations.sumlify(tt)
@test ttt[1][1]&(@equ i=2)==-1


a=rand(Int,3)%9;b=rand(Int,3)%9
ab=[Equation(:a,a),Equation(:b,b)]
ex=Ten(:a,:i)*Ten(:b,:i)
@test ex&ab==dot(a,b)
ex=Alt([:i,:j,:k])*Ten(:a,:j)*Ten(:b,:k)
c=cross(a,b)
x=(ex&ab).x
@test c==x
ex=Alt([:i,:j,:k])*Ten(:a,:j)*Ten(:b,:k)*Ten(:a,:m)*Ten(:b,:m)
r=cross(a,b)*dot(a,b)
x=(ex&ab).x
@test r==x
ex=Alt([:i,:j,:k])*Ten(:a,:j)*Ten(:b,:k)*Ten(:a,:m)*Ten(:b,:m)+Ten(:b,:i)
r=cross(a,b)*dot(a,b)+b
x=(ex&ab).x
@test r==x
c=rand(Int,3)%9;d=rand(Int,3)%9
abcd=[Equation(:a,a),Equation(:b,b),Equation(:c,c),Equation(:d,d)]
ex=Alt([:i,:j,:k])*Ten(:a,:j)*Ten(:b,:k)*Alt([:m,:n,:o])*Ten(:c,:n)*Ten(:d,:o)
r=dot(cross(a,b),cross(c,d))
x=ex&abcd&Equation(:m,:i)
@test r==x

include("../examples/tensors.jl")
