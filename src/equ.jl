include("common.jl")
import Base: &, adjoint

mutable struct Equation
	lhs#::EX #relaxed this to allow arbitrary substitution, for example a tensor Ten(A) where A is replaced with an array. Do note that raw arrays should never be present in expressions, unless you are a practitioner of Chaos Magic (ie UNDEFINED results).
	rhs#::EX
	divisions
end
Equation(ex1,ex2)=Equation(ex1,ex2,Set()) 
Equation(ex1)=Equation(ex1,0,Set()) 
function tosym(expr)
	if isa(expr,Symbol)
		return QuoteNode(:($expr))
	elseif isa(expr,Expr)
		if expr.head==:$
			expr=esc(expr.args[1])
		elseif expr.head==:vcat
			for s in 1:length(expr.args)
				for p in 1:length(expr.args[s].args)
					expr.args[s].args[p]=tosym(expr.args[s].args[p])
				end
			end
		else
			if expr.head==:vect
				s1=1
			else
				s1=2
			end
			for s in s1:length(expr.args)
				expr.args[s]=tosym(expr.args[s])
			end
		end
	end
	return expr
end
macro equ(eq)
	neq=Expr(:comparison)
	push!(neq.args,tosym(eq.args[1]),≖,tosym(eq.args[2]))
	neq
end
macro equs(eqs...)
	l=length(eqs)
	eqa=Expr(:vect)
	for i in 1:l
		neq=Expr(:comparison)
		push!(neq.args,tosym(eqs[i].args[1]),≖,tosym(eqs[i].args[2]))
		push!(eqa.args,neq)
	end
	return eqa
end
function print(io::IO,eq::Equation)
	print(io,eq.lhs)
	print(io," = ")
	print(io,eq.rhs)
end
≖(a,b)=Equation(a,b)
complexity(eq::Equation)=complexity(eq.lhs)+complexity(eq.rhs)
isless(eq1::Equation,eq2::Equation)=complexity(eq1)<complexity(eq2)
mutable struct EquationChain
	expressions::Vector
end
EquationChain(a...)=EquationChain([a...])
start(eqc::EquationChain)=(1,eqc.expressions)
function next(eqc::EquationChain,state)
	return (state[2][state[1]],(state[1]+1,state[2]))
end
done(eqc::EquationChain,state)=state[1]>length(state[2])
getindex(eqc::EquationChain,i::Integer)=getindex(eqc.expressions,i)
setindex!(eqc::EquationChain,a)=setindex!(eqc.expressions,a)
length(eqc::EquationChain)=length(eqc.expressions)
push!(eqc::EquationChain,a)=push!(eqc.expressions,a)
function print(io::IO,eqc::EquationChain)
	for exi in 1:length(eqc)-1
		print(io,eqc[exi])
		print(io," ≖ ")
	end
	print(io,eqc[length(eqc)])
end
≖(a::EX,b::Equation)=EquationChain(a,b.lhs,b.rhs)
≖(b::Equation,a::EX)=EquationChain(b.lhs,b.rhs,a)
≖(eqc::EquationChain,a)=push!(eqc,a)
-(eq::Equation)=simplify(-eq.lhs≖-eq.rhs) 
+(eq::Equation,ex::EX)=simplify(eq.lhs+ex≖eq.rhs+ex) 
-(eq::Equation,ex::EX)=simplify(eq.lhs-ex≖eq.rhs-ex) 
*(eq::Equation,ex::EX)=simplify(eq.lhs*ex≖eq.rhs*ex)
/(eq::Equation,ex::EX)=simplify(eq.lhs/ex≖eq.rhs/ex)
+(eq1::Equation,eq2::Equation)=simplify(eq1.lhs+eq2.lhs≖eq1.rhs+eq2.rhs) 
-(eq1::Equation,eq2::Equation)=simplify(eq1.lhs-eq2.lhs≖eq1.rhs-eq2.rhs)
*(eq1::Equation,eq2::Equation)=simplify(eq1.lhs*eq2.lhs≖eq1.rhs*eq2.rhs)
/(eq1::Equation,eq2::Equation)=simplify(eq1.lhs/eq2.lhs≖eq1.rhs/eq2.rhs)
equation(ex::EX)=Equation(ex,0,Any[])
equation(ex1::EX,ex2::EX)=Equation(ex1,ex2,Any[])
adjoint(eq::Equation)=Equation(eq.rhs,eq.lhs)
==(eq1::Equation,eq2::Equation)=eq1.lhs==eq2.lhs&&eq1.rhs==eq2.rhs
function (&)(eq1::Equation,eq2::Equation)
	eq1=simplify(eq1);eq2=simplify(eq2)
	neq=simplify(Equation(replace(eq1.lhs,Dict(eq2.lhs=>eq2.rhs)),replace(eq1.rhs,Dict(eq2.lhs=>eq2.rhs))))
	if neq==eq1
		neq=Equation(eq1.lhs,simplify(eq1.rhs&eq2))
	end
	return neq
end
function (&)(eq::Equation,eqa::Array{Equation})
	for teq in eqa
		eq=eq&teq
	end
	return simplify(eq)
end
(&)(eq::Equation,fun::Function)=fun(eq)
(&)(ex::EX,fun::Function)=fun(ex)
function applyamp(ex::Expression,eq::Equation,simp=true)
	if simp
		ex=simplify(ex)
	end
	eq=simplify(eq)
	if isa(eq.lhs,Symbol)
		if simp
			return simplify(replace(ex,Dict(eq.lhs=>eq.rhs)))
		else
			return replace(ex,Dict(eq.lhs=>eq.rhs))
		end
	end
	m=matches(ex,eq)
	if !isempty(m)
		return simplify(m[1])
	else
		tms=Tuple[]
		_terms=dcterms(ex)
		for t in 1:length(_terms)
			tm=matches(simplify(expression(ex[t])),eq)
			if !isempty(tm)
				_terms[t]=tm[1][1]
			else
				for f in 1:length(_terms[t])
					if isa(_terms[t][f],Component)
						ttm=matches(_terms[t][f],eq)
						if !isempty(ttm)
							_terms[t][f]=ttm[1]
						end
					end
				end
			end
		end
		nex=expression(_terms)
		if simp
			nex=simplify(nex)
		end
		return nex
	end
end
function applyamp(ex::Component,eq::Equation,simp=true)
	if simp
		ex=simplify(ex)
	end
	eq=simplify(eq)
	if isa(eq.lhs,Symbol)
		nex=replace(ex,Dict(eq.lhs=>eq.rhs))
		if simp
			nex=simplify(nex)
		end
		return nex
	end
	m=matches(ex,eq)
	if !isempty(m)
		return simplify(m[1])
	else 
		return ex
	end
end
applyamp(x::Number,eq:.Equation,simp=true)=x
function (&)(ex::Expression,eq::Equation)
	return applyamp(ex,eq)
end
function (&)(ex::Component,eq::Equation)
	return applyamp(ex,eq)
end
function (&)(ex::Symbol,eq::Equation)
	if isa(eq.lhs,Symbol)&&eq.lhs==ex
		return eq.rhs
	end
#	m=matches(ex,eq)
#	if !isempty(m)
#		return simplify(m[1])
#	end
	return ex
end
(&)(x::Number,eq::Equation)=x
function (&)(ex::Union{Ex,Equation},eqa::Array)
	ex=simplify(ex)
	for teq in eqa
		#=if isa(teq,Function)
			ex=ex&teq
		else
			ex=applyamp(ex,teq,false)
		end=#
		ex=ex&teq
	end
	#return simplify!(ex)
	return ex
end
function (&)(eq::Equation,sym::Symbol)
	if isa(eq.lhs,Component)
		s=solve(eq,sym,typeof(eq.lhs))
	else
		s=solve(eq,sym)
	end
	if isa(s,Nothing)
		error("Please implement code to solve $eq for $sym")
	end
#	if isa(s.lhs,Component) #how to avoid infinite recursion?
#		s=s&sym
#	end
	return s
end
function solve(c::Component,sym::Symbol,t::Type)
	print_with_color(:green,"Please implement a solver for $(typeof(c))")
	c
end
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
function simplify(eq::Equation)
	lhs,rhs=simplify(eq.lhs),simplify(eq.rhs)
#	if (isa(rhs,Symbol)&&!isa(lhs,Symbol))||(isa(lhs,Number)&&!isa(rhs,Number)) #this is convenient sometimes but causes breakage
#		return Equation(rhs,lhs)
#	else
		return Equation(lhs,rhs)
#	end
end
function simplify!(eqa::Array{Equation})
	for eq in 1:length(eqa)
		eqa[eq]=simplify(eqa[eq])
	end
	return eqa
end
simplify(eqa::Array{Equation})=simplify!(deepcopy(eqa))
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
pushallunique!(a1::Array,b::Bool)=Void
function uniquefilter(a::Array{T}) where {T}
	pushallunique!(T[],a)
end
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
			teq.rhs=Expression(Term[[teq.rhs],[-1;terms[term]]])
		end
		if !isa(tt,X)
			deleteat!(tt,term)
		end
		teq.lhs=expression(tt)
		push!(m,teq)
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
include("log.jl")
include("der.jl")
include("vec.jl")
function evaluate(eq::Equation,symdic::Dict)
	for key in keys(symdic)
		if symdic[key]==0&&key∈eq.divisions
			error("Assigning zero to a value that the equation has been divided by.")
		end
	end
	return (evaluate(eq.lhs,symdic),evaluate(eq.rhs,symdic))
end
function solve(eq::Equation,sym::Symbol)
	eq=simplify(eq)
	indsl=expandindices(indsin(eq.lhs,sym))
	indsh=expandindices(indsin(eq.rhs,sym))
	if length(indsl)==0||length(indsh)==0
		if length(indsl)==0
			inds=indsh
			lhs=eq.rhs
			rhs=eq.lhs
		else
			inds=indsl
			lhs=eq.lhs
			rhs=eq.rhs
		end
		if length(inds)==1
			inds=inds[1]
			for termi in 1:length(lhs)
				if termi==inds[1]
					continue
				end
				rhs=rhs-expression(lhs[termi])
			end
			lhs=lhs[inds[1]]
			for fac in lhs
				if fac==lhs[inds[2]]
					continue
				end
				rhs=rhs/fac
			end
			lhs=lhs[inds[2]]
			return simplify(Equation(lhs,rhs))
		end
	end
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

include("units.jl")
include("printers.jl")
