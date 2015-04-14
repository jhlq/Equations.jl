import Base./
#include("common.jl")

type ÷ <: SingleArg #\div
	x
end
Div=÷
/(x::X,ex::Ex)=Expression([x,Div(ex)])
function /(ex::Expression,x::Ex)
	ap=addparse(ex)
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
			ap=addparse(term[i].x)
			if length(ap)==1
				aprem=Integer[]
				for fac in 1:length(ap[1])
					if isa(ap[1][fac],Div)
						push!(term,ap[1][fac].x)
						push!(aprem,fac)
					end
				end
				deleteat!(ap[1],aprem)
				term[i].x=expression(ap)
				#println(term)
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
function simplify!(d::Div)
	x=simplify!(getarg(d))
	if isa(x,Number)
		return 1/x
	end
	d.x=x
	return d
end
simplify(d::Div)=simplify!(deepcopy(d))
