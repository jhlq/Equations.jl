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
					push!(pows,sort(Pow(extract(Expression(p[start1:stop1])),pocketpow)))
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
	#ap=addparse(ex)
	for term in ex
		pushallunique!(pows,findpows(term))
	end
	return pows
end
#simplify!(p::Pow)=begin;p.x=simplify(p.x);p.y=simplify(p.y);p;end
simplify(p::Pow)=Pow(simplify(p.x),simplify(p.y))
function simplify(term::Array,t::Type{Pow})
	sort!(term)
	pows=findpows(term)
	potpows=Term[]
	for potpow in pows
		nterm=deepcopy(term)
		#xlen=1
		if isa(potpow.x,X)
			powloc=indin(term,potpow.x)
			deleteat!(nterm,[powloc:powloc+potpow.y-1])
			insert!(nterm,powloc,potpow)		
		elseif isa(potpow.x,Expression)
			powloc=indin(term,potpow.x)
			if powloc==0 && length(addparse(potpow.x))==1
				#powloc=indin(term,potpow.x.components[1])
				factors=uniquefilter(potpow.x.components)
				for fac in factors
					deleteat!(nterm,[indin(nterm,fac):indin(nterm,fac)+potpow.y-1])
				end
				insert!(nterm,length(nterm)+1,potpow)
				#xlen=length(potpow.x.components)
			else
				error("Could not locate $potpow in $term")
			end
		end
		push!(potpows,nterm)
	end
	return sort(potpows)[1]
end
#simplify(term::Array,t::Type{Pow})=simplify!(deepcopy(term),t)
function simplify(ex::Expression,t::Type{Pow})
	ex=componify(ex)
	ap=addparse(ex)
	for term in 1:length(ap)
		ap[term]=simplify(ap[term],t)
	end
	return extract(expression(ap))	
end
