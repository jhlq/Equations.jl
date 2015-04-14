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
				for matchi in 1:length(terms)#[[1:ti-1], [ti+1:length(terms)]]
					#print(" matchi:",matchi)
					if 2l>length(terms[matchi]) || matchi==ti
						continue
					else
						xsq=simplify(Expression(p[1:l])^2).components
						
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
							xsqlen=2l#length(xsq)
							matchlen=length(terms[matchi])
							numshift=matchlen-xsqlen
							for shif in 0:numshift#xsqperm in permutations(xsq)
								
									
								#xsq=simplify(Expression(p[1:l])^2).components
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
										for tl in 2l+1:length(mp)
											push!(a,mp[tl])
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
