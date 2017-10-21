type Oneable <: Component
	x
end
type Named <: Component
	x
end

relations=Dict{AbstractString,Vector{Equation}}()

function validated(related::Array,pat::Array)
	tmd=Dict[]
	valid=Dict[]
	for t in 1:length(related)
		ttmd=Dict[]
		pushallunique!(ttmd,matches(related[t],pat[t]))
		if isempty(tmd)
			for ttd in ttmd
				push!(valid,ttd)
			end
		else
			for td in tmd
				for ttd in ttmd
					if !clash(td,ttd)
						push!(valid,combine(td,ttd))
					end
				end
			end
		end
		tmd=valid
		valid=Dict[]
	end
	return tmd
end
function validfilter(c1,c2,mda::Array{Dict})
	filtered=Dict[]
	for md in mda
		if randeval(replace(c2,md))==randeval(c1)
			push!(filtered,md)
		end
	end
	return filtered
end
function matches(c1::Component,c2::Component)
	args1,args2=getargs(c1),getargs(c2)
	return validfilter(c1,c2,validated(args1,args2))
end
function facalloc!(termremains::Array,patremains::Array,psremains::Array,dic::Dict,dica::Array{Dict})
	lps,lpat,lterm=length(psremains),length(patremains),length(termremains)
	ldiff=lterm-lpat
	if lps==2
		for shift in 1:ldiff+1
			tdic=deepcopy(dic)
			tdic[patremains[psremains[1]]]=extract(expression(termremains[1:end-shift]))
			tdic[patremains[psremains[2]]]=extract(expression(termremains[end-shift+1:end]))
			push!(dica,tdic)
		end
	elseif lps==1
		tdic=deepcopy(dic)
		tdic[patremains[psremains[1]]]=extract(expression(termremains[1:end]))
		push!(dica,tdic)
	else
		@assert lps>2
		for shift in 0:ldiff
			tdic=deepcopy(dic)
			tdic[patremains[psremains[end]]]=extract(expression(termremains[end-shift:end]))
			npatremains=deleteat!(deepcopy(patremains),psremains[end])
			pushallunique!(dica,facalloc!(termremains[1:end-1-shift],npatremains,psremains[1:end-1],tdic,dica))
		end
		
	end
	return dica
end
getcoef(term::Array)=begin;i=indsin(term,Number);isempty(i)?1:sum(term[i]);end
function whenallequal(term,pat,ps)
	mda=Dict[]
	for l in 1:length(ps)
		if isa(term[l],Component)&&isa(pat[ps[l]],Component)
			pushallunique!(mda,matches(term[l],pat[ps[l]]))
		else
			tmd=Dict()
			tmd[pat[ps[l]]]=term[l]
			push!(mda,tmd)
		end
	end
	if length(mda)>1
		md=combine(mda[1],mda[2])
		for i in 3:length(mda)
			md=combine(md,mda[i])
		end
	else
		md=mda[1]
	end
	return md
end
function matches(term::Array{Factor},pat::Array{Factor})
	md=Dict[]
	ps=indsin(pat,Ex)
	lps,lpat,lterm=length(ps),length(pat),length(term)
	if lterm==lpat==lps
		pushallunique!(md,whenallequal(term,pat,ps))
	elseif lterm>lpat==lps
		facalloc!(term,pat,ps,Dict(),md)
	elseif lterm==lpat>lps
		if getcoef(term)==getcoef(pat)
			pushallunique!(md,whenallequal(term[2:end],pat[2:end],ps-1))
		end
	elseif lterm>lpat>lps
		if getcoef(term)==getcoef(pat)
			facalloc!(term[2:end],pat[2:end],ps-1,Dict(),md)
		end
	end
	return md
end
function clash(dic1::Dict,dic2::Dict)
	for key in keys(dic1)
		if haskey(dic2,key)&&dic1[key]!=dic2[key]
			return true
		elseif !haskey(dic2,key)
			for key2 in keys(dic2)
				if dic2[key2]==dic1[key]
					return true
				end
			end
		end
	end
	return false
end
function combine(dic1::Dict,dic2::Dict)
	ndic=Dict()
	for key in keys(dic1)
		ndic[key]=dic1[key]
	end
	for key in keys(dic2)
		ndic[key]=dic2[key]
	end
	return ndic
end
function matches(ex::Expression,pattern::Expression)
	if has(pattern,Pow)
		ex=simplify(ex,Pow)
	end
	md=Dict[]
	apex=terms(sort(componify(ex)))
	if !isa(apex,Array)
		apex=Term[Factor[apex]]
	end
	apat=terms(sort(componify(pattern)))
	if length(apex)==length(apat)==1
		pushallunique!(md,matches(apex[1],apat[1]))
	else
		tmd=validated(apex,apat)
		pushallunique!(md,tmd)
	end		
	return md		
end
function matches(n::EX,pat::Symbol)
	md=Dict[]
	push!(md,Dict(pat=>n))
	return md
end
matches(::N, ::Expression)=[]
matches(::N, ::Component)=[]
matches(::Number, ::Equation)=[]
function stageoneables(pat)
	ois=expandindices(indsin(pat.lhs,Oneable))
	pat=deepcopy(pat)
	for toi in ois
		pat.lhs[toi]=pat.lhs[toi].x
	end
	pats=Equation[]
	push!(pats,pat)
	if !isempty(ois)
		for oip in permutations(ois)
			np=deepcopy(pat)
			for oi in oip
				np.rhs=replace(np.rhs,Dict(np.lhs[oi]=>1))
				np.lhs[oi]=1
				push!(pats,simplify(np))
			end
		end
	end
	return uniquefilter(pats)
end
function matches(ex::Ex,eq::Equation)
	m=Any[]
	mda=Array{Dict}[]
	if has(eq.lhs,Oneable)
		staged=stageoneables(eq)
		for s in staged
			sm=matches(ex,s.lhs)
			push!(mda,sm)
		end
	else
		staged=[eq]
		push!(mda,matches(ex,eq.lhs))
	end
	for i in 1:length(mda)
		for md in mda[i]
			trh=replace(staged[i].rhs,md)
			push!(m,trh)
		end
	end
	return sort!(m)
end
function quadratic(eq::Equation,xlen::Integer=0,notinx::Array=[])
	eq=simplify(eq)
	if (eq.rhs!=0&&eq.lhs!=0)||(eq.rhs==0&&eq.lhs==0)
		return false
	elseif eq.rhs==0
		termses=terms(eq.lhs)
	else
		termses=terms(eq.rhs)
	end
	connections=Any[]
	matches=Equation[]
	for ti in 1:length(termses)
		matchesfound=Any[]
		for p in permutations(termses[ti])
			for l in 1:length(termses[ti])
				foundmatch=false
				cantbematch=false
				if xlen!=0&&l!=xlen
					cantbematch=true
				end
				if cantbematch
					continue
				end
				for matchi in 1:length(termses)
					if 2l>length(termses[matchi]) || matchi==ti
						continue
					else
						xsq=componify(Expression(Term[p[1:l]])^2)
						if isa(xsq,Expression)
							@assert length(xsq)==1
							xsq=xsq[1]
						end
						for mp in permutations(termses[matchi])
							notx=false
							for notthis in notinx	
								if notthis∈mp[1:2l]

									notx=true
									break
								end
							end
							if notx
								continue
							end
							@assert 2l==length(xsq)
							xsqlen=2l
							matchlen=length(termses[matchi])
							numshift=matchlen-xsqlen
							for shif in 0:numshift
								if xsq==mp[1+shif:2l+shif]
									found=Integer[]
									nomatch=false
									for termi in 1:length(termses)
										if termi∈[ti,matchi]#||termi∈found
											continue
										elseif has(termses[termi],p[1:l])
											nomatch=true
											break
										end
									end
									if !nomatch
										a=Factor[]
										for tl in 1:length(mp)
											if !in(tl,collect(1+shif:2l+shif))
												push!(a,mp[tl])
											end
										end
										b=Factor[]
										for tl in l+1:length(p)
											push!(b,p[tl])
										end
										x=p[1:l]
										c=deleteat!(deepcopy(termses),sort([ti,matchi]))
										eq1=Equation(expression(x),(-expression(b)+Sqrt(expression(b)^2-4*expression(a)*expression(c)))/2expression(a))
										if !in(eq1,matches)
											push!(matches,eq1)
										end
										eq2=Equation(expression(x),(-expression(b)-Sqrt(expression(b)^2-4*expression(a)*expression(c)))/2expression(a))
										if !in(eq2,matches)
											push!(matches,eq2)
										end
										foundmatch=true
										break
									end #if
								end #if
							end #for perm xsq
							if foundmatch;break;end
						end #for mp
					end #if
					if foundmatch;break;end
				end #matchi
			end #length(ti)
		end
	end
	return unique(simplify(matches))
end
