import Base: log,exp,cos,sin,cosh,sinh
type Log <: Component
	x
	y
end
Log(ex::EX)=Log(ex,:e)
log(ex::Ex)=Log(ex,:e)
log(ex::Ex,p::EX)=Log(ex,p)
function simplify(l::Log)
	l=Log(simplify(l.x),simplify(l.y))
	if l.x==l.y
		return 1
	end
	if isa(l.x,Number)
		if l.y==:e
			return log(l.x)
		elseif isa(l.y,Number)
			return log(l.x,l.y)
		end
	end
	return l
end

type Exp <: Component
	x
end
exp(ex::Ex)=Exp(ex)
function simplify(l::Exp)
	x=simplify(l.x)
	if isa(x,Number)
		return exp(x)
	end
	return Exp(x)
end
type Cos <: Component
	x
end
cos(ex::Ex)=Cos(ex)
function simplify(l::Cos)
	x=simplify(l.x)
	if isa(x,Number)
		return cos(x)
	end
	return cos(x)
end
type Sin <: Component
	x
end
sin(ex::Ex)=Sin(ex)
function simplify(l::Sin)
	x=simplify(l.x)
	if isa(x,Number)
		return sin(x)
	end
	return Sin(x)
end
for c=((:Cosh,:cosh),(:Sinh,:sinh))
	ex1=Expr(:type)
	ex2=Expr(:<:)
	push!(ex2.args,c[1],Component)
	ex3=Expr(:block)
	push!(ex3.args,:x)
	push!(ex1.args,true,ex2,ex3)
	eval(ex1)
	eval(parse("$(c[2])(ex::Ex)=$(c[1])(ex)"))
	eval(parse("function simplify(l::$(c[1]))
			x=simplify(l.x)
			if isa(x,Number)
				return $(c[2])(x)
			end
			return $(c[1])(x)
		end"))
end
