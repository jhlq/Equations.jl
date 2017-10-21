b=3;a=@equ a=$b #:a ≖ 3
@test a==Equation(:a,3)
P=@equ P=Ten($(map(x->pi^x,1:3)),i)
@test floor(P.rhs&@equ(i=1))==3
arr=@equs(e=$e, pi=$pi, M=$(eye(b)))
@test arr[1].rhs == e
@test arr[2].rhs == pi
@test arr[3].rhs == eye(b) 

@test Ten(:I,[:i,:i])&@equ(I=eye(3))==3
@test Ten(:A,[:i,:i])&@equ(A=[:a 0;0 :b])==:a+:b
@test Ten(:A,:i)*Ten(:B,:j)&@equs(A=[1,2,3],B=[3,2,1], j=i)==10
@test Ten(:A,[:j,:i,:i])*Ten(:B,:j)&@equs(A=ones(3,3,3), B=[1,2,3])==18
@test (Alt([:i,:j,:k])*Ten([:a1,:a2,:a3],:j)*Ten([:b1,:b2,:b3],:k)&@equ i=1 )==simplify(:a2*:b3+-1.0*:a3*:b2)

x=@equ x=a*b^sqrt(y)+c/d
@test (x&@equs(a=3, b=2, y=9, c=8, d=4)).rhs==3*2^sqrt(9)+8/4

tri=@equ c^2=a^2+b^2
@test sqrt(tri)==simplify(:c ≖ Equations.Sqrt(:a*:a+:b*:b))

energy=@equ E=m*c^2
c=@equ c=299792458
m=@equ m=3*n
n=@equ n=9
@test (energy&c&m&n).rhs == 3*9*299792458^2

r=(Der(:x^:n,:x)-Der(-0.1*:x^:m,:x)+1/:a*Der(:a*sqrt(:x),:x))&relations["Der"]
@test r==simplify(:n*Equations.Pow(:x,:n+-1)+0.1*:m*Equations.Pow(:x,:m+-1)+0.5*Equations.Pow(:x,-0.5))

relation=@equ Log(:a,:a)=1
@test Log(:e)&relation ==1
@test Log(9,9)&relation ==1
@test Log(:x+:y,:x+:y)&relation ==1

eq=3*:x^2-5*:x+1.5 ≖ 0
meq=eq&quadratic
@test evaluate(eq.lhs,Dict(:x=>meq[1].rhs))==0

rel=@equ Oneable(a)*x*z=y
@test :q*:r&rel ==:y

eq=3*:x^2-5*:x+1.5 ≖ 0
meq=eq&quadratic
@assert evaluate(eq.lhs,Dict(:x=>meq[1].rhs))==0
f1(ex::Expression)=ex[1][1]
f2(fac::Factor)=3*fac
@test (:a+:b)&[f1,f2]==3*:a
f3(eq::Equation)=eq'
f4(eq::Equation)=sqrt(eq)
@test (@equ(a=b^2)&[f3,f4]).lhs==:b

l=U(:l,:meter);t=U(:t,:second);v=l/t
@test v==U(:l*Equations.╱(:t),:meter*Equations.╱(:second))

rule=Der(:a*:x,:x)≖:a #equivalent to Equation(Der(:a*:x,:x),:a)
ex=Der(3*:x,:x)
m=matches(ex,rule)[1] #equivalent to ex&rule
@test m==ex&rule==3

eq=Equation(:x*:z+:y)
@test eq.rhs==0
@test !isempty(matches(eq))
eq=Equation(:x^2,9)
@test matches(eq,Sqrt)[1].rhs==3

meq=matches(:x^2+:a*:x≖0,Div)[1]
try
	evaluate(meq,Dict(:x=>0))
	@test false
catch er
end
