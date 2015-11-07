type U <: Component
	x
	units
end
Physical=U
*(p1::Physical,p2::Physical)=simplify(Physical(p1.x*p2.x,p1.units*p2.units))
+(p1::Physical,p2::Physical)=simplify(Physical(p1.x+p2.x,p1.units+p2.units))
-(p1::Physical,p2::Physical)=simplify(Physical(p1.x-p2.x,p1.units-p2.units))
/(p1::Physical,p2::Physical)=simplify(Physical(p1.x/p2.x,p1.units/p2.units))
*(p::Physical,n::Number)=simplify(Physical(p.x*n,p.units))
function simplify(p::Physical)
	u=simplify(p.units)
	if isa(u,Array) && length(u)==1 && length(u[1])>1 && isa(u[1][1],Number)
		shift!(u[1])
	end
	return Physical(simplify(p.x),u)
end
