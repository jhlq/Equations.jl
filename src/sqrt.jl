import Base.sqrt
immutable Sqrt <: SingleArg #using \sqrt causes problems, maybe (√) works? 
	x
end
sqrt(a)=Sqrt(a)

function simplify(sq::Sqrt)
	sq=Sqrt(simplify(sq.x))
	if isa(sq.x,Number)
		if isreal(sq.x)&&sq.x<0
			return sqrt(complex(sq.x))
		else
			return sqrt(sq.x)
		end
	elseif isa(sq.x,Expression)
		ap=addparse(sq.x)
		if length(ap)==1
			facs=ap[1]
			nfacs=length(facs)
			if iseven(nfacs)
				for p in permutations(facs)
					if p[1:nfacs/2]==p[nfacs/2+1:nfacs]
						return simplify(Expression(p[1:nfacs/2]))
					end
				end
			end
		end
	elseif isa(sq.x,Pow)
		return Pow(sq.x.x,sq.x.y/2)
	end
	return sq
end
function matches(eq::Equation,t::Type{Sqrt})
	lhs=deepcopy(eq.lhs)
	rhs=deepcopy(eq.rhs)
	m=Equation[]
	push!(m,Equation(Sqrt(lhs),Sqrt(rhs)))
	push!(m,Equation(Sqrt(lhs),-Sqrt(rhs)))
	return simplify!(m)
end
