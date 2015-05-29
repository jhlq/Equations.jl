type Der <: Component
	x
	dy
end
getargs(d::Der)=[d.x,d.dy]
relations["Der"]=simplify(Equation[Der(:a,:x)≖0,Der(Oneable(:a)*:x,:x)≖:a,Der(Oneable(:a)*Pow(:x,:n),:x)≖:n*:a*Pow(:x,:n-1),Der(Oneable(:a)*Sqrt(:x),:x)≖0.5*:a*Pow(:x,-0.5)]) #Der(Pow(:a,:x),:x)≖log(:a)*Pow(:a,:x)
function matches(d::Der,pat::Der)
	valid=validated([d.x,d.dy],[pat.x,pat.dy]) 
	return validfilter(d,pat,valid)
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
