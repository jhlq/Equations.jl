import Base.show
show(io::IO,eq::Equation)=print(io,ps(eq))
show(io::IO,ex::Factor)=print(io,ps(ex))

ps(eq::Equation)="$(ps(eq.lhs)) ≖ $(ps(eq.rhs))"
function ps(ex::Expression)
	s=""
	for t in ex
		s*=ps(t)*"+"
	end
	s[1:end-1]
end
function ps(t::Term)
	s=""
	for f in t
		if isa(f,Expression) && length(f)>1
			s*="("*ps(f)*")"*"*"
		else
			s*=ps(f)*"*"
		end
	end
	s[1:end-1]
end
function ps(ar::Array{T,1}) where {T}
	if isempty(ar)
		return "$T[]"
	end
	s="$T["
	for a in ar
		s*=ps(a)*","
	end
	try 
		s=s[1:end-1]*"]"
	catch err
		s=s[1:end-2]*"]"
	end
	return s
end
#function ps{T}(a::T)
#	"$T"
#end
function ps(a)
	io=IOBuffer()
	show(io,a) 
	str=String(take!(io))
end
function ps(c::Component)
	ar=getargs(c)
	s="$(typeof(c))("
	for a in ar
		s*="$(ps(a)),"
	end
	try
		s=s[1:end-1]*")"
	catch err
		s=s[1:end-2]*")"
	end
	return s
end
ps(s::Symbol)=":$s"
ps(n::Number)="$n"


function print(io::IO,u::U)
	print(io,u.x)
	print(io," [")
	print(io,u.units)
	print(io,"]")
end
ps(a::Alt)="Alt($(a.indices))"
function show(io::IO,a::Alt)
	print(io,ps(a))
end
function print(io::IO,a::Alt)
	print(io,"ϵ$(a.indices)")
end
