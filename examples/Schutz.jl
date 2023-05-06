#This file is based on the solution manual to the book on general relativity by Schutz.

function cchr(gF::Fun) #construct Christoffel symbol
	igF=inv(gF)
	pda=[]
	for x in gF.x
		push!(pda,PD(x))
	end
	chr=0.5*Ten(igF,[:cha,:ch1])*(Ten(pda,:ch3)*Ten(gF,[:cha,:ch2])+Ten(pda,:ch2)*Ten(gF,[:cha,:ch3])-Ten(pda,:cha)*Ten(gF,[:ch2,:ch3]))
	return simplify(chr)
end
function cRct(gF::Fun) #construct Riemann curvature tensor
	pds=[]
	for x in gF.x
		push!(pds,PD(x))
	end
	chr=cchr(gF)
	return Ten(pds,:ch3)*(chr&@equ(ch3=ch4))-Ten(pds,:ch4)*chr+(chr&@equ(ch2=ch5))*(chr&@equs(ch1=ch5,ch3=ch4))-(chr&@equs(ch2=ch5,ch3=ch4))*(chr&@equ(ch1=ch5))
end
function cRctfv(gF::Fun) #construct Riemann curvature tensor, fun version
	pds=[]
	for x in gF.x
		push!(pds,PD(x))
	end
	chr=cchr(gF)
	return Ten(pds,:ch3)*Ten(fun(chr&@equ(ch3=ch4),gF.x),[:ch1,:ch2,:ch4])-Ten(pds,:ch4)*Ten(fun(chr,gF.x),[:ch1,:ch2,:ch3])+(chr&@equ(ch2=ch5))*(chr&@equs(ch1=ch5,ch3=ch4))-(chr&@equs(ch2=ch5,ch3=ch4))*(chr&@equ(ch1=ch5))
end

#5.3
function cdet(v1,v2) #construct determinant expression from two vectors
	if isa(v1,Fun)
		dim=length(sample(v1))
	else
		dim=length(v1)
	end
	inds=[]
	for i in 1:dim
		push!(inds,Symbol("det$i"))
	end
	detex=Alt(inds)
	for i in 1:dim
		detex=detex*Ten(v1,i)*Ten(v2,inds[i])
	end
	return simplify(detex)
end
v1=[PD(:x),PD(:y)]
v2=Fun(a->[a[1],1],[:x,:y])
detex=cdet(v1,v2) #The matrix becomes transposed as to what it appears in the book.
@assert detex==0#&@equs(x=2,y=3)==0

#5.4
function cdet(m) #m is a square matrix
	dim=size(m)[1]
	inds=[]
	for i in 1:dim
		push!(inds,Symbol("det$i"))
	end
	detex=Alt(inds)
	for i in 1:dim
		detex=detex*Ten(m,[i,inds[i]])
	end
	return simplify(detex)
end
ge=Fun(a->(a[1]^2+a[2]^2)^0.5,[:x,:y])
gn=Fun(a->atan(a[2]/a[1]),[:x,:y])
transmat=[PD(:x)*ge PD(:y)*ge;PD(:x)*gn PD(:y)*gn]
detex=cdet(transmat)
#@assert isnan(detex&@equs(x=0,y=0)) #Expressions involving NaN gets stuck in loops
#f(x,y)=detex&@equs(x=$x,y=$y)
#surface(-3:0.1:9,-3:0.1:9,f)

#5.5 a)
xf(t)=sin(t)
yf(t)=cos(t)
V=Ten([PD(:t)*Fun(xf,:t),PD(:t)*Fun(yf,:t)],:i)
V0=V&@equ t=0
nV=[V0&@equ(i=1),V0&@equ(i=2)]
Vo=[xf(0),yf(0)]
#=
scx=map(xf,0:0.1:7)
scy=map(yf,0:0.1:7)
scatter(scx,scy)
plot!([Vo[1],Vo[1]+nV[1]],[Vo[2],Vo[2]+nV[2]])
=#
#b)
xf(t)=sin(2pi*t^2)
yf(t)=cos(2pi*t+pi)
V=Ten([PD(:t)*Fun(xf,:t),PD(:t)*Fun(yf,:t)],:i)
V0=V&@equ t=0
nV=[V0&@equ(i=1),V0&@equ(i=2)]
Vo=[xf(0),yf(0)] #why doesnt the scatterplot work for this example?

#5.7
tmf(r,th)=[cos(th) -r*sin(th);sin(th) r*cos(th)]
tmif(r,th)=[cos(th) sin(th);-sin(th)/r cos(th)/r]
r=1
th=pi/4
eye=[1 0;0 1]
@assert tmf(r,th)*tmif(r,th)==eye
d=1e-9
dr=tmf(r,th)*[d,0]
@assert isapprox(dr[1],dr[2])
dth=tmf(r,th)*[0,d]
@assert isapprox(-dth[1],dth[2])
drdth=tmf(r,th)*[d,d]
@assert drdth[2]>0&&isapprox(drdth[1]+1,1)
dx=tmif(r,th)*[d,0]
@assert isapprox(dx[1],-dx[2])
dy=tmif(r,th)*[0,d]
@assert isapprox(dy[1],dy[2])
dxdy=tmif(r,th)*[d,d]
@assert isapprox(dxdy[2]+1,1)&&dxdy[1]>0
tmpd=Ten([PD(:r),PD(:th)],:b)*Ten([Fun(a->a[1]*cos(a[2]),[:r,:th]),Fun(a->a[1]*sin(a[2]),[:r,:th])],:a)
for a in 1:2
	for b in 1:2
		@assert isapprox(tmpd&@equs(a=$a,b=$b,r=$r,th=$th),tmf(r,th)[a,b])
	end
end
tmipd=Ten([PD(:x),PD(:y)],:j)*Ten([Fun(a->sqrt(a[1]^2+a[2]^2),[:x,:y]),Fun(a->atan(a[2]/a[1]),[:x,:y])],:i)
for i in 1:2
	for j in 1:2
		@assert isapprox(tmipd&@equs(i=$i,j=$j,x=$(r*cos(th)),y=$(r*sin(th))),tmif(r,th)[i,j])
	end
end
id=tmipd*(tmpd&@equ(a=j))
for i in 1:2
	for b in 1:2
		@assert id&@equs(i=$i,b=$b,x=$(r*cos(th)),y=$(r*sin(th)),r=$r,th=$th)==eye[i,b]
	end
end
dr=tmpd*Ten([d,0],:b)
@assert isapprox(dr&@equs(a=1,r=$r,th=$th),dr&@equs(a=2,r=$r,th=$th))
dth=tmpd*Ten([0,d],:b)
@assert isapprox(-dth&@equs(a=1,r=$r,th=$th),dth&@equs(a=2,r=$r,th=$th))
drdth=tmpd*Ten([d,d],:b)
@assert drdth&@equs(a=2,r=$r,th=$th)>0&&isapprox(drdth&@equs(a=1,r=$r,th=$th)+1,1)

#5.9
erf(th)=[cos(th),sin(th)]
er0=erf(0)
er1=erf(pi/8)
er2=erf(pi/4)
er3=erf(pi/2)
ethf(r,th)=[-r*sin(th),r*cos(th)]
eth01=ethf(1,0)
eth02=ethf(3,0)
eth1=ethf(2,pi/8)
eth21=ethf(1.5,pi/4)
eth22=ethf(2.5,pi/4)
eth3=ethf(1,pi/2)
#=
plot([0,3*er0[1]],[0,3*er0[2]])
plot!([0,3*er1[1]],[0,3*er1[2]])
plot!([0,3*er2[1]],[0,3*er2[2]])
plot!([0,3*er3[1]],[0,3*er3[2]])
plot!([er0[1],er0[1]+eth01[1]],[er0[2],er0[2]+eth01[2]])
plot!([3*er0[1],3*er0[1]+eth02[1]],[3*er0[2],3*er0[2]+eth02[2]])
plot!([2*er1[1],2*er1[1]+eth1[1]],[2*er1[2],2*er1[2]+eth1[2]])
plot!([1.5*er2[1],1.5*er2[1]+eth21[1]],[1.5*er2[2],1.5*er2[2]+eth21[2]])
plot!([2.5*er2[1],2.5*er2[1]+eth22[1]],[2.5*er2[2],2.5*er2[2]+eth22[2]])
plot!([er3[1],er3[1]+eth3[1]],[er3[2],er3[2]+eth3[2]])
=#

#5.11 a)
Vf(a)=[a[1]^2+3*a[2],a[2]^2+3*a[1]]
VF=Fun(Vf,[:x,:y])
VT=Ten(VF,:a)
pdT=Ten([PD(:x),PD(:y)],:b)
Vcb=pdT*VT
x=rand()
y=rand()
sola=[2*x 3;3 2*y]
for a in 1:2
	for b in 1:2
		@assert Vcb&@equs(a=$a,b=$b,x=$x,y=$y)==sola[a,b]
	end
end

#b)
V_acb=Ten(Fun(a->[2a[1]*cos(a[2]) 3;3 2a[1]*sin(a[2])],[:r,:th]),[:a,:b])
tm_bv=Ten(Fun(a->[cos(a[2]) -a[1]*sin(a[2]);sin(a[2]) a[1]*cos(a[2])],[:r,:th]),[:b,:v])
tmi_ua=Ten(Fun(a->[cos(a[2]) sin(a[2]);-sin(a[2])/a[1] cos(a[2])/a[1]],[:r,:th]),[:u,:a])
V_uCv=tmi_ua*V_acb*tm_bv
r=sqrt(x^2+y^2)
th=atan(y/x)
solb=[2r*(cos(th)^3+sin(th)^3)+3sin(2th) 2r^2*(-cos(th)^2*sin(th)+sin(th)^2*cos(th))+3r*cos(2th);2*(-cos(th)^2*sin(th)+sin(th)^2*cos(th))+3/r*cos(2th) 2r*(cos(th)^2*sin(th)+sin(th)^2*cos(th))-3sin(2th)]
for u in 1:2
	for v in 1:2
		@assert isapprox(V_uCv&@equs(u=$u,v=$v,r=$r,th=$th),solb[u,v])
	end
end
tm_bv=tmpd&@equs(b=v,a=b)
tmi_ua=tmipd&@equs(i=u,j=a)
V_uCv2=tmi_ua*Vcb*tm_bv
V_uCv=tmi_ua*V_acb*tm_bv
for u in 1:2
	for v in 1:2
		@assert isapprox(V_uCv&@equs(u=$u,v=$v,x=$x,y=$y,r=$r,th=$th),solb[u,v])
	end
end
 
#c)
#=function cchr(gF::Fun) #construct Christoffel symbol
	igF=Fun(a->inv(gF.y(a)),gF.x)
	pda=[PD(gF.x[1]),PD(gF.x[2])]
	chr=0.5*Ten(igF,[:cha,:ch1])*(Ten(pda,:ch3)*Ten(gF,[:cha,:ch2])+Ten(pda,:ch2)*Ten(gF,[:cha,:ch3])-Ten(pda,:cha)*Ten(gF,[:ch2,:ch3]))
	return chr
end=#
gF=Fun(a->[1 0;0 a[1]^2],[:r,:th])
chr=cchr(gF)
chrsol=zeros(2,2,2)
chrsol[1,2,2]=-r
chrsol[2,1,2]=1/r
chrsol[2,2,1]=1/r
for i in 1:2
	for j in 1:2
		for k in 1:2
			@assert isapprox(chr&@equs(ch1=$i,ch2=$j,ch3=$k,r=$r,th=$th),chrsol[i,j,k])
		end
	end
end

Vf(a)=[a[1]^2*(cos(a[2])^3+sin(a[2])^3)+3*a[1]*sin(2a[2]),-a[1]*cos(a[2])^2*sin(a[2])+a[1]*sin(a[2])^2*cos(a[2])+3cos(2a[2])]
VF=Fun(Vf,[:r,:th])
VT=Ten(VF,:ch2)
pdT=Ten([PD(:r),PD(:th)],:b)
V_2cb=pdT*VT
solc=[2r*(cos(th)^3+sin(th)^3)+3sin(2th) 3r^2*(-cos(th)^2*sin(th)+sin(th)^2*cos(th))+6r*cos(2th);(-cos(th)^2*sin(th)+sin(th)^2*cos(th)) r*(2sin(th)^2*cos(th)+2cos(th)^2*sin(th)-cos(th)^3-sin(th)^3)-6sin(2th)]
m=zeros(2,2)
for a in 1:2
	for b in 1:2
		m[a,b]=V_2cb&@equs(ch2=$a,b=$b,r=$r,th=$th)
		@assert isapprox(V_2cb&@equs(ch2=$a,b=$b,r=$r,th=$th),solc[a,b])
	end
end

ex=VT*chr
m2=zeros(2,2)
for ch1 in 1:2
	for ch3 in 1:2
		m2[ch1,ch3]=ex&@equs(ch1=$ch1,ch3=$ch3,r=$r,th=$th)
	end
end
@assert isapprox(m2+m,solb)

mT=V_2cb&@equs(r=$r,th=$th)
m2T=ex&@equs(r=$r,th=$th)
V_1c3=Transp(V_2cb&@equs(b=ch3,ch2=ch1))
suex=V_1c3+ex
mtT=suex&@equs(r=$r,th=$th)
@assert isapprox(mtT.x,solb)

#d)
Vf(a)=[a[1]^2+3*a[2],a[2]^2+3*a[1]]
VF=Fun(Vf,[:x,:y])
VT=Ten(VF,:a)
pdT=Ten([PD(:x),PD(:y)],:b)
Vcb=pdT*VT
rd=Vcb&@equs(b=a,x=$x,y=$y)
sold=2r*(cos(th)+sin(th))
@assert isapprox(rd,sold)

#e)
mtTtr=mtT&@equ ch1=ch3
@assert isapprox(mtTtr,sold)

#f)
Vf(a)=[a[1]*(a[1]^2*(cos(a[2])^3+sin(a[2])^3)+3*a[1]*sin(2a[2])),-a[1]*cos(a[2])^2*sin(a[2])+a[1]*sin(a[2])^2*cos(a[2])+3cos(2a[2])]
VF=Fun(Vf,[:r,:th])
VT=Ten(VF,:a)
pdT=Ten([(1/r)*PD(:r),PD(:th)],:a)
tracef=(pdT*VT)&@equs(r=$r,th=$th)
@assert isapprox(tracef,sold)

#13
#p=Ten(gF,[:a,:ch1])*suex
p2=Ten(gF,[:a,:ch1])*mtT
#psim=p&@equs(r=$r,th=$th)
p2sim=p2&@equs(r=$r,th=$th)
@assert isapprox(p2sim.x[1,:],mtT.x[1,:]) && isapprox(p2sim.x[2,:]/r^2,mtT.x[2,:])

#15
#=
VF=Fun(a->[a[1],a[2]],[:r,:th])
#V_1C3=Transp(Ten([PD(:r),PD(:th)],:ch3)*Ten(VF,:ch1))+Ten(VF,:ch2)*chr
V_1C3=Ten([PD(:r),PD(:th)],:ch3)*Ten(VF,:ch1)+Ten(VF,:ch2)*chr
V_1C3&@equs(r=1,th=0)
B_12c3=GenTrans(Ten([PD(:r),PD(:th)],:ch3)*(V_1C3&@equ(ch3=ch2)),:ch1,:ch3)
B_12c3&@equs(r=1,th=0)
B_a2=(V_1C3&@equs(ch1=a,ch3=ch2))*(chr&@equ(ch2=a))
B_a2&@equs(r=1,th=0)
B_1a=-(V_1C3&@equ(ch3=a))*(chr&@equ(ch1=a))
B_1a&@equs(r=1,th=0)
VCC=B_12c3+B_a2+B_1a
VCC&@equs(r=1,th=0)
=#

#6.5 a)
r=rand();th=rand()
gF=Fun(a->[1 0;0 a[1]^2],[:r,:th])
chr=cchr(gF)
chr0=chr&@equs(r=$r,th=$th)
@assert isapprox(chr0.x[1,2,1],chr0.x[1,1,2])
@assert isapprox(chr0.x[2,2,1],chr0.x[2,1,2])

#6.7 b)
ra=rand(8)
AF=Fun(a->[ra[1]*(a[1]+a[2]^ra[2]) ra[3]*(a[1]-a[2]^ra[4]);ra[5]*(-a[1]+a[2]^ra[6]) ra[7]*(-a[1]-a[2]^ra[8])],[:x,:y])
Adet=det(AF)
Adetdu=Ten([PD(:x),PD(:y)],:u)*Adet
x=rand();y=rand()
lhsxy=Adetdu&@equs(x=$x,y=$y)
rhs=Adet*Ten(inv(AF),[:a,:b])*Ten([PD(:x),PD(:y)],:u)*Ten(AF,[:b,:a])
rhsxy=rhs&@equs(x=$x,y=$y)
@assert isapprox(lhsxy.x,rhsxy.x)

#6.9
ra=rand(2)
VF=Fun(a->[a[1]^ra[1],a[2]^ra[2]],[:r,:th])
VC=cC(VF,gF)
VCtr=VC&@equs(r=$r,th=$th,ch1=ch3)
rhs=1/sqrt(abs(det(gF)))*Ten([PD(:r),PD(:th)],:a)*Ten(sqrt(abs(det(gF)))*VF,:a)
VCtr2=rhs&@equs(r=$r,th=$th)
@assert isapprox(VCtr,VCtr2)
rF=Fun(a->a[1],[:r,:th])
rhs2=1/:r*PD(:r)*(Ten(rF*VF,1))+PD(:th)*Ten(VF,2) #corrected typo a->r
VCtr3=rhs2&@equs(r=$r,th=$th)
@assert isapprox(VCtr,VCtr3)
ra=rand(3)
ph=rand()
gF3D=Fun(a->[1 0 0;0 a[1]^2 0;0 0 a[1]^2*sin(a[2])^2],[:r,:th,:ph])
VF3D=Fun(a->[a[1]^ra[1],a[2]^ra[2],a[3]^ra[3]],[:r,:th,:ph])
VC3D=cC(VF3D,gF3D)
VC3Dtr=VC3D&@equs(r=$r,th=$th,ph=$ph,ch1=ch3)
rhs3D=PD(:r)*Ten(VF3D,1)+PD(:th)*Ten(VF3D,2)+PD(:ph)*Ten(VF3D,3)+2Ten(VF3D,1)/r+Ten(VF3D,2)/tan(th)
VC3Dtr2=rhs3D&@equs(r=$r,th=$th,ph=$ph)
@assert isapprox(VC3Dtr,VC3Dtr2)
rhs3D2=1/sqrt(abs(det(gF3D)))*Ten([PD(:r),PD(:th),PD(:ph)],:a)*Ten(sqrt(abs(det(gF3D)))*VF3D,:a)
VC3Dtr3=rhs3D2&@equs(r=$r,th=$th,ph=$ph)
@assert isapprox(VC3Dtr,VC3Dtr3)

#6.11 a)
VF=Fun(a->[(a[1]+a[2])^ra[1],(a[1]+a[2])^ra[2]],[:r,:th])
Vcvb=PD(:r)*PD(:th)*Ten(VF,:a)
Vcbv=PD(:th)*PD(:r)*Ten(VF,:a)
@assert isapprox((Vcvb&@equs(r=$r,th=$th)).x,(Vcbv&@equs(r=$r,th=$th)).x)
chr=cchr(gF)
lhs=(Ten([PD(:r),PD(:th)],:ch4)*chr-Ten([PD(:r),PD(:th)],:ch3)*(chr&@equ(ch3=ch4)))*Ten(VF,:ch2)
rhs=(chr*(chr&@equs(ch2=ch5,ch3=ch4,ch1=ch2))-(chr&@equ(ch3=ch4))*(chr&@equs(ch2=ch5,ch1=ch2)))*Ten(VF,:ch5)
leq=lhs&@equs(r=$r,th=$th)
req=rhs&@equs(r=$r,th=$th) #These are not equal, but maybe they only are for the Vs that satisfies 6.35

#6.13 a)
gFla=Fun(la->gF.y([la,la^2]),:la)
AFla=Fun(la->[la+la^0.5,la^2],:la)
BFla=Fun(la->[la,la^4],:la)
ex=Ten(gFla,[:a,:b])*Ten(AFla,:a)*Ten(BFla,:b)
s=simplify(ex)
spd=PD(:la)*s
la=rand()
pd1=spd&@equ(la=$la)
pdex=PD(:la)*(Ten(gFla,[:a,:b])*Ten(AFla,:a)*Ten(BFla,:b))
pd2=pdex&@equ(la=$la)
@assert isapprox(pd1,pd2) #this is supposed to be zero though...

gC=cC(gF,gF)
fex=Ten(Fun(a->[a[1],a[2]],[:r,:th]),:ch3)*gC
fex&@equs(r=$(r),th=$(th))
fexlaF=Fun(a->(fex&@equs(r=$(a),th=$(a^2))).x,:la)
dfexla=PD(:la)*fexlaF
dfexla&@equ la=$la #still not zero...

#6.19
R=cRct(gF)
Rn=R&@equs(r=$r,th=$th)
@assert Rn==0||isapprox(Rn.x .+ 1,ones(size(Rn.x)))
eyeF=Fun(a->[1 0;0 1],[:x,:y])
Reye=cRct(eyeF)
Reyen=Reye&@equs(x=0.24,y=1.23) 
gFc=Fun(a->[1 0;0 a[1]^2+a[2]^2],[:x,:y])
Rc=cRct(gFc)
Rcn=Rc&@equs(x=0.24,y=1.23) #Now this isn't zero anymore...

#6.21
n=gC&@equs(r=$r,th=$th) #this should be zero...
igC=cC(inv(gF),gF)
ni=igC&@equs(r=$r,th=$th) #this isnt zero either
gC3D=cC(gF3D,gF3D)
n3D=gC3D&@equs(r=$r,th=$th,ph=$ph) #nor this
gCc=cC(gFc,gFc)
nc=gCc&@equs(x=$r,y=$th) #nor this

#6.25
R0=R&@equ ch1=ch2
R0n=R0&@equs(r=$r,th=$th)
@assert R0n==0||isapprox(R0n.x .+ 1,ones(size(R0n.x)))
Ric=R&@equ ch1=ch3
Ricn=Ric&@equs(r=$r,th=$th)
@assert Ricn==0||isapprox(Ricn.x .+ 1,ones(size(Ricn.x)))

#6.29
r=3.0
gFsph=Fun(a->diagm([r^2,r^2*sin(a[1])^2]),[:th,:ph])
Rsph=cRct(gFsph)
nsph=Rsph&@equs(th=$(pi/2),ph=1)
nsph=trans(trans(nsph,:ch2,:ch1),:ch4,:ch3)
@assert nsph[1,2,1,2]==1
@assert nsph[2,1,1,2]==-1
@assert nsph[2,1,2,1]==1
lowR=Ten(gFsph,[:a,:ch1])*Rsph
th=rand()
lown=lowR&@equs(th=$th,ph=1)
lown=trans(trans(lown,:ch2,:a),:ch4,:ch3)
@assert isapprox(lown[1,2,1,2],r^2**sin(th)^2)
@assert isapprox(lown[2,1,1,2],-r^2**sin(th)^2)
@assert isapprox(lown[1,2,2,1],-r^2**sin(th)^2)
