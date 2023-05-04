using ForwardDiff
mutable struct Fun <: Component
	y#::Function
	x#::Union{Array,Number,Symbol}
	pds::Array{Symbol}
end
#show(io::IO,f::Fun)=print(io,"Fun(func,$(f.x),$(f.pds))")
Fun(y,x)=Fun(deepcopy(y),x,Symbol[])
function *(f1::Fun,f2::Fun)
	if f1.x!=f2.x
		#error("Different arguments not yet supported")
		return expression(Factor[f1,f2])
	end
	return Fun(a->f1.y(a)*f2.y(a),f1.x)
end
function ==(f1::Fun,f2::Fun)
	if !isa(f1.y,Function)||!isa(f2.y,Function)
		return f1.y==f2.y&&f1.x==f2.x&&f1.pds==f2.pds
	end
	for i in 1:3
		if sample(f1,i)!=sample(f2,i)
			return false
		end
	end
	return true
end
function inv(f::Fun)
	if isa(f.y,Function)
		return Fun(a->inv(f.y(a)),f.x,f.pds)
	else
		return Fun(Inv(f.y),f.x,f.pds)
	end
end
function det(f::Fun)
	if isa(f.y,Function)
		return Fun(a->det(f.y(a)),f.x,f.pds)
	else
		return Fun(Det(f.y),f.x,f.pds)
	end
end
function abs(f::Fun)
	if isa(f.y,Function)
		return Fun(a->abs(f.y(a)),f.x,f.pds)
	else
		return Fun(Abs(f.y),f.x,f.pds)
	end
end
function sqrt(f::Fun)
	if isa(f.y,Function)
		return Fun(a->sqrt(f.y(a)),f.x,f.pds)
	else
		return Fun(Sqrt(f.y),f.x,f.pds)
	end
end
function simplify(f::Fun)
	if isa(f.x,Number)
		return f.y(f.x)
	end
	if isa(f.x,Array)
		hascomplex=false
		for a in f.x
			if !isa(a,Number)
				return f
			end
			if isa(a,Complex)
				hascomplex=true
			end
		end
		typ=Float64
		if hascomplex;typ=ComplexF64;end
		if !isa(f.x[1],ForwardDiff.Dual)
			fx=convert(Array{typ},f.x)
		else
			#fx=convert(Array{ForwardDiff.Dual{ForwardDiff.Tag,Float64,1},1},f.x)
			fx=[f.x[1]]
			for i in 2:length(f.x)
				push!(fx,f.x[i])
			end
		end
		return f.y(fx)
	end
	return f
end 
function simplify(ex::Expression,typ::Type{Fun})
	next=Term[]
	for t in ex
		fi=indsin(t,Fun)
		if length(fi)>1
			delf=Int64[]
			nf=t[fi[1]]
			for tit in fi[1]+1:length(t)
				if in(tit,fi)
					nnf=nf*t[tit]
					if isa(nnf,Fun)
						push!(delf,tit)
						nf=nnf
					else
						break
					end
				elseif isa(t[tit],NonAbelian)
					break
				end
			end
			if !isempty(delf)
				t[fi[1]]=nf
				deleteat!(t,delf)
				fi=indsin(t,Fun)
			end
		end
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
					cont=true
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
						if !hasfield(typeof(f),:x)
							cont=false
							break
						end
						f=f.x
						if i==9001
							error("Either an infinite loop has occured or you have a Fun nested over 9000 deep in a Ten!")
						end
					end
					if !cont
						break
					end
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
		r=f.y(rand(length(f.x))*10)
	else
		r=f.y(rand()*10)
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

