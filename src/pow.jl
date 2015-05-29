immutable Pow <: Component
	x
	y
end
==(p1::Pow,p2::Pow)=p1.x==p2.x&&p1.y==p2.y
import Base: ^, hash
^(x::EX,y::Ex)=Pow(x,y)
^(x::Ex,y::FloatingPoint)=Pow(x,y)
^(x::Ex,y::Complex)=Pow(x,y)
hash(p::Pow) = hash(p.x) + hash(p.y)
replace(p::Pow,dic::Dict)=Pow(replace(p.x,dic),replace(p.y,dic))
sort(p::Pow)=Pow(sort(p.x),sort(p.y))
function findpows(term::Array)
	pows=Pow[]
	exis=indsin(term,Expression)
	for exi in exis
		tex=componify(replace(term,[term[exi]=>:___internal]))
		@assert length(tex)==1
		tpows=Pow[]
		pushallunique!(tpows,findpows(Expression(tex[1])))
		for tp in tpows
			tp=replace(tp,[:___internal=>term[exi]])
		end
		pushallunique!(pows,tpows)
	end
	nfacs=length(term)
	for p in unique(permutations(term))
		for powl in 1:floor(nfacs/2)
			maxpow=floor(nfacs/powl)
			pocketpow=1
			for pow in 1:maxpow-1
				start1=1+(pow-1)*powl
				stop1=start1+powl-1
				#if (p[start1:stop1],pow)∈pows #this slows down a LOT
				#	continue
				#end
				start2=stop1+1
				stop2=start2+powl-1
				if p[start1:stop1]==p[start2:stop2]
					pocketpow+=1
					push!(pows,sort(Pow(extract(expression(p[start1:stop1])),pocketpow)))
				else
					pocketpow=1
				end
			end
		end
	end
	return uniquefilter(pows)
end
function findpows(ex::Expression)
	pows=Pow[]
	powsa=Array[]
	for term in ex
		pushallunique!(pows,findpows(term))
	end
	return pows
end
function matches(term::Term,t::Type{Pow})
	term=sort(term)
	pows=findpows(term)
	potpows=Term[]
	for potpow in pows
		nterm=deepcopy(term)
		if isa(potpow.x,X)
			powloc=indin(term,potpow.x)
			deleteat!(nterm,[powloc:powloc+potpow.y-1])
			insert!(nterm,powloc,potpow)		
		elseif isa(potpow.x,Expression)
			powloc=indin(term,potpow.x)
			if powloc==0 && length(potpow.x)==1
				factors=uniquefilter(potpow.x.terms[1])
				for fac in factors
					deleteat!(nterm,[indin(nterm,fac):indin(nterm,fac)+potpow.y-1])
				end
				insert!(nterm,length(nterm)+1,potpow)
			else
				error("Could not locate $potpow in $term")
			end
		end
		push!(potpows,nterm)
	end
	return sort(potpows)
end
function matches(ex::Expression,t::Type{Pow})
	#major todo: contract several terms
	terms=Array{Term}[]
	for term in ex
		push!(terms,matches(term,t))
	end
	#m=Any[] #combine these here or let user decide?
	return terms
end
function matches(term::Term,p::Pow)
	m=matches(term,Pow)
	if !isempty(m)
		m=m[1]
	end
	if length(m)==1
		dics=matches(m[1],p)
		return dics
	end
	return Dict[]
end
function matches(p::Pow,pat::Pow)
	validated([p.x,p.y],[pat.x,pat.y])
end
matches(::N, ::Pow)=[]
matches(::Pow, ::Expression)=[]
	
function simplify(p::Pow)
	p,e=(simplify(p.x),simplify(p.y))
	return p^e
end
function simplify(term::Array,t::Type{Pow})
	potpows=matches(term,t)
	if !isempty(potpows)
		return potpows[1]
	else
		return term
	end
end

function simplify(ex::Expression,t::Type{Pow})
	ex=componify(ex)
	ap=terms(ex)
	for term in 1:length(ap)
		ap[term]=simplify(ap[term],t)
	end
	return extract(expression(ap))	
end
function matches(ex::Expression,pattern::Pow)
	ex=simplify(ex,Pow)
	if isa(ex,Pow)
		return matches(ex,pattern)
	end
	md=Dict[]
	apex=terms(sort(componify(ex)))
	if !isa(apex,Array)
		apex=Term[Factor[apex]]
	end
	if length(apex)==1
		pushallunique!(md,matches(apex[1],Factor[pattern]))
	else
		tmd=validated(apex,Term[Factor[pattern]])
		pushallunique!(md,tmd)
	end		
	return md		
end
