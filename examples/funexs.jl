f=Fun(x->x,:x)
f2=f*f
y=f2&@equ x=3
@assert y==3^2
fp=PD(:x)*f
yp=fp&@equ x=3
@assert isapprox(yp,1,atol=1e-5)
fxy=Fun(a->a[1]+a[2]^2,[:x,:y])
fxyp=PD(:y)*fxy
fxypp=PD(:x)*PD(:y)*fxy
#fxypps=simplify(fxypp) fix this
#fxypp=PD(:x)*(PD(:y)*fxy)
xy=@equs(x=1,y=1)
@assert isapprox(fxyp&xy,2,atol=1e-5)
@assert fxypp&xy==0
T=Ten([PD(:x),PD(:y)],:i)*Ten([fxy,fxy],:i)
ts&xy

function cchr(gf::Fun) #construct Christoffel symbol
	igf=Fun(a->inv(gf.y(a)),gf.x)
	pda=[PD(gf.x[1]),PD(gf.x[2])]
	chrybu=0.5*Ten(igf,[:cha,:chy])*(Ten(pda,:chu)*Ten(gf,[:cha,:chb])+Ten(pda,:chb)*Ten(gf,[:cha,:chu])-Ten(pda,:cha)*Ten(gf,[:chb,:chu]))
	return chrybu
end

gf=Fun(a->[1 0;0 a[1]^2],[:r,:th])
chrybu=cchr(gf)
r=10
chr212=chrybu&@equs(chy=2,chb=1,chu=2,r=$r,th=3)
@assert isapprox(chr212,1/r,atol=1e-5)

#http://einsteinrelativelyeasy.com/index.php/general-relativity/34-christoffel-symbol-exercise-calculation-in-polar-coordinates-part-ii
R=3
gf=Fun(a->[R^2 0;0 R^2*sin(a[1])^2],[:th,:ph])
chrybu=cchr(gf)
chrm=zeros(2,2,2)
th=1
ph=2
for i in 1:2
	for j in 1:2
		for k in 1:2
			chrm[i,j,k]=chrybu&@equs(chy=$i,chb=$j,chu=$k,th=$th,ph=$th)
		end
	end
end
@assert isapprox(chrm[1,2,2],-sin(th)*cos(th),atol=1e-5)
@assert isapprox(chrm[2,1,2],cos(th)/sin(th),atol=1e-5)
