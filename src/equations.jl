include("common.jl")

type Equation
	lhs::EX
	rhs::EX
	divisions
end
Equation(ex1::EX,ex2::EX)=Equation(ex1,ex2,Any[]) #or set?
function print(io::IO,eq::Equation)
	print(io, "Equation(")
	print(io,eq.lhs)
	print(io,'=')
	print(io,eq.rhs)
	print(io,')')
end
#import Core.is
# ===(a::EX,b::EX)=Equation(a,b)
≖(a::EX,b::EX)=Equation(a,b)
equation(ex::EX)=Equation(ex,0,Any[])
equation(ex1::EX,ex2::EX)=Equation(ex1,ex2,Any[])
==(eq1::Equation,eq2::Equation)=eq1.lhs==eq2.lhs&&eq1.rhs==eq2.rhs
function equivalent(eq1::Equation,eq2::Equation)
	m=matches(eq2)
	for eq in m
		if eq1==eq
			return true
		end
	end
	return false
end
simplify!(eq::Equation)=begin;eq.lhs=simplify!(eq.lhs);eq.rhs=simplify!(eq.rhs);eq;end #the ! functions are not complete
simplify(eq::Equation)=Equation(simplify(eq.lhs),simplify(eq.rhs))
function simplify!(eqa::Array{Equation})
	for eq in 1:length(eqa)
		eqa[eq]=simplify(eqa[eq])
	end
	return eqa
end
simplify(eqa::Array{Equation})=simplify!(deepcopy(eqa))
relations=Equation[]
#eq1=Equation(cos(:x)-sin(:x+pi/2),0)
function pushallunique!(a1::Array,a2::Array)
	for d in a2
		if !(d∈a1)
			push!(a1,d)
		end
	end
	return a1
end
function pushallunique!(a1::Array,d)
	if !(d∈a1)
		push!(a1,d)
	end
	return a1
end
pushallunique!(a1::Array,b::Bool)=Nothing
uniquefilter{T}(a::Array{T})=pushallunique!(T[],a)
include("matchers.jl")
matchfuns=Function[]
push!(matchfuns,quadratic)
function matches(eq::Equation)
	m=Equation[]
	if eq.lhs==0
		return m #it only moves from left to right
	end
	eq=simplify(eq)
	terms=dcterms(eq.lhs)
	for term in 1:length(terms)
		teq=deepcopy(eq)
		tt=deepcopy(terms)
		if typeof(teq.rhs)==Expression
			nterm=Factor[]
			push!(nterm,-1)
			for fac in terms[term]
				push!(nterm,fac)
			end
			push!(teq.rhs,nterm)
		else
			teq.rhs=Expression(Term[[teq.rhs],[-1,terms[term]]])
		end
		if !isa(tt,X)
			deleteat!(tt,term)
			#if isempty(tt)
			#	push!(tt,Factor[0])
			#end
		end
		teq.lhs=expression(tt)
		push!(m,teq)
#=		if tt!=0
			dmt=matches(teq,Div)
			for d in dmt
				push!(m,d)
			end
		end

		tm=matches(teq)
		if tm!=false
			for tteq in tm
				if !(tteq∈m)
					push!(m,tteq)
				end
			end
		end
=#
	end
	for teq in m
		teq.rhs=sumnum(componify(teq.rhs))
		teq.lhs=sumnum(componify(teq.lhs))
	end
	return m
end
matches(ex::EX)=matches(equation(ex))
function matches(eq::Equation,fun::Function)
	m=Equation[]
	pushallunique!(m,fun(eq))
	return m
end
matches(ex::EX,fun::Function)=matches(equation(ex),fun)
function matches(eq::Equation,all::Bool)
	if eq.lhs==0
		return false #it only moves from left to right
	end
	eq=simplify(eq)
	m=Equation[]
	for fun in matchfuns
		pushallunique!(m,fun(eq))
	end
	pushallunique!(m,matches(eq,Div))
	pushallunique!(m,matches(eq,Sqrt))
	pushallunique!(m,matches(eq))	
	return m
end
matches(ex::EX,all::Bool)=matches(equation(ex),all)
function matches(eqa::Array{Equation})
	neqa=deepcopy(eqa)
	for eq in eqa
		m=matches(eq)
		for teq in m
			push!(neqa,teq)
		end
	end
	return neqa
end
function matches!(eqa::Array{Equation})
	leqa=length(eqa)
	for eq in 1:leqa
		m=matches(eqa[eq])
		for teq in m
			if teq!=false&&indin(eqa,teq)==0
				push!(eqa,teq)
			end
		end
	end
	return eqa
end
function matches(eq::Equation,recursions::Integer)
	m=matches(eq)
	for r in 1:recursions
		matches!(m)
	end
	return m
end
matches(ex::EX,rec::Integer)=matches(equation(ex),rec)
include("div.jl")
include("sqrt.jl")
include("pow.jl")
include("der.jl")
function evaluate(eq::Equation,symdic::Dict)
	for key in keys(symdic)
		if symdic[key]==0&&key∈eq.divisions
			error("Assigning zero to a value that the equation has been divided by.")
		end
	end
	return (evaluate(eq.lhs,symdic),evaluate(eq.rhs,symdic))
end
function solve(eq::Equation,rec::Integer=1)
	seq=simplify(eq)
	mat=matches(seq,rec)
	sol=Equation[]
	for m in mat
		if isa(m.lhs,Symbol)
			push!(sol,m)
		end
	end
	return sol
end
function solve(eq::Equation,op)
	seq=simplify(eq)
	mat=matches(seq,op)
	sol=Equation[]
	for m in mat
		if length(m.lhs)==1
			push!(sol,m)
		end
	end
	return sol
end
solve(ex::Ex)=solve(equation(ex))
solve(ex::Ex,a)=solve(equation(ex),a)
