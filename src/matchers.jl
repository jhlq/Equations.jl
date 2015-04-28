function validfilter(c1,c2,mda::Array{Dict})
	filtered=Dict[]
	for md in mda
		if replace(c2,md)==c1
			push!(filtered,md)
		end
	end
	return filtered
end
function matches(c1::Component,c2::Component) #implement new for custom types
	mda=Dict[]
	if isa(getarg(c2),Symbol)
		tmd=Dict()
		tmd[getarg(c2)]=getarg(c1)
		push!(mda,tmd)
	elseif isa(getarg(c2),Expression)
		pushallunique!(mda,matches(getarg(c1),getarg(c2)))
	end
	return validfilter(c1,c2,mda)
end
function facalloc!(termremains::Array,patremains::Array,psremains::Array,dic::Dict,dica::Array{Dict})
	lps,lpat,lterm=length(psremains),length(patremains),length(termremains)
	ldiff=lterm-lpat
	if lps==2
		for shift in 1:ldiff+1
			tdic=deepcopy(dic)
			tdic[patremains[psremains[1]]]=termremains[1:end-shift]
			tdic[patremains[psremains[2]]]=termremains[end-shift+1:end]
			push!(dica,tdic)
		end
	elseif lps==1
		tdic=deepcopy(dic)
		tdic[patremains[psremains[1]]]=termremains[1:end]
		push!(dica,tdic)
	else
		@assert lps>2
		for shift in 0:ldiff
			tdic=deepcopy(dic)
			tdic[patremains[psremains[end]]]=termremains[end-shift:end]
			npatremains=deleteat!(deepcopy(patremains),psremains[end])
			pushallunique!(dica,facalloc!(termremains[1:end-1-shift],npatremains,psremains[1:end-1],tdic,dica))
		end
		
	end
	return dica
end
getcoef(term::Array)=begin;i=indsin(term,Number);isempty(i)?1:sum(term[i]);end
function whenallequal(term,pat,ps)
	mda=Dict[]
	#print(term,pat,ps)
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
	md=Dict[]
	apex=terms(sort(componify(ex)))
	apat=terms(sort(componify(pattern)))
	if length(apex)==length(apat)==1
		pushallunique!(md,matches(apex[1],apat[1]))
	else
		tmd=Dict[]
		validated=Dict[]
		for t in 1:length(apex)
			ttmd=Dict[]
			pushallunique!(ttmd,matches(apex[t],apat[t]))
			if isempty(tmd)
				for ttd in ttmd
					push!(validated,ttd)
				end
			else
				for td in tmd
					for ttd in ttmd
						if !clash(td,ttd)
							push!(validated,combine(td,ttd))
						end
					end
				end
			end
			tmd=validated
			validated=Dict[]
		end
		pushallunique!(md,tmd)
	end		
	return md		
end
function matches(ex::Ex,eq::Equation)
	m=Equation[]
	mda=matches(ex,eq.lhs)
	for md in mda
		tlh=deepcopy(ex)
		trh=replace(eq.rhs,md)
		push!(m,Equation(tlh,trh))
	end
	return m
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
		#print(ti)
		matchesfound=Any[]
		for p in permutations(termses[ti])
			for l in 1:length(termses[ti])
				#print(" l:",l)
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
						#println(xsq)
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
							xsqlen=2l#length(xsq)
							matchlen=length(termses[matchi])
							numshift=matchlen-xsqlen
							for shif in 0:numshift
								if xsq==mp[1+shif:2l+shif]
	#								push!(connections,(ti,p,l,matchi,termses[matchi]))
									found=Integer[]
									nomatch=false
									for termi in 1:length(termses)
										#print("termi:",termi)
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
											if !in(tl,[1+shif:2l+shif])
												#println(mp,mp[tl])
												push!(a,mp[tl])
											end
										end
										b=Factor[]
										for tl in l+1:length(p)
											push!(b,p[tl])
										end
										x=p[1:l]
										c=deleteat!(deepcopy(termses),sort([ti,matchi]))
										#println("$termses is of the form ax^2+bx+c with a=$a, x^2=$xsq, b=$b, x=$x, c=$c")
										eq1=Equation(expression(x),(-expression(b)+Sqrt(expression(b)^2-4*expression(a)*expression(c)))/2expression(a))
#Equation(expression(x),(-expression(b)/(2expression(a))+Sqrt(expression(b)^2/(4*expression(a)^2)-expression(c)/expression(a))))
										if !in(eq1,matches)
											push!(matches,eq1)
										end
										eq2=Equation(expression(x),(-expression(b)-Sqrt(expression(b)^2-4*expression(a)*expression(c)))/2expression(a))
										if !in(eq2,matches)
											push!(matches,eq2)
										end
										#push!(found,termi)
										foundmatch=true
										#print("!")
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
#	println(unique(connections))
	return unique(simplify(matches))
end
