immutable Vec <: NonAbelian
	v
end
immutable Cross <: Component
	x
	y
end
function simplify(c::Cross)
	if (isa(c.x,Vec)&&isa(c.y,Vec)&&isa(c.x.v,Vector)&&isa(c.y.v,Vector))
		return Vec(cross(c.x.v,c.y.v))
	end
	if isa(c.x,Expression)&&isa(c.y,Expression)
		ind=indsin(c,Vec)
		args=deepcopy(getargs(c))
		ex1=args[ind[1][1]][ind[1][2][1][1]]
		v1=ex1[ind[1][2][1][2][1]]
		deleteat!(ex1,ind[1][2][1][2][1])
		ex2=args[ind[2][1]][ind[2][2][1][1]]
		v2=ex2[ind[2][2][1][2][1]]
		deleteat!(ex2,ind[2][2][1][2][1])
		return extract(expression(ex1))*extract(expression(ex2))*Vec(cross(v1.v,v2.v))
	end
	return c
end
print(io::IO,c::Cross)=print(io,c.x,'×',c.y)
type Norm <: Component
	x
end
Base.norm(ex::Ex)=Norm(ex)
Base.norm(vec::Vec)=has(vec.v,Ex)?Norm(vec):norm(vec.v)
simplify(n::Norm)=norm(n.x)

