import Base: log,exp,cos,sin
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
