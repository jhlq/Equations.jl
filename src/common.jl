import Base: convert, show, push!, length, getindex, sort!, sort

abstract Component
function ==(c1::Component, c2::Component)
	if isa(c1,typeof(c2))
		for n in names(c1)
			if getfield(c1,n)!=getfield(c2,n)
				return false
			end
		end
		return true
	end
	return false
end
abstract SingleArg <: Component
==(sa1::SingleArg,sa2::SingleArg)=isa(sa1,typeof(sa2))&&sa1.x==sa2.x 
function getarg(c::Component,n::Integer=1)
	getfield(c,names(c)[n])
end
function setarg!(c::Component,newarg,argn::Integer=1)
	setfield!(c,names(c)[argn],newarg)
	return c
end
setarg(c::Component,newarg,argn::Integer=1)=setarg!(deepcopy(c),newarg,argn)
type Components <: Component 
	components 
	coef
end #maybe this type should be deprecated and sumsym rewritten
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

type Expression 
	terms::Array{Array{Union(Number,Symbol,Component,Expression),1},1}
end
length(ex::Expression)=length(ex.terms)
getindex(ex::Expression,i::Integer)=getindex(ex.terms,i)
function _show(io,c)
	if isa(c,Number)&&(isa(c,Complex)||c<0)
		print(io,'(')
		show(io,c)
		print(io,')')
	else
		show(io,c)
	end
end
function show(io::IO,ex::Expression)
	print(io, "𝐸(")
	if isempty(ex.terms)
		show(io,ex.terms)
	else
		for term in 1:length(ex.terms)-1
			for fac in 1:length(ex.terms[term])-1
				_show(io,ex.terms[term][fac])			
	#			print(io,' ')
			end
			_show(io,ex.terms[term][end])
			print(io,'+')
		end
		for fac in 1:length(ex.terms[end])-1
			_show(io,ex.terms[end][fac])
	#		print(io,' ')
		end
		_show(io,ex.terms[end][end])
	end
	print(io, ')')
end
#show(io::IO,s::Symbol)=print(io,s)
N=Union(Number,Symbol)
X=Union(Number,Symbol,Component)
Ex=Union(Symbol,Component,Expression)
EX=Union(Number,Symbol,Component,Expression)
typealias Factor EX
show(io::IO,x::Type{Factor})=print(io, "Factor")
typealias Term Array{Factor,1}
#convert(::Type{Term},ex::EX)=Factor[ex]
convert(::Type{Array{Array{Factor,1},1}},a::Array{Any,1})=Term[a]
complexity(n::N)=1
function complexity(c::Component)
	tot=0
	for n in names(c)
		tot+=complexity(getfield(c,n))
	end
	return tot
end
function complexity(term::Term)
	tot=0
	for factor in term
		tot+=complexity(factor)
	end
	return tot
end
function complexity(ex::Expression)
	tot=0
	for term in ex
		tot+=complexity(term)
	end
	return tot
end
expression(a::Term)=Expression(Term[a])
expression(a::Array{Term})=Expression(a)
function expression(cs::Array{Components})
	if isempty(cs)
		return 0#Expression([0])
	end
	ex=Expression(Term[])
	for cc in cs
		if cc.coef!=0
			nterm=Factor[]
			if cc.coef!=1||isempty(cc.components) 
				push!(nterm,cc.coef)
			end
			for c in cc.components
				push!(nterm,c)
			end
			push!(ex.terms,nterm)
		end
	end
	if length(ex)==0
		return 0#Expression([0])
	else
		return ex
	end
end
expression(x::X)=expression(Factor[x])
==(ex1::Expression,ex2::Expression)=ex1.terms==ex2.terms
# ==(ex::Expression,n::Number)=simplify(ex)==n
push!(ex::Expression,a)=push!(ex.terms,a)
push!(x::X,a)=expression(Factor[x,a])
+(ex1::Expression,ex2::Expression)=begin;ex=deepcopy(ex1);push!(ex.terms,[ex2]);ex;end
+(ex::Expression,a::X)=begin;ex=deepcopy(ex);push!(ex.terms,[a]);ex;end
-(ex::Expression,a::X)=begin;ex=deepcopy(ex);push!(ex.terms,[-1,a]);ex;end
-(a::X,ex::Expression)=a+(-1*ex)
-(ex1::Expression,ex2::Expression)=begin;ex=deepcopy(ex1);push!(ex,Factor[-1,ex2]);ex;end
+(a::X,ex::Expression)=begin;ex=deepcopy(ex);insert!(ex.terms,1,Factor[a]);ex;end
*(ex1::Expression,ex2::Expression)=expression(Factor[deepcopy(ex1),deepcopy(ex2)])
/(ex::Ex,n::Number)=*(1/n,ex)
function *(a::X,ex::Expression)
	ex=deepcopy(ex)
	for ti in 1:length(ex)
		insert!(ex[ti],1,a)
	end
	return ex
end

*(a::Number,c::Component)=Expression([a,c])
*(c1::Union(Component,Symbol),c2::Union(Component,Symbol))=Expression(Term[Factor[c1,c2]])
function *(ex::Expression,x::EX)
	ap=terms(deepcopy(ex))
	for t in ap
		push!(t,x)
	end
	return expression(ap)
end
-(c1::Component,c2::Component)=+(c1,-1*c2)
+(c1::Component,c2::Component)=Expression(Term[Factor[c1],Factor[c2]])
+(c::Component,ex::Expression)=Expression(Term[Factor[c],Factor[ex]])
+(ex::Expression,c::Component)=Expression(Term[Factor[ex],Factor[c]])

+(x1::X,x2::X)=Expression(Term[[x1],[x2]])
-(x1::X,x2::X)=Expression(Term[[x1],[-1,x2]])
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
function indin(array,typ::Type)
	for it in 1:length(array)
		if isa(array[it],typ)
			return it
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
terms(ex::Expression)=ex.terms
terms(x::X)=x#Term[Factor[x]]
dcterms(ex::Expression)=terms(deepcopy(ex))
dcterms(x::X)=x
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
function has(ex::Expression,x::Symbol)
	for term in ex
		for c in term
			if c==x || (isa(c,Expression)&&has(c,x)) || (isa(c,Component)&&has(c,x))
				return true
			end
		end
	end
	return false
end
has(c::Component,x::Symbol)=has(getarg(c),x)
has(n::N,x::Symbol)=n==x
function maketype(c::Component,fun) #rewrite with vararg
	l=length(names(c))
	if l==1
		tc=typeof(c)(fun(getarg(c)))
	elseif l==2
		tc=typeof(c)(fun(getarg(c)),componify(getarg(c,2)))
	elseif l==3
		tc=typeof(c)(fun(getarg(c)),componify(getarg(c,2)),componify(getarg(c,3)))
	else
		error("File an issue requesting the development of more general component creation or create a custom maketype(t::TheType,function).")
	end
	return tc
end
function unnest(ex::Expression)
	nt=Term[]
	for term in ex.terms
		nf=Factor[]
		for fac in term
			if isa(term,Array)
				for nested in term
					push!(nf,nested)
				end
			else
				push!(nf,fac)
			end
		end
		push!(nt,nf)
	end
	return Expression(nt)
end
function componify(ex::Expression,raw=false)
	ap=dcterms(ex)
	lap=length(ap)
	for term in 1:lap
		exs=Expression[]
		xs=X[]
		for fac in ap[term]
			if isa(fac,Array)
				warn("How did the array $fac end up in $ex?") #through replace!
				push!(exs,componify(Expression(fac)))
			elseif isa(fac,Expression)
				push!(exs,componify(fac))
			elseif isa(fac,Component)
				fac=maketype(fac,componify)
				push!(xs,fac)
			else
				push!(xs,fac)
			end
		end
		if isempty(exs)
			continue
		else
			tap=exs[1].terms
			for x in xs
				for tterm in tap
					unshift!(tterm,x)
				end
			end
			exs[1]=expression(tap)
			while length(exs)>1
				ap1=terms(exs[1])
				ap2=terms(exs[2])
				lap1,lap2=length(ap1),length(ap2)
				multed=Term[]
				for l in 1:lap1*lap2
					push!(multed,Factor[])
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
#			print(exs[1])
#			@assert length(exs[1])==1
			ap[term]=terms(exs[1])[1]
			for tterm in 2:length(exs[1])
				push!(ap,exs[1][tterm])
			end
		end
	end
	if raw 
		return ap #this was needed for previous componify, maybe remove?
	else
		return expression(ap)
	end
end
componify(a::Array)=length(a)==1?componify(extract(a)):componify(expression(a),true)
componify(a::Array{Array})=componify(expression(a))
componify(c::Component)=maketype(c,componify)
componify(x::N)=x
function extract(ex::Expression)
	if length(ex.terms)==1&&length(ex.terms[1])==1
		return ex[1][1]
	end
	return ex
end
function extract(a::Array)
	if length(a)==1
		return a[1]
	end
	return a
end
import Base.isless
isless(ex::Expression,x::X)=false
isless(x::X,ex::Expression)=true
isless(c::Component,s::N)=false
isless(s::N,c::Component)=true
isless(s::Symbol,n::Number)=false
isless(n::Number,s::Symbol)=true
function isless(c1::Component,c2::Component)
	xi1=complexity(c1)
	xi2=complexity(c2)
	xi1==xi2?isless(string(c1),string(c2)):xi1<xi2
end
function isless(t1::Term,t2::Term)
	xi1=complexity(t1)
	xi2=complexity(t2)
	xi1==xi2?isless(string(t1),string(t2)):xi1<xi2
end
function isless(ex1::Expression,ex2::Expression)
	xi1=complexity(ex1)
	xi2=complexity(ex2)
	xi1==xi2?isless(string(ex1),string(ex2)):xi1<xi2
end
sort(n::N)=n
sort(c::Component)=maketype(c,sort)
function sort!(ex::Expression)
	ap=terms(ex)
	for term in ap
		sort!(term)
	end
	return expression(sort!(ap))
end
sort(ex::Expression)=sort!(deepcopy(ex))
function simplify(ex::Expression)
	#ex=deepcopy(ex)
	tex=0
	nit=0
	while tex!=ex
		tex=ex
#		print(terms(ex),"   =>   ")
		ex=sumsym(sumnum(componify(ex)))
#		print(terms(ex),"!!!\t")
		ap=terms(ex)
		if isa(ap,X)
			return ap
		end
		for term in 1:length(ap)
			ap[term]=divify!(ap[term])
			for fac in 1:length(ap[term])
				ap[term][fac]=simplify(ap[term][fac])
			end
			sort!(ap[term])
		end
		ex=extract(expression(ap)) #better to check if res::N before calling expression instead of extracting?
		nit+=1
		if nit>90
			warn("Stuck in simplify! Iteration #$nit: $ex")
		end
	end
	return ex 
end
#simplify!(ex::Expression)=begin;warn("simplify! is incomplete.");ex=simplify(ex);end #this doesn't really save memory...
simplify(c::Component)=begin;deepcopy(c).x=simplify(getarg(c));c;end
#simplify!(c::Component)=begin;c.x=simplify!(getarg(c));c;end
simplify(x::N)=x
simplify(x::N,a)=x
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
	#if ex==0
	#	print(0)
	#	return 0
	#end
	terms=dcterms(ex)
	nterms=Term[]
	numsum=0
	for term in terms
		prod=1
		allnum=true
		nterm=Factor[]
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
	elseif isempty(nterms)
		return 0
	else
		return expression(nterms)
	end
end
sumnum(c::Component)=typeof(c)(sumnum(getarg(c)))
sumnum(x::N)=x 
function sumsym(ex::Expression)
	ap=terms(deepcopy(ex))
	nap=length(ap)
	cs=Array(Components,0)
	for add in 1:nap
		tcs=Array(Ex,0)
		coef=1
		for term in ap[add]
			term=sumsym(term)
			if isa(term,Ex)
				push!(tcs,term)
			elseif isa(term,Number)
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
	if isa(ret,Expression)&&length(ret.terms)==1&&length(ret.terms[1])==1
		return ret[1][1]
	else
		return ret
	end
end
sumsym(c::Component)=maketype(c,sumsym)
sumsym(x::N)=x
sumsym(term::Array)=sumsym(Expression(term)) #reverse this...
function findsyms(term::Array)
	syms=Dict()
	for fac in 1:length(term)
		if isa(term[fac],Symbol)
			if haskey(syms,term[fac])
				push!(syms[term[fac]],fac)
			else
				syms[term[fac]]=Any[fac]
			end
		end
	end
	return syms
end
function findsyms(ex::Expression)
	syms=Set{Symbol}()
	for term in ex
		for fac in term
			if isa(c,Symbol)#&&c!=:+
				push!(syms,c)
			elseif isa(c,Expression)||isa(c,Component)
				syms=union(syms,findsyms(c))
			end
		end
	end
	return syms
end
findsyms(c::Component)=findsyms(getarg(c))
findsyms(s::Symbol)=Set([s])
findsyms(n::Number)=Set()
function findsyms(ex::Expression,symdic::Dict)
	syminds=Dict()
	for k in keys(symdic)
		inds=Tuple[]
		for ti in 1:length(ex)
			for ci in 1:length(ex[ti])
				if ex[ti][ci]==k
					push!(inds,(ti,ci))
				end
			end
		end
		syminds[k]=inds
	end
	return syminds
end
findsyms(C::Component,symdic::Dict)=findsyms(getarg(c),symdic)
function findcoms(term::Array)
	coms=Dict()
	for fac in 1:length(term)
		if isa(term[fac],Component)
			if haskey(coms,term[fac])
				push!(coms[term[fac]],fac)
			else
				coms[term[fac]]=Any[fac]
			end
		end
	end
	return coms
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
function replace!(ex::Expression,symdic::Dict)
	for ti in 1:length(ex)
		for c in 1:length(ex[ti])
			if isa(ex[ti][c],Ex)
				rep=replace(ex[ti][c],symdic)
				deleteat!(ex[ti],c)
				if isa(rep,Array)
					for r in rep
						insert!(ex[ti],c,r)
					end
				else
					insert!(ex[ti],c,rep)
				end
			end
		end
	end
	syminds=findsyms(ex,symdic)
	for tup in symdic
		sym,val=tup
		for i in syminds[sym]
			if isa(val,Array)
				deleteat!(ex[i[1]],i[2])
				for r in val
					insert!(ex[i[1]],i[2],r)
				end
			else
				ex[i[1]][i[2]]=val
			end
		end
	end 
	return ex
end
replace(ex::Expression,symdic::Dict)=replace!(deepcopy(ex),symdic)
#replace!(term::Array,symdic::Dict)=replace!(Expression(term),symdic).components
replace(term::Array,symdic::Dict)=replace(Expression(term),symdic).components
replace(c::Component,symdic::Dict)=maketype(c,x->replace(x,symdic))
function replace(s::Symbol,symdic::Dict)
	for tup in symdic
		sym,val=tup
		if s==sym
			return val
		end
	end
	return s
end
replace(n::Number,symdic::Dict)=n
function evaluate(ex::Ex,symdic::Dict)
	ex=simplify(replace(simplify(ex),symdic))
	if isa(ex,Expression)&&hasex(symdic)
		symdic=delexs(symdic)
		ex=evaluate(ex,symdic)
	end
	return simplify(ex)
end
evaluate(x::Number,symdic::Dict)=x

import Base.start, Base.next, Base.done
start(ex::Expression)=(1,terms(ex))
function next(ex::Expression,state)
	return (state[2][state[1]],(state[1]+1,state[2]))
end
done(ex::Expression,state)=state[1]>length(state[2])
