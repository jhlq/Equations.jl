import Base: log,exp
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
	l=Exp(simplify(l.x))
	if isa(l.x,Number)
		return exp(l.x)
	end
	return l
end
