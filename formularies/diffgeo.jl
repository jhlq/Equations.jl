using Equations

Ea=Tensor(:E,0,:a,2) 			#1.1
u=Tensor(:u,:a,0,1)*Ea			#1.2

eq1_3=@equ Braket(ω,α*v+β*w)=α*Braket(ω,v)+β*Braket(ω,w)	#1.3
ω=Tensor(:ω,0,:a,1)*Tensor(:E,:a,0,2)				#1.4

eq1_5=@equ Braket(Tensor(E,a,0,2),Tensor(E,0,b,2))=Delta(a,b)	#1.5
eq1_6=@equ Braket(αη+βλ,u)=α*Braket(η,u)+β*Braket(λ,u)		#1.6
eq1_7=@equ Braket(ω,u)=Tensor(ω,0,a,1)*Tensor(u,a,0,1)		#1.7

eq1_8=@equ Braket(D(f),X)=X*f					#1.8
eq1_9=@equ Braket(DerOp(Tensor(x,i,0,1)),D(Tensor(x,j,0,1)))=Delta(i,j)	#1.9
