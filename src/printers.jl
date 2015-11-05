import Base.show
show(io::IO,eq::Equation)=print(io,ps(eq))
show(io::IO,ex::Factor)=print(io,ps(ex))

ps(eq::Equation)="$(typeof(eq))($(ps(eq.lhs)),$(ps(eq.rhs)))"
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
