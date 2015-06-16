#example of creating custom types

importall Equations

type Exp<:Component
	x
end
simplify(c::Exp)=isa(simplify(c.x),Number)?exp(simplify(c.x)):c
type Cos<:Component
	x
end
simplify(c::Cos)=isa(simplify(c.x),Number)?cos(simplify(c.x)):c
type Sin<:Component
	x
end
simplify(c::Sin)=isa(simplify(c.x),Number)?sin(simplify(c.x)):c
e1=Vec([1,0,0]);e2=Vec([0,1,0]);e3=Vec([0,0,1])

type Differentiable <: Component
	fun
	der::Dict
end
#getargs(d::Differentiable)=(d.fun,)
Equations.maketype(d::Differentiable,fun)=Differentiable(fun(d.fun),d.der)
Differentiable(a,b)=Differentiable(a,[:x=>b])
ed=Vec(Differentiable(1,0),Differentiable(0,1),0)
type DerOp #<: Operator
	dx
end
DerOp()=DerOp(:x)
*(d::DerOp,f::Differentiable)=haskey(f.der,d.dx)?f.der[d.dx]:Der(f,d.dx)
*(d::DerOp,ex::Factor)=Der(ex,d.dx)
type Grad <: Operator
	v
end
Grad()=Grad(Vec([DerOp(:x),DerOp(:y),DerOp(:z)]))
Base.print(io::IO,g::Grad)=print(io,"∇")
function dot(v1::Grad,v2::Differentiable)
	ex=Expression(Term[Factor[(v1.v[1]*v2)[1]]])
	for t in 2:length(v1.v)
		push!(ex,Factor[(v1.v[t]*v2)[t]])
	end
	return simplify(ex)
end


eq1=Cross(:j,:B)≖Grad()*:p
eq2=Cross(Grad(),:B)≖:μ0*:j
eq2p=Dot(Grad(),Cross(Grad(),:B))≖:μ0*Dot(Grad(),:j)
eq3=Dot(Grad(),:B)≖0

eqc=eq1≖0
