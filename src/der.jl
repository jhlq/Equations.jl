type Der <: Component
	x
	dy
end
import Base.ctranspose
function ctranspose(ex::Ex)
	syms=findsyms(ex)
	dy=:t
	if length(syms)==1
		dy=pop!(syms)
	end
	return Der(ex,dy)
end

