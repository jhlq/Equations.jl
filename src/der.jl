mutable struct Der <: Component
	x
	dy
end
function print(io::IO,d::Der)
	if isa(d.dy,X) && isa(d.x,X)
		print(io,"∂$(d.x)/∂$(d.dy)")
	else
		print(io,"∂($(d.x))/∂($(d.dy))")
	end
end
getargs(d::Der)=[d.x,d.dy]
mutable struct DerOp <: NonAbelian
	dy
end
#*(dop::DerOp,ex::EX)=Der(ex,dop.dy)
function print(io::IO,dop::DerOp)
	if isa(dop.dy,X)
		print(io,"∂/∂$(dop.dy)")
	else
		print(io,"∂/∂($(dop.dy))")
	end
end
relations["Der"]=simplify(Equation[Der(:a,:x)≖0,Der(Oneable(:a)*:x,:x)≖:a,Der(Oneable(:a)*Pow(:x,:n),:x)≖:n*:a*Pow(:x,:n-1),Der(Oneable(:a)*Sqrt(:x),:x)≖0.5*:a*Pow(:x,-0.5)]) #Der(Pow(:a,:x),:x)≖log(:a)*Pow(:a,:x)
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
	return validfilter(d,pat,validated)
end
matches(::N,::Der)=[]
matches(::Term,::Der)=[]
function matches(d::Der)
	ap=addparse(d.x)
	nap=Term[]
	for term in ap
		push!(nap,Factor[Der(Expression(term),d.dy)]) 
	end
	return Expression(nap)
end
function simplify(d::Der)
	return Der(simplify(d.x),simplify(d.dy))
end
