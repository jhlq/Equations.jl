import Base: norm, dot, cross

immutable Vec <: NonAbelian
	v
end
Vec(a...)=Vec([a...])
@delegate Vec.v [getindex, setindex!, start, next, done, length]
#getindex(v::Vec,i::Integer)=getindex(v.v,i)
function .*(v::Vec,a::Factor)
	nv=Any[]
	for val in v.v
		push!(nv,val*a)
	end
	return Vec(nv)
end
immutable Cross <: Component
	x
	y
end
function getvec(c::Cross)
	ind=indsin(c,Vec)
	args=deepcopy(getargs(c))
	ex=args[ind[1][1]][ind[1][2][1][1]]
	vec=ex[ind[1][2][1][2][1]]
	deleteat!(ex,ind[1][2][1][2][1])
	return (ex,vec)
end
function getvec(ex::Expression)
	@assert length(ex)==1
	ind=indsin(ex,Vec)
	ex=deepcopy(ex)
				#implement support for multiple vectors/terms
	vec=ex[1][ind[1][2][1]]
	deleteat!(ex[1],ind[1][2][1])
	return (extract(ex),vec)
end
function cross(v1::Vec,v2::Vec)
	if isa(v1.v,Vector)&&isa(v2.v,Vector)
		return Vec(cross(v1.v,v2.v))
	end
	return Cross(v1,v2)
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
norm(ex::Ex)=Norm(ex)
function norm(vec::Vec)
	if isa(vec.v,Vector)
		return norm(vec.v)
	elseif isa(vec.v,Expression)
		ex,v=getvec(vec.v)
		return ex*norm(v)
	else
		return Norm(vec)
	end
#	has(vec.v,Ex)?Norm(vec):norm(vec.v)
end
function simplify(n::Norm)
	if isa(n.x,Expression)&&has(n.x,Vec)
		ex,v=getvec(n.x)
		return ex*norm(v)
	end
	norm(n.x)
end
type Dot <: Component
	x
	y
end
print(io::IO,c::Dot)=print(io,c.x,'⋅',c.y)
function dot(v1::Vec,v2::Vec)
	if isa(v1.v,Array)&&isa(v2.v,Array)&&length(v1.v)==length(v2.v)
		ex=Expression(Term[Factor[v1.v[1]*v2.v[1]]])
		for t in 2:length(v1.v)
			push!(ex,Factor[v1.v[t],v2.v[t]])
		end
		return simplify(ex)
	end
	return Dot(v1,v2)
end
function simplify(d::Dot)
	if !isempty(methods(dot,(typeof(d.x),typeof(d.y))))
		return dot(d.x,d.y)
	end
	return d
end
