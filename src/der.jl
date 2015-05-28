type Der <: Component
	x
	dy
end
#Der(Pow(:a,:x),:x)≖log(:a)*Pow(:a,:x),
getargs(d::Der)=[d.x,d.dy]
relations["Der"]=simplify(Equation[Der(:a,:x)≖0,Der(Oneable(:a)*:x,:x)≖:a,Der(Pow(:x,:n),:x)≖:n*Pow(:x,:n-1),Der(Sqrt(:x),:x)≖0.5*Pow(:x,-0.5)])
function matches(d::Der,pat::Der)
	mdx=matches(d.x,pat.x)
	mddy=matches(d.dy,pat.dy)
	validated=Dict[]
	for md in mdx
		for mdy in mddy
			md,mdy=simplify(md),simplify(mdy)
			con=false
			for key in keys(md)
				if key!=d.dy&&has(md[key],d.dy)
					con=true
				end
			end
			if con;continue;end
			if !clash(md,mdy)
				push!(validated,combine(md,mdy))
			end
		end
	end
	return validated
end
matches(::N,::Der)=[]
matches(::Term,::Der)=[]
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
end
