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
	else
		@assert lps>2
		for shift in 0:ldiff
			tdic=deepcopy(dic)
			tdic[patremains[psremains[end]]]=termremains[end-shift:end]
			npatremains=deleteat!(deepcopy(patremains),psremains[end])
			pushallunique!(dica,facalloc(termremains[1:end-1-shift],npatremains,psremains[1:end-1],tdic,dica))
		end
		
	end
	return dica
end
getcoef(term::Array)=sum(term[indsin(term,Number)])
function whenallequal(term,pat,ps)
	tmd=Dict()
	for l in 1:length(ps)
		tmd[pat[ps[l]]]=term[l]
	end
	return tmd
end
function matches(term::Array,pat::Array)
	md=Dict[]
	ps=indsin(pat,Symbol)
	lps,lpat,lterm=length(ps),length(pat),length(term)
	if lterm==lpat==lps
#		tmd=Dict()
#		for l in 1:lps
#			tmd[pat[ps[l]]]=term[l]
#		end
		push!(md,whenallequal(term,pat,ps))
	elseif lterm>lpat==lps
		facalloc!(term,pat,ps,Dict(),md)
	elseif lterm==lpat>lps
		if getcoef(term)==getcoef(pat)
			push!(md,whenallequal(term[2:end],pat[2:end],ps-1))
		end
	end
	return md
end
function matches(ex::Expression,pattern::Expression)
	md=Dict[]
	apex=addparse(simplify(ex))
	apat=addparse(simplify(pattern))
	if length(apex)==length(apat)==1
		pushallunique!(md,matches(apex[1],apat[1]))
	else
		for t in 1:length(apex)
			if length(apex[t])!=length(apat[t])
				break
			end
		end
	end		
	return md		
end

function quadratic(eq::Equation,xlen::Integer=0,notinx::Array=[])
	eq=simplify(eq)
	if (eq.rhs!=0&&eq.lhs!=0)||(eq.rhs==0&&eq.lhs==0)
		return false
	elseif eq.rhs==0
		terms=addparse(eq.lhs)
	else
		terms=addparse(eq.rhs)
	end
	connections=Any[]
	matches=Equation[]
	for ti in 1:length(terms)
		#print(ti)
		matchesfound=Any[]
		for p in permutations(terms[ti])
			for l in 1:length(terms[ti])
				#print(" l:",l)
				foundmatch=false
				cantbematch=false
				if xlen!=0&&l!=xlen
					cantbematch=true
				end
				if cantbematch
					continue
				end
				for matchi in 1:length(terms)
					if 2l>length(terms[matchi]) || matchi==ti
						continue
					else
						xsq=componify(Expression(p[1:l])^2)
						#println(xsq)
						if isa(xsq,Expression)
							xsq=xsq.components
						end
						for mp in permutations(terms[matchi])
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
							matchlen=length(terms[matchi])
							numshift=matchlen-xsqlen
							for shif in 0:numshift
								if xsq==mp[1+shif:2l+shif]
	#								push!(connections,(ti,p,l,matchi,terms[matchi]))
									found=Integer[]
									nomatch=false
									for termi in 1:length(terms)
										#print("termi:",termi)
										if termi∈[ti,matchi]#||termi∈found
											continue
										elseif has(terms[termi],p[1:l])
											nomatch=true
											break
										end
									end
									if !nomatch
										a=Any[]
										for tl in 1:length(mp)
											if !in(tl,[1+shif:2l+shif])
												push!(a,mp[tl])
											end
										end
										b=Any[]
										for tl in l+1:length(p)
											push!(b,p[tl])
										end
										x=p[1:l]
										c=deleteat!(deepcopy(terms),sort([ti,matchi]))
										#println("$terms is of the form ax^2+bx+c with a=$a, x^2=$xsq, b=$b, x=$x, c=$c")
										eq1=Equation(Expression(x),(-Expression(b)/(2Expression(a))+Sqrt(Expression(b)^2/(4*Expression(a)^2)-Expression(c)/Expression(a))))
										if !in(eq1,matches)
											push!(matches,eq1)
										end
										eq2=Equation(Expression(x),(-Expression(b)-Sqrt(Expression(b)^2-4*Expression(a)*Expression(c)))/2Expression(a))
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
