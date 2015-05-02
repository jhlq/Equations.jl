type Der <: Component
	x
	dy
end
#=import Base.ctranspose
function ctranspose(ex::Ex)
	syms=findsyms(ex)
	dy=:t
	if length(syms)==1
		dy=pop!(syms)
	end
	return Der(ex,dy)
end =#
function matches(d::Der)
	ap=addparse(d.x)
	nap=Array[]
	for term in ap
		push!(nap,Any[Der(Expression(term),d.dy)]) #the Any[] is for convenient construction by calling expression
	end
	return expression(nap)
end
function simplify(d::Der)
	if isa(d.x,Number)
		return 0
	elseif d.x==d.dy
		return 1
	end
end
