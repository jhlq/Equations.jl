import Base./

immutable ╱ <: SingleArg #\diagup
	x
end
Div=╱
/(x::X,ex::Ex)=expression(Factor[x,Div(ex)])
function /(ex::Expression,x::Ex)
	ap=dcterms(ex)
	for t in ap
		push!(t,Div(x))
	end
	return expression(ap)
end

function divify!(term::Array)
	dis=indsin(term,Div)
	remove=Int64[]
	for i in dis
		if term[i].x==1
			term[i]=1
		elseif isa(term[i].x,Div)
			term[i]=term[i].x.x
		elseif isa(term[i].x,Expression)
			ap=dcterms(term[i].x)
			if length(ap)==1
				aprem=Integer[]
				for fac in 1:length(ap[1])
					if isa(ap[1][fac],Div)
						push!(term,ap[1][fac].x)
						push!(aprem,fac)
					end
				end
				deleteat!(ap[1],aprem)
				term[i]=Div(expression(ap))
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
		ret=deepcopy(term)
		deleteat!(ret,sort!(remove))
		if isempty(ret)
			push!(ret,1)
		end
		return ret
	else
		return term
	end	
end
divify(term::Array)=divify!(deepcopy(term))
divify(x::X)=x
function simplify(ex::Expression,t::Type{Div})
	ap=dcterms(ex)
	for term in 1:length(ap)
		ap[term]=divify!(ap[term])
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
