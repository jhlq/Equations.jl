type Der <: Component
	x
	dy
end
#Der(Pow(:a,:x),:x)≖log(:a)*Pow(:a,:x),
getargs(d::Der)=[d.x,d.dy]
derrelations=Equation[Der(:a,:x)≖0,Der(:a*:x,:x)≖:a,Der(Pow(:x,:n),:x)≖:n*Pow(:x,:n-1),Der(Sqrt(:x),:x)≖0.5*Pow(:x,-0.5)]
function matches(d::Der,pat::Der)
	mdx=matches(d.x,pat.x)
	mddy=matches(d.dy,pat.dy)
	validated=Dict[]
	for md in mdx
		for mdy in mddy
			md,mdy=simplify(md),simplify(mdy)
			if !clash(md,mdy)
				push!(validated,combine(md,mdy))
			end
		end
	end
	return validated
end
function matches(ex::Expression,pat::Der)
	termmds=Dict[]
	for term in ex
		push!(termmds,matches(term,pat))
	end		
#	mdx=matches(d.x,pat.x)
#=	mddy=matches(d.dy,pat.dy)

	validated=Dict[]
	for ti in 1:length(termmds)
		for md1 in term 
	end
	for md in mdx
		for mdy in mddy
			md,mdy=simplify(md),simplify(mdy)
			if !clash(md,mdy)
				push!(validated,combine(md,mdy))
			end
		end
	end
	return validated =#
end
#=import Base.ctranspose
function ctranspose(ex::Ex)
	syms=findsyms(ex)
	dy=:t
	if length(syms)==1
		dy=pop!(syms)
	end
	return Der(ex,dy)
end =#
function matches(d::Der)
	ap=addparse(d.x)
	nap=Array[]
	for term in ap
		push!(nap,Any[Der(Expression(term),d.dy)]) #the Any[] is for convenient construction by calling expression
	end
	return expression(nap)
end
function simplify(d::Der)
	return Der(simplify(d.x),simplify(d.dy))
#=	if isa(d.x,Number)
		return 0
	elseif d.x==d.dy
		return 1
	end =#
end
