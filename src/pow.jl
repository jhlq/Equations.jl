type Pow <: Component
	x
	y
end
==(p1::Pow,p2::Pow)=p1.x==p2.x&&p1.y==p2.y
import Base: ^
^(x::EX,y::Ex)=Pow(x,y)
^(x::Ex,y::FloatingPoint)=Pow(x,y)
^(x::Ex,y::Complex)=Pow(x,y)
replace!(p::Pow,dic::Dict)=begin;p.x=replace(p.x,dic);p.y=replace(p.y,dic);p;end
replace(p::Pow,dic::Dict)=replace!(deepcopy(p),dic)
function findpows(term::Array)
	pows=Pow[]
	exis=indsin(term,Expression)
	for exi in exis
		tex=componify(replace(term,[term[exi]=>:___internal]))
		@assert length(tex)==1
		tpows=Pow[]
		pushallunique!(tpows,findpows(Expression(tex[1])))
		for tp in tpows
			replace!(tp,[:___internal=>term[exi]])
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
					push!(pows,Pow(p[start1:stop1],pocketpow))
				else
					pocketpow=1
				end
			end
		end
	end
	return unique(pows)
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
