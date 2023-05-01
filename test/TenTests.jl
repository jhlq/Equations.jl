using LinearAlgebra

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

@test simplify(Ten(zeros(3,3).+Diagonal([1,1,1]),[:i,:i]))==3
@test simplify(Ten(zeros(4,4).+Diagonal([1,1,1,1]),[:i,:i]))==4
@test simplify(Ten(zeros(5,5).+Diagonal([1,1,1,1,1]),[:i,:i]))==5
r=Ten(:A,[:i,:i])&@equ A=[:a 0;0 :b]
@test r==:a+:b

io=IOBuffer()
print(io,simplify(Ten([1,2],:j)*Ten([3 2;1 -1],[:i,:j]))) 
str=String(take!(io))
#@test str=="Any[3,1](i) + 2 [2,-1](i)"
io=IOBuffer()
print(io,simplify(Ten([1,2],:j)*Ten([3 2;1 -1],[:j,:i]))) 
str=String(take!(io))
#@test str=="Any[3 2](i) + 2 [1 (-1)](i)"

@test duplicates([:a,:b,:c,:d,:b])==[2,5]
@test duplicates([:a,:b,:c,:d,:b,:b])==[5,6]
@test duplicates([:a,:b,:c],[:z,:c,:z])==[3,2]
@test duplicates([:a,:c,:c],[:c,:c,:c])==[3,3]
@test Equations.arrduplicates([:a,:c,:e],[:ab,:bda,:ac,:c],[:c,:a,:a])==([1,2],[2,4])
@test Equations.arrduplicates([:a,:c,:ee],[:ab,:bda,:ac],[:cc,:acbd,:e,:f,:a])==([1,3],[1,5])

ex=Ten(:A,[:j,:i,:i])*Ten(:B,:j);r=ex&@equs(A=ones(3,3,3), B=[1,2,3])
@test r==18

eye3=zeros(3,3).+Diagonal([1,1,1])
ex=Ten(:A,[:i,:i]);eq=@equ A=$eye3;r=ex&eq
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
@test sum(ex[1][1].x)==90
#ex==Term[Factor[Equations.Ten(Any[100.0,-10.0],Any[:i]),10]]

ex=Alt([:i,:j,:k])*Ten([1,0,0],:j)*Ten([0,0,1],:k);ex=sumconv(ex);ex=sumconv(ex);tt=Equations.untensify!(ex.terms);ttt=Equations.sumlify(tt)
@test ttt[1][1]&(@equ i=2)==-1


a=rand(Int,3).%9;b=rand(Int,3).%9
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
c=rand(Int,3).%9;d=rand(Int,3).%9
abcd=[Equation(:a,a),Equation(:b,b),Equation(:c,c),Equation(:d,d)]
ex=Alt([:i,:j,:k])*Ten(:a,:j)*Ten(:b,:k)*Alt([:m,:n,:o])*Ten(:c,:n)*Ten(:d,:o)
r=dot(cross(a,b),cross(c,d))
x=ex&abcd&Equation(:m,:i)
@test r==x

B=[:b1 :b2;:b3 :b4];ex=Alt([:i,:j])*Alt([:k,:l])*Ten(B,[:i,:k])*Ten(B,[:j,:l]);r=simplify(ex)
@test r==simplify(2*:b1*:b4+-2.0*:b2*:b3)

f=Fun(a->ones(2,2),[:x,:y])
ex=Ten(f,[:i,:i])
@test ex&@equs(x=1,y=1)==2

a=inv(:m)
m=rand(2,2)
@test a&@equ(m=$m)==inv(m)
t1=Ten(m,[:i,:j])
t2=Ten(inv(m),[:i,:j])
@test a&@equ(m=$t1)==t2

ex=Ten([:a,:b],:i)*Ten([:c,:d,:e],:j)
sex=simplify(ex)
@test ex&@equs(i=1,j=1)==:a*:c&&ex&@equs(i=2,j=1)==:b*:c&&ex&@equs(i=1,j=2)==:a*:d
@test sex.x[1,1]==:a*:c&&sex.x[2,1]==:b*:c&&sex.x[1,2]==:a*:d

r1=rand(2)
r2=rand(3,2)
ex=Ten(r1,[:i])*Ten(r2,[:a,:b])
sex=simplify(ex)
@test sex.x[1,1,1]==r1[1]*r2[1,1]&&sex.x[2,1,2]==r1[2]*r2[1,2]&&sex.x[1,2,2]==r1[1]*r2[2,2]

r1=rand(2,3,2,3)
r2=rand(3,2,2)
ex=Ten(r1,[:i,:j,:k,:l])*Ten(r2,[:a,:b,:c])
sex=simplify(ex)
@test sex.x[1,1,1,1,1,1,1]==r1[1,1,1,1]*r2[1,1,1]&&sex.x[2,1,2,3,3,1,2]==r1[2,1,2,3]*r2[3,1,2]&&sex.x[1,2,2,1,3,2,2]==r1[1,2,2,1]*r2[3,2,2]

t=Ten([Fun(x->x,:x),Fun(x->-x,:x)],:i)
@test t&@equ(x=2)==Ten(Any[2,-2],Any[:i])

t=Ten([Fun(x->[x,-x],:x),Fun(x->[-x,x],:x)],[:i,:j])
@test t&@equ(x=1)==Ten(Any[1 -1; -1 1],Any[:i,:j])
t&@equ(x=1)&@equs(i=1,j=1)
tn=Ten(Any[Int64[1,-1],Int64[-1,1]],Any[1,1])

r1=rand(2,3,2)
r2=rand(2,3,2)
r3=rand(2,3,2)
t=Ten([Fun(x->r1,:x),Fun(x->r2,:x),Fun(x->r3,:x)],[:i,:j,:k,:l])
st=t&@equ x=1
@test st.x[3,2,3,2]==r3[2,3,2]&&st.x[2,2,2,1]==r2[2,2,1]&&st.x[1,1,1,1]==r1[1,1,1]

ex=Ten([PD(:x),PD(:y)],:i)*Fun(a->a[1]^2+a[2]^3,[:x,:y])
sex=simplify(ex)
@test sex&@equs(x=1,y=2)==Ten(Any[2.0,12.0],Any[:i])

ex=PD(:x)*Ten([Fun(a->a[1]^2+a[2]^3,[:x,:y]),Fun(a->a[2]^2+a[1]^3,[:x,:y])],:j)
sex=simplify(ex)
@test sex&@equs(x=1,y=2)==Ten(Any[2.0,3.0],Any[:j])

ex=Ten([PD(:x),PD(:y)],:i)*Ten([Fun(a->a[1]^2+a[2]^3,[:x,:y]),Fun(a->a[2]^2+a[1]^3,[:x,:y])],:j)
sex=simplify(ex)
@test sex&@equs(x=1,y=2)==Ten(Any[2.0 3.0; 12.0 4.0],Any[:i,:j])
