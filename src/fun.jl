using ForwardDiff
mutable struct Fun <: Component
	y::Function
	x#::Union{Array,Number,Symbol}
	pds::Array{Symbol}
end
show(io::IO,f::Fun)=print(io,"Fun(func,$(f.x),$(f.pds))")
Fun(y,x)=Fun(y,x,Symbol[])
function *(f1::Fun,f2::Fun)
	if f1.x!=f2.x
		#error("Different arguments not yet supported")
		return expression(Factor[f1,f2])
	end
	f(a)=f1.y(a)*f2.y(a)
	return Fun(f,f1.x)
end
function ==(f1::Fun,f2::Fun)
	for i in 1:3
		if sample(f1,i)!=sample(f2,i)
			return false
		end
	end
	return true
end
function simplify(f::Fun)
	if isa(f.x,Number)
		return f.y(f.x)
	end
	if isa(f.x,Array)
		for a in f.x
			if !isa(a,Number)
				return f
			end
		end
		return f.y(convert(Array{Float64},f.x))
	end
	return f
end 
function simplify(ex::Expression,typ::Type{Fun})
	next=Term[]
	for t in ex
		fi=indsin(t,Fun)
		ti=indsin(t,Ten)
		fti=[]
		for tii in ti
			if has(t[tii].x,Fun)
				push!(fti,tii)
			end
		end
		pdi=indsin(t,PD)
		fil=length(fi)
		pdil=length(pdi)
		ftil=length(fti)
		tl=length(t)
		if (fil+ftil)*pdil==0
			push!(next,t)
			continue
		end
		nt=deepcopy(t)
		deli=[]
		for pdii in 1:pdil
			pdiii=pdi[pdil-pdii+1]
			pd=nt[pdiii]
			for ffi in pdiii+1:tl
				if in(ffi,fi)
					f=nt[ffi]
					if pd.d==f.x||(isa(f.x,Array)&&in(pd.d,f.x))
						nt[ffi]=pd*f
						push!(deli,pdiii)
						break
					end
				elseif in(ffi,fti)
					f=nt[ffi].x
					for i in 1:9001
						if isa(f,Fun)
							break
						end
						f=f.x
						if i==9001
							error("Either an infinite loop has occured or you have a Fun nested over 9000 deep in a Ten!")
						end
					end
					if pd.d==f.x||(isa(f.x,Array)&&in(pd.d,f.x))
						c=nt[ffi]
						for i in 1:9000
							if isa(c.x,Fun)
								c.x=pd*f
								break
							end
							c=c.x
						end
						push!(deli,pdiii)
						break
					end
				end
			end
		end
		deleteat!(nt,sort!(deli))
		push!(next,nt)
	end
	return Expression(next)
end
function replace(c::Fun,symdic::Dict)
	if isa(c.x,Array{Symbol})
		c.x=convert(Array{Any},c.x)
	end
	x=replace(c.x,symdic)
	if x==c.x
		return c
	end
	return Fun(c.y,x,c.pds)
end
componify(f::Function)=f
has(f::Function,a)=false
maketype(c::Fun,fun)=typeof(c)(c.y,fun(c.x),c.pds)
function sample(f::Fun,seed=0)
	if seed!=0
		Random.seed!(seed)
	end
	if isa(f.x,Array)
		return f.y(rand(length(f.x)))
	else
		return f.y(rand())
	end
end

mutable struct PD<:NonAbelian
	d::Symbol
end
function *(d::PD,f::Fun)
	npds=deepcopy(f.pds)
	push!(npds,d.d)
	if isa(f.x,Symbol)&&f.x==d.d
		fp=x->ForwardDiff.derivative(f.y,x)
		return Fun(fp,f.x,npds)
	else
		tf=f.y(rand(length(f.x)))
		l=length(f.x)
		if isa(f.x,Array)&&isa(tf,Number)
			for i in 1:l
				if f.x[i]==d.d
					fp=a->ForwardDiff.gradient(f.y,a)[i]
					return Fun(fp,f.x,npds)
				end
			end
		elseif isa(f.x,Array)&&isa(tf,Array)
			for i in 1:l
				if f.x[i]==d.d
					fp=a->reshape(ForwardDiff.jacobian(f.y,a)[:,i],size(tf))
					return Fun(fp,f.x,npds)
				end
			end
		end
	end
	return expression(Factor[d,f])
end
function *(d::PD,t::Ten)
	if isa(t.x,Fun)
		t2=deepcopy(t)
		t2.x=d*t2.x
		return t2
	end
	return expression(Factor[d,t])
end
replace(c::PD,symdic::Dict)=c

