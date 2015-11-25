a=rand(Int,3)%9;b=rand(Int,3)%9;c=rand(Int,3)%9
abc=[Equation(:a,a),Equation(:b,b),Equation(:c,c)]

#Dot product
ex1=Ten(:a,:i)*Ten(:b,:i)
r1=ex1&abc
@assert r1==dot(a,b)

#Cross product
ex2=Alt([:i,:j,:k])*Ten(:a,:j)*Ten(:b,:k)
r2=ex2&abc
@assert r2.x==cross(a,b)

ex3=Alt([:i,:j,:k])*Ten(:a,:j)*Ten(:b,:k)*Ten(:b,:m)*Ten(:a,:m)+Ten(:c,:i)
r3=ex3&abc
@assert r3.x==cross(a,b)*dot(b,a)+c

#Both
ex4=Alt([:i,:j,:k])*Ten(:a,:j)*Ten(:b,:k)*Ten(:a,:m)*Ten(:c,:m)
r4=ex4&abc
@assert r4.x==cross(a,b)*dot(a,c)

ex5=Alt([:i,:j,:k])*Ten(:a,:j)*Ten(:b,:k)*Alt([:m,:n,:o])*Ten(:c,:n)*Ten(:b,:o)
r5=ex5&abc&Equation(:m,:i)
@assert r5==dot(cross(a,b),cross(c,b))

#Triangle area
ex6=Sqrt(Alt([:i,:j,:k])*Ten(:a,:j)*Ten(:b,:k)*Alt([:i,:m,:n])*Ten(:a,:m)*Ten(:b,:n))/2
r6=ex6&abc
@assert round(r6)==round(norm(cross(a,b))/2)

#Diadic products
ex7=Ten(:a,:i)*Ten(:b,:j)
r7=ex7&abc&@equs(i=2, j=3)
@assert r7==a[2]*b[3]

#Transpose
ex8=Transpose(Ten(a*b',[:i,:j]))
r8=simplify(ex8)
@assert r8.x==(a*b')'

#Determinant
A=rand(Int,3,3)%9
ex9a=Alt([:i,:j,:k])*Ten(A,[:i,1])*Ten(A,[:j,2])*Ten(A,[:k,3])
r9a=simplify(ex9a)
ex9b=Alt([:i,:j,:k])*Alt([:r,:s,:t])*Ten(A,[:i,:r])*Ten(A,[:j,:s])*Ten(A,[:k,:t])/6
r9b=simplify(ex9b)
@assert round(det(A))==r9a==round(r9b)

#Inverse
eq1=@equ detA=Alt([x,y,z])*Ten(A,[x,1])*Ten(A,[y,2])*Ten(A,[z,3])
eq2=@equ invA=Alt([j,m,n])*Alt([i,p,q])*Ten(A,[m,p])*Ten(A,[n,q])/(2detA)
eq3=eq2&eq1&Equation(:A,A)
@assert round((eq3&@equs(i=1,j=3)).rhs/inv(A)[1,3])==1
