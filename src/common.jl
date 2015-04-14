import Base.push!

abstract Component
abstract SingleArg <: Component
==(sa1::SingleArg,sa2::SingleArg)=sa1.x==sa2.x #getfield of names for more general, getfield(a,names(a)[1])
function getarg(c::Component,n::Integer=1)
	getfield(c,names(c)[n])
end
type Components <: Component
	components
	coef
end
type Term
	factors
end
function ==(t1::Term,t2::Term)
	for p in permutations(t2.factors)
		if t1.factors==p
			return true
		end
	end
	return false
end
function ==(cs1::Components,cs2::Components)
	nc=length(cs1.components)
	if nc != length(cs2.components)
		return false
	else
		for c in 1:nc
			if length(indsin(cs1.components,cs1.components[c]))!=length(indsin(cs2.components,cs1.components[c]))
				return false
			end
		end
	end
	return true
end

type Expression #<: Component?
	components::Array{Any}
end
type ApExpression #<: Component?
	components::Array{Any}
	ap::Array{Term}
end
function expression(a::Array{Array})
	if isempty(a)
		return 0
	end
	ex=Expression(Any[])
	for cc in a
		for c in cc
			push!(ex.components,c)
		end
		push!(ex.components,:+)
	end
	deleteat!(ex.components,length(ex.components))
	return ex
end
function expression(a::Array{Term})
	if isempty(a)
		return 0
	end
	ex=Expression(Any[])
	for cc in a
		push!(ex.components,cc.factors)
		push!(ex.components,:+)
	end
	deleteat!(ex.components,length(ex.components))
	return ex
end
expression(t::Term)=Expression(t.factors)
ctranspose(t::Term)=Expression(t.factors)
#ctranspose(a::Array{Term})=expression(a)
function expression(cs::Array{Components})
	if isempty(cs)
		return Expression([0])
	end
	ex=Expression(Any[])
	for cc in cs
		if cc.coef!=0
			if cc.coef!=1||isempty(cc.components) 
				push!(ex.components,cc.coef)
			end
			for c in cc.components
				push!(ex.components,c)
			end
			push!(ex.components,:+)
		end
	end
	if length(ex.components)==0
		return Expression([0])
	else
		deleteat!(ex.components,length(ex.components))
		return ex
	end
end

==(ex1::Expression,ex2::Expression)=ex1.components==ex2.components
==(ex::Expression,zero::Integer)=length(ex.components)==1&&ex.components[1]==zero
push!(ex::Expression,a)=push!(ex.components,a)
function ==(ex1::ApExpression,ex2::ApExpression)
	if length(ex1.ap)!=length(ex2.ap)
		return false
	end
	for p1 in permutations(ex1.ap)
		cont=false
		for l in 1:length(p1)
			if p1[l]!=ex2.ap[l]
				cont=true
				break
			end
		end
		if cont
			continue
		end
		return true
	end
	return false
end

N=Union(Number,Symbol)
X=Union(Number,Symbol,Component)
Ex=Union(Symbol,Component,Expression)
EX=Union(Number,Symbol,Component,Expression)

expression(x::X)=Expression([x])

push!(x::X,a)=Expression([x,a])
+(ex1::Expression,ex2::Expression)=begin;ex=deepcopy(ex1);push!(ex.components,:+);push!(ex.components,ex2);ex;end
+(ex::Expression,a::X)=begin;ex=deepcopy(ex);push!(ex.components,:+);push!(ex.components,a);ex;end
-(ex::Expression,a::X)=begin;ex=deepcopy(ex);push!(ex.components,:+);push!(ex.components,-1);push!(ex.components,a);ex;end
-(a::X,ex::Expression)=a+(-1*ex)#begin;ex=deepcopy(ex);unshift!(ex.components,:+);unshift!(ex.components,-a);unshift!(ex.components,-1);ex;end
-(ex1::Expression,ex2::Expression)=begin;ex=deepcopy(ex1);push!(ex.components,:+);push!(ex.components,-1);push!(ex.components,ex2);ex;end
+(a::X,ex::Expression)=begin;ex=deepcopy(ex);insert!(ex.components,1,:+);insert!(ex.components,1,a);ex;end
#-(ex::Expression,a)=begin;ex=deepcopy(ex);push!(ex.components,:+);push!(ex.components,-1);push!(ex.components,a);ex;end
#-(a,ex::Expression)=begin;ex=deepcopy(ex);insert!(ex.components,1,:+);insert!(ex.components,1,-1);insert!(ex.components,1,a);ex;end
*(ex1::Expression,ex2::Expression)=Expression([deepcopy(ex1),deepcopy(ex2)])
#*(ex::Expression,a)=begin;ex=deepcopy(ex);push!(ex.components,a);ex;end
#*(a,ex::Expression)=begin;ex=deepcopy(ex);insert!(ex.components,1,a);ex;end
/(ex::Ex,n::Number)=*(1/n,ex)
function *(a::X,ex::Expression)
	ex=deepcopy(ex)
	insert!(ex.components,1,a)
	ps=findin(ex.components,[:+])
	nps=length(ps)
	if nps==0
		return ex
	else
		for p in ps
			insert!(ex.components,p+1,a)
		end
		return ex
	end
end

*(a::Number,c::Component)=Expression([a,c])
*(c1::Union(Component,Symbol),c2::Union(Component,Symbol))=Expression([c1,c2])
function *(ex::Expression,x::EX)
	ap=addparse(ex)
	for t in ap
		push!(t,x)
	end
	return expression(ap)
end
-(c1::Component,c2::Component)=+(c1,-1*c2)
#-(c::Component,a)=+(c,-1*a)
#-(a,c::Component)=+(-1*a,c)
+(c1::Component,c2::Component)=Expression([c1,:+,c2])
+(c::Component,ex::Expression)=Expression([c,:+,ex])
+(ex::Expression,c::Component)=Expression([ex,:+,c])
#+(c::Component,a)=Expression([c,:+,a])
#+(a,c::Component)=Expression([a,:+,c])

+(x1::X,x2::X)=Expression([x1,:+,x2])
-(x1::X,x2::X)=Expression([x1,:+,-1,x2])
-(x::X)=Expression([-1,x])
-(ex::Expression)=-1*ex
*(x1::X,x2::X)=Expression([x1,x2])

abstract Operation <: Component

function indin(array,item)
	ind=0
	for it in array
		ind+=1
		if it==item
			return ind
		end
	end
	return 0
end
function indsin(array,item)
	ind=Int64[]
	for it in 1:length(array)
		if array[it]==item
			push!(ind,it)
		end
	end
	return ind
end
function indsin(array,typ::Type)
	ind=Int64[]
	for it in 1:length(array)
		if isa(array[it],typ)
			push!(ind,it)
		end
	end
	return ind
end
function addparse(ex::Expression)
	#ex=componify(ex)
	adds=findin(ex.components,[:+])
	nadd=length(adds)+1
	parsed=Array(Array,0)
	s=1
	for add in adds
		push!(parsed,ex.components[s:add-1])
		s=add+1
	end
	push!(parsed,ex.components[s:end])
	return parsed
end
addparse(x::X)=Array[Any[x]]
function addparse(ex::Expression,term::Bool)
	adds=findin(ex.components,[:+])
	nadd=length(adds)+1
	parsed=Array(Term,0)
	s=1
	for add in adds
		push!(parsed,Term(ex.components[s:add-1]))
		s=add+1
	end
	push!(parsed,Term(ex.components[s:end]))
	return parsed
end
addparse(x::X,term::Bool)=Array[Term([x])]
function has(term1,term2)
	if length(term1)<length(term2)
		return false
	end
	for p1 in permutations(term1)
		for p2 in permutations(term2)
			for l in 1:length(term2)
				if p1[1:l]==p2[1:l]
					return true
				end
			end
		end
	end
	return false
end
function componify_dep(ex::Expression,raw=false)
	lex=length(ex.components)
	stuff=Array(Any,0)	
	for term in 1:lex
		com=ex.components[term]
		if typeof(com)==Expression
			rex=componify(com,true)
			stuff=[stuff,rex]
		else
			stuff=[stuff,com]
		end
	end	
	if raw==true
		return stuff
	else
		return Expression(stuff)
	end		
end
function componify(ex::Expression,raw=false)
	ap=addparse(ex)
	for term in 1:length(ap)
		exs=Expression[]
		xs=X[]
		for fac in ap[term]
			if isa(fac,Array)
				push!(exs,componify(Expression(fac)))
			elseif isa(fac,Expression)
				push!(exs,componify(fac))
			elseif isa(fac,Component)
				fac.x=componify(fac.x)
				push!(xs,fac)
			else
				push!(xs,fac)
			end
		end
		if isempty(exs)
			continue
		else
			tap=addparse(exs[1])
			for x in xs
				for tterm in tap
					push!(tterm,x)
				end
			end
			exs[1]=expression(tap)
			while length(exs)>1
				ap1=addparse(exs[1])
				ap2=addparse(exs[2])
				lap1,lap2=length(ap1),length(ap2)
				multed=Array[]
				for l in 1:lap1*lap2
					push!(multed,Any[])
				end
				for l1 in 0:lap1-1
					for l2 in 1:lap2
						for fac in ap1[l1+1]
							push!(multed[l2+l1*lap2],fac)
						end
						for fac in ap2[l2]
							push!(multed[l2+l1*lap2],fac)
						end
					end
				end
				exs[2]=expression(multed)
				deleteat!(exs,1)
			end
			ap[term]=exs[1].components
		end
	end
	if raw
		return ap
	else
		return expression(ap)
	end
end
componify(c::Component)=begin;c=deepcopy(c);c.x=componify(c.x);c;end
componify(x::N)=x
function simplify_dep2(ex::Expression)
	componify(sumnum(ex))
end
function simplify_dep(ex::Expression)
	ex=deepcopy(ex)
	ex=componify(ex)
#	lex=length(ex.components)
	cs=Array(Components,0)
#	adds=findin(ex.components,[:+])
#	insert!(adds,1,0)
#	push!(adds,lex+1)
	adds=addparse(ex)
	nadds=length(adds)
	for add in 1:nadds
		tcs=Array(Ex,0)
		coef=1
		for term in adds[add]
			if typeof(term)<:Ex
				push!(tcs,term)
			elseif typeof(term)<:Number
				coef*=term
			else			
				warn("Don't know how to handle $term")
			end
		end
		com=Components(tcs,coef)
		ind=indin(cs,com)
		if ind==0
			push!(cs,com)
		else
			cs[ind].coef+=com.coef
		end
	end
	exa=Any[]
	for c in cs
		if c.coef!=0
			if isempty(c.components)
				push!(exa,c.coef)
				push!(exa,:+)
			else
				if length(c.components)==1
					if c.coef!=1
						push!(exa,c.coef)
					end
					push!(exa,c.components[1])
					push!(exa,:+)
				else
					push!(exa,c)
					push!(exa,:+)
				end
			end
		end	
	end
	if length(exa)>0
		deleteat!(exa,length(exa))
	end
	if length(exa)==1
		return exa[1]
	else
		return Expression(exa)
	end
end
function extract(ex::Expression)
	if length(ex.components)==1
		return ex.components[1]
	end
	return ex
end
include("div.jl")
include("sqrt.jl")
function simplify(ex::Expression)
	ex=deepcopy(ex)
	tex=0
	nit=0
	while tex!=ex
		tex=ex
		ex=sumsym(sumnum(componify(ex)))
		ap=addparse(ex)
		for term in 1:length(ap)
			ap[term]=divify(ap[term])
			for fac in 1:length(ap[term])
				#println(fac,simplify(fac))
				ap[term][fac]=simplify(ap[term][fac])
				#println(term)
			end
		end
		ex=extract(expression(ap)) #better to check if res::N before calling expression instead of extracting?
		nit+=1
		if nit>10
			warn("Stuck in simplify! Iteration #$nit: $res")
		end
	end
	return ex 
end
simplify!(ex::Expression)=begin;ex.components=simplify(ex).components;ex;end
simplify(c::Component)=begin;deepcopy(c).x=simplify(getarg(c));c;end
simplify!(c::Component)=begin;c.x=simplify!(getarg(c));c;end
simplify(x::N)=x
simplify!(x::N)=x
function simplify!(a::Array)
	if length(a)==1
		return simplify(a[1])
	else
		for i in 1:length(a)
			a[i]=simplify(a[i])
		end
	end
	return a
end
simplify(a::Array)=simplify!(deepcopy(a))
function sumnum(ex::Expression)
	if ex==0
		return 0
	end
	terms=addparse(ex)
	nterms=Array[]
	numsum=0
	for term in terms
		prod=1
		allnum=true
		nterm=Any[]
		for t in term
			if typeof(t)<:Number
				prod*=t
			else
				if allnum
					allnum=false
				end
				push!(nterm,t)				
			end
		end
		if prod==0
			continue
		elseif allnum
			numsum+=prod
			continue
		else
			if prod!=1
				unshift!(nterm,prod)
			end
			push!(nterms,nterm)
		end
	end
	if numsum!=0
		push!(nterms,[numsum])
	end
	if length(nterms)==1&&length(nterms[1])==1
		return nterms[1][1]
	else
		return expression(nterms)
	end
end
sumnum(x::X)=x #needs to recurse into components such as Cos.x, move SingleArg to common and add check
function sumsym(ex::Expression)
	ap=addparse(ex)
	nap=length(ap)
	cs=Array(Components,0)
	for add in 1:nap
		tcs=Array(Ex,0)
		coef=1
		for term in ap[add]
			if typeof(term)<:Ex
				push!(tcs,term)
			elseif typeof(term)<:Number
				coef*=term
			else			
				warn("Don't know how to handle $term")
			end
		end
		com=Components(tcs,coef)
		ind=indin(cs,com)
		if ind==0
			push!(cs,com)
		else
			cs[ind].coef+=com.coef
		end
	end
	ret=expression(cs)
	if length(ret.components)==1
		return ret.components[1]
	else
		return ret
	end
end
sumsym(x::X)=x
function findsyms(ex::Expression)
	syms=Set{Symbol}()
	for c in ex.components
		if isa(c,Symbol)
			push!(syms,c)
		end
	end
	return syms
end
function findsyms(ex::Expression,symdic::Dict)
	syminds=Dict()
	for k in keys(symdic)
		inds=Integer[]
		for ci in 1:length(ex.components)
			if ex.components[ci]==k
				push!(inds,ci)
			end
		end
		syminds[k]=inds
	end
	return syminds
end
function hasex(symdic::Dict)
	for v in values(symdic)
		if isa(v,Ex)
			return true
		end
	end
	return false
end
function delexs(symdic::Dict)
	sd=deepcopy(symdic)
	for k in keys(symdic)
		if isa(symdic[k],Ex)
			delete!(sd,k)
		end
	end
	return sd
end
import Base.replace
function replace(ex::Ex,symdic::Dict)
	ex=simplify(ex)
	syminds=findsyms(ex,symdic)
	for tup in symdic
		sym,val=tup
		for i in syminds[sym]
			ex.components[i]=val
		end
	end
	return componify(ex)
end
function evaluate(ex::Ex,symdic::Dict)
	ex=simplify(replace(ex,symdic))
	if isa(ex,Expression)&&hasex(symdic)
		symdic=delexs(symdic)
		ex=evaluate(ex,symdic)
	end
	return ex
end
evaluate(x::Number,symdic::Dict)=x#evaluate(Expression([x],symdic))


import Base.start, Base.next, Base.done
start(ex::Expression)=(1,addparse(ex))
function next(ex::Expression,state)
	return (state[2][state[1]],(state[1]+1,state[2]))
end
done(ex::Expression,state)=state[1]>length(state[2])
