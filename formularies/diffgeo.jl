using Equations

Ea=Tensor(:E,0,:a,2) 			#1.1
u=Tensor(:u,:a,0,1)*Ea			#1.2

eq1_3=@equ Braket(ω,α*v+β*w)=α*Braket(ω,v)+β*Braket(ω,w)	#1.3
ω=Tensor(:ω,0,:a,1)*Tensor(:E,:a,0,2)				#1.4

eq1_5=@equ Braket(Tensor(E,a,0,2),Tensor(E,0,b,2))=Delta(a,b)	#1.5
eq1_6=@equ Braket(αη+βλ,u)=α*Braket(η,u)+β*Braket(λ,u)		#1.6
eq1_7=@equ Braket(ω,u)=Tensor(ω,0,a,1)*Tensor(u,a,0,1)		#1.7

eq1_8=@equ Braket(D(f),X)=X*f					#1.8
xj=Tensor(:x,:j,0,1)
eq1_9=@equ Braket(DerOp(Tensor(x,i,0,1)),D(xj))=Delta(i,j)	#1.9
eq1_10=@equ Braket(DerOp(Tensor(x,i,0,1)),D(xj))=DerOp(Tensor(x,i,0,1))*xj
Xj=Tensor(:X,:j,0,1)
X=Xj*DerOp(xj)
eq1_11=@equ Braket(D(f),X)=X*f

#If
eq1_12=@equ Braket(D(f),X)=0
#Then f is a constant in the direction of the vector X.

eq1_13=@equ D(f)=Der(f,xi)*D(xi)
eq1_13&(@equ f=Der(f,xj)*D(xj))

eq1_14=@equ T=Tensor(T,[a1,a2,a3],[b1,b2])*Tensor(E,0,a1)*Tensor(E,0,a2)*Tensor(E,0,a3)*Tensor(E,b1,0)*Tensor(E,b2,0)
eq1_15=@equ Ea´=Tensor(χ,a,a´)*Tensor(E,0,a)
eq1_16=@equ Tensor(E,a´,0)=Tensor(Φ,a´,a)*Tensor(E,0,a)
eq1_17=@equ Delta(a´,b´)=Tensor(Φ,a´,a)*Tensor(χ,a,b´) #Tensor(χ,b,b´)*Delta(a,b)=Tensor(χ,a,b´)

eq1_19=@equ Tensor(T,a´,b´)*Tensor(χ,a,a´)*Tensor(Φ,b´,b)=Tensor(T,a,b)

eq1_22=@equ Tensor(E,a,0)∧Tensor(E,b,0)=Tensor(E,a,0)⊗Tensor(E,b,0)-Tensor(E,b,0)⊗Tensor(E,a,0)

eq1_28=@equ P∧Q=-1^(p*q)*Q∧P
