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
		pdi=indsin(t,PD)
		fti=[]
		for tii in ti
			if has(t[tii].x,Fun)
				push!(fti,tii)
			elseif alltyp(t[tii].x,PD)
				push!(pdi,tii)
			end
		end
		sort!(pdi)
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
					if isa(pd,Ten)
						deone=false
						for pdx in pd.x
							if pdx.d==f.x||(isa(f.x,Array)&&in(pdx.d,f.x))
								deone=true
							end
						end
						if deone
							for pdxi in 1:length(pd.x)
								pd.x[pdxi]=pd.x[pdxi]*f
							end
							push!(deli,ffi)
							break
						end
					end
					if !in(ffi,deli)&&(pd.d==f.x||(isa(f.x,Array)&&in(pd.d,f.x)))
						nt[ffi]=pd*f
						push!(deli,pdiii)
						break
					end
				elseif in(ffi,fti)
					f=nt[ffi].x
					#cont=true
					for i in 1:9001 #is this loop really necessary?
						if isa(f,Fun)
							break
						elseif isa(f,Array)
						#	cont=false #can't be certain if the array contains something differentiable, maybe jump into the array and differentiate every element? #has Fun
						#	if has(f,Fun)
						#		cont=true
						#	end
							break
						end
						f=f.x
						if i==9001
							error("Either an infinite loop has occured or you have a Fun nested over 9000 deep in a Ten!")
						end
					end
					#if !cont
					#	break
					#end
					if isa(pd,Ten)
						if !isa(f,Array)
							deone=false
							for pdx in pd.x
								if pdx.d==f.x||(isa(f.x,Array)&&in(pdx.d,f.x))
									deone=true
								end
							end
							if deone
								for pdxi in 1:length(pd.x)
									pd.x[pdxi]=pd.x[pdxi]*f
									if !isa(nt[ffi].x,Fun)
										npdx=nt[ffi].x
										c=npdx.x
										for i in 1:9000
											if isa(c.x,Fun)
												c.x=pd.x[pdxi]
												pd.x[pdxi]=npdx
												break
											end
											c=c.x
										end
									end
								end
								push!(deli,ffi)
								pushall!(pd.indices,nt[ffi].indices)
								break
							end
						end
					elseif isa(f,Array)||(pd.d==f.x||(isa(f.x,Array)&&in(pd.d,f.x)))
						c=nt[ffi]
						for i in 1:9000
							if isa(c.x,Fun)
								c.x=pd*f
								break
							elseif isa(c.x,Array)
								for cxi in 1:length(c.x)
									c.x[cxi]=pd*c.x[cxi]
								end
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
		r=f.y(rand(length(f.x)))
	else
		r=f.y(rand())
	end
	if seed!=0
		Random.seed!(Int(round(time())))
	end
	return r
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

