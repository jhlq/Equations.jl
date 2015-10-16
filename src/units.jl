type Physical <: Component
	x
	units
end
*(p1::Physical,p2::Physical)=simplify(Physical(p1.x*p2.x,p1.units*p2.units))
+(p1::Physical,p2::Physical)=simplify(Physical(p1.x+p2.x,p1.units+p2.units))
-(p1::Physical,p2::Physical)=simplify(Physical(p1.x-p2.x,p1.units-p2.units))
/(p1::Physical,p2::Physical)=simplify(Physical(p1.x/p2.x,p1.units/p2.units))
function simplify(p::Physical)
	u=simplify(p.units)
	if length(u)==1 && length(u[1])>1 && isa(u[1][1],Number)
		shift!(u[1])
	end
	return Physical(simplify(p.x),u)
end
