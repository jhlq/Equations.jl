mutable struct Fun <: Component
	y::Function
	x::Any
	pds::Array{Symbol}
end
Fun(y,x)=Fun(y,x,Symbol[])
function *(f1::Fun,f2::Fun)
	if f1.x!=f2.x
		#error("Different arguments not yet supported")
		return expression(Factor[f1,f2])
	end
	f(a)=f1.y(a)*f2.y(a)
	return Fun(f,f1.x)
end
==(f1::Fun,f2::Fun)=f1.x==f2.x&&f1.pds==f2.pds #evaluate randomly y1==y2?
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
		return f.y(f.x)
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
			if isa(t[tii].x,Fun)
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
					if pd.d==f.x||(isa(f.x,Array)&&in(pd.d,f.x))
						nt[ffi].x=pd*f
						push!(deli,pdiii)
						break
					end
				end
			end
		end
		deleteat!(nt,deli)
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

mutable struct PD<:NonAbelian
  d::Symbol
end
function *(d::PD,f::Fun)
  h=1e-9
  if isa(f.pds,Symbol)
    npds=[f.pds]
  else
    npds=deepcopy(f.pds)
  end
  push!(npds,d.d)
  if isa(f.x,Symbol)&&f.x==d.d
    fp(a)=(f.y(a+h)-f.y(a))/h
    return Fun(fp,f.x,npds)
  end
  if isa(f.x,Array)
    l=length(f.x)
    for i in 1:l
      if f.x[i]==d.d
        ha=zeros(l)
        ha[i]+=h
        fpa(a)=(f.y(a+ha)-f.y(a))/h
        return Fun(fpa,f.x,npds)
      end
    end
  end
  return Term[d,f]
end
function *(d::PD,t::Ten)
  if isa(t.x,Fun)
    t2=deepcopy(t)
    t2.x=d*t2.x
    return t2
  end
  return Term[d,t]
end
replace(c::PD,symdic::Dict)=c

