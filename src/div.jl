type ╱ <: SingleArg #\diagup
	x
end
Div=╱
function print(io::IO,d::Div)
	print(io,"/($(d.x))")
end
/(x::X,ex::Ex)=expression(Factor[x,Div(ex)])
function /(ex::Expression,x::Ex)
	ap=dcterms(ex)
	for t in ap
		push!(t,Div(x))
	end
	return expression(ap)
end
function divbine!(term::Term)
	dis=indsin(term,Div)
	if isempty(dis)
		return term
	end
	df=Factor[]
	for i in dis
		push!(df,term[i].x)
	end
	deleteat!(term,dis)
	push!(term,Div(simplify(expression(df))))
	return term
end
divbine(term::Term)=divbine!(deepcopy(term))
function divbinedify!(term::Term)
	if !isa(term[end],Div)
		return term
	end
	x=term[end].x
	if isa(x,Expression)
		if length(x)==1
			x=x[1]
		else
			return term
		end
	elseif !isa(x,Array)
		x=[x]
	end
	remove=Integer[]
	for fi in 1:length(x)
		i=indin(term[1:end-1],x[fi])
		if i!=0
			push!(remove,fi)
			deleteat!(term,i)
		elseif isa(x[fi],Number)
			push!(remove,fi)
			unshift!(term,1/x[fi])
		end
	end
	deleteat!(x,remove)
	if isempty(x)
		deleteat!(term,length(term))
	elseif length(x)==1
		term[end].x=x[1]
	else
		term[end].x=simplify(expression(x))
	end
	return term		
end
divbinedify(term::Term)=divbinedify!(deepcopy(term))
function divify!(term::Array)
	dis=indsin(term,Div)
	remove=Int64[]
	for i in dis
		if term[i].x==1
			term[i]=1
		elseif isa(term[i].x,Div)
			term[i]=term[i].x.x
		elseif isa(term[i].x,Expression)
			ap=terms(term[i].x)
			if length(ap)==1
				aprem=Integer[]
				termrem=Integer[]
				for fac in 1:length(ap[1])
					if isa(ap[1][fac],Div)
						push!(term,ap[1][fac].x)
						push!(aprem,fac)
					elseif has(term,ap[1][fac])
						ti=indsin(term,ap[1][fac])
						fi=0
						for tfi in ti
							if !in(tfi,termrem)
								fi=tfi
								break
							end
						end
						if fi!=0
							push!(termrem,fi)
							push!(aprem,fac)
						end
					end
				end
				deleteat!(ap[1],aprem)
				term[i]=Div(expression(ap))
				pushallunique!(remove,termrem)
			end
		else
			invinds=indsin(term,term[i].x)
			removed=findin(invinds,remove)
			deleteat!(invinds,removed)	
			if !isempty(invinds)
				push!(remove,i)
				push!(remove,invinds[end])
			end
		end
	end
	if !isempty(remove)
		#ret=deepcopy(term)
		deleteat!(term,sort!(remove))
		if isempty(term)
			push!(term,1)
		end
		return term
	else
		return term
	end	
end
divify(term::Array)=divify!(deepcopy(term))
divify(x::X)=x
function simplify(ex::Expression,t::Type{Div})
	ap=dcterms(ex)
	for term in 1:length(ap)
		ap[term]=divify!(ap[term]) #this should be phased out
		ap[term]=divbine!(ap[term])
		ap[term]=divbinedify!(ap[term]) #this needn't be called if divify succeeded however it will fail if divbine was called before and in that case divbine doesn't need be called here...
	end
	return simplify(expression(ap))
end
function simplify(d::Div)
	x=simplify(d.x)
	if isa(x,Number)
		return 1/x
	end
	return Div(x)
end
function matches(eq::Equation,t::Type{Div})
	lhs=terms(eq.lhs)
	rhs=terms(eq.rhs)
	m=Equation[]
	for term in lhs
		for fac in term
			nl=deepcopy(lhs)
			nr=deepcopy(rhs)
			for t in nl
				push!(t,Div(deepcopy(fac)))
			end
			for t in nr
				push!(t,Div(deepcopy(fac)))
			end
			nl=simplify(expression(nl))
			nr=simplify(expression(nr))
			teq=Equation(nl,nr,Any[fac])
			if !(teq∈m)&&!(isa(nl,Number)&&isa(nr,Number)&&nl!=nr) #prevents 1=0 from x=0
				push!(m,teq)
			end
		end
	end
	return m
end
