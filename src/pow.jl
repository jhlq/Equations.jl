function findpows(term::Array)
	nfacs=length(term)
	pows=Any[]
	for p in unique(permutations(term))
		for powl in 1:floor(nfacs/2)
			maxpow=floor(nfacs/powl)
			pocketpow=1
			for pow in 1:maxpow-1
				#println(pow)
				start1=1+(pow-1)*powl
				stop1=start1+powl-1
				#if (p[start1:stop1],pow)∈pows #this slows down a LOT
				#	continue
				#end
				start2=stop1+1
				stop2=start2+powl-1
				if p[start1:stop1]==p[start2:stop2]
					pocketpow+=1
					#println(p[start1:stop1],pow,pocketpow,p)
					push!(pows,(p[start1:stop1],pocketpow))
				else
					pocketpow=1
				end
			end
		end
		#print(length(unique(pows)),' ')
	end
	return unique(pows)
end
