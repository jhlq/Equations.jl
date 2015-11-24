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

