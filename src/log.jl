import Base: log,exp,cos,sin,cosh,sinh
mutable struct Log <: Component
	x
	y
end
Log(ex::EX)=Log(ex,:e)
log(ex::Ex)=Log(ex,:e)
log(ex::Ex,p::EX)=Log(ex,p)
function simplify!(l::Log)
	l=Log(simplify!(l.x),simplify!(l.y))
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
simplify(l::Log)=simplify!(deepcopy(l))
mutable struct Exp <: Component
	x
end
exp(ex::Ex)=Exp(ex)
function simplify!(l::Exp)
	x=simplify!(l.x)
	if isa(x,Number)
		return exp(x)
	end
	return Exp(x)
end
simplify(l::Exp)=simplify!(deepcopy(l))
mutable struct Cos <: Component
	x
end
cos(ex::Ex)=Cos(ex)
function simplify!(l::Cos)
	x=simplify!(l.x)
	if isa(x,Number)
		return cos(x)
	end
	return cos(x)
end
simplify(l::Cos)=simplify!(deepcopy(l))
mutable struct Sin <: Component
	x
end
sin(ex::Ex)=Sin(ex)
function simplify!(l::Sin)
	x=simplify!(l.x)
	if isa(x,Number)
		return sin(x)
	end
	return Sin(x)
end
simplify(l::Sin)=simplify!(deepcopy(l))
for c=((:Cosh,:cosh),(:Sinh,:sinh),(:Tanh,:tanh),(:Tan,:tan),(:Atan,:atan),(:Acos,:acos),(:Asin,:asin))
	eval(Meta.parse("mutable struct $(c[1])<:Component;x;end"))
	eval(Meta.parse("$(c[2])(ex::Ex)=$(c[1])(ex)"))
	eval(Meta.parse("function simplify!(l::$(c[1]))
			x=simplify!(l.x)
			if isa(x,Number)
				return $(c[2])(x)
			end
			return $(c[1])(x)
		end"))
	eval(Meta.parse("simplify(l::$(c[1]))=simplify!(deepcopy(l))"))
end
