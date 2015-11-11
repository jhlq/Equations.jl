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
		s*=ps(f)*"*"
	end
	s[1:end-1]
end
function ps{T}(ar::Array{T,1})
	if isempty(ar)
		return "$T[]"
	end
	s="$T["
	for a in ar
		s*=ps(a)*","
	end
	s[1:end-1]*"]"
end
#function ps{T}(a::T)
#	"$T"
#end
function ps(a)
	io=IOBuffer()
	show(io,a) 
	str=takebuf_string(io)
end
function ps(c::Component)
	ar=getargs(c)
	s="$(typeof(c))("
	for a in ar
		s*="$(ps(a)),"
	end
	s[1:end-1]*")"
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
