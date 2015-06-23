#Week 6
#A
eq1=@equ δ=4m*M/(m+M)^2 #maximum fraction of energy transferable
eq2=@equ Te-Tgas=2qe*E^2/(3δ*me*vm^2) #∝p^-2, steady state

#B
b1=@equ d*Ṅ=Ṅ*α*d*x
b2=@equ Ṅ=Ṅ0*exp(α*x)
b3=@equ i=Ṅ0*e*exp(α*d) # =i0*exp(α*d) #current leaving the anode #should e be qe?
b4=@equ i=i0*exp(α*d)/(1-γ*(exp(α*d)-1)) #sum of avalances
b5=@equ γ*exp(α*d)=γ+1 #1-γ*(exp(α*d)-1)=0 #breakdown criterion

#C
c1=@equ α=A*p*exp(-B*p/E)
c1b=@equ α=1/λ*exp(-ϵi/(e*E*λ))
c1c=@equ α=A*p*exp(-B*p*d/V)
c2=@equ E=V/d #for parallel plates
c3=@equ VB=B*p*d/(log(A*p*d)-log(log(1+1/γ))) #breakdown voltage
c3b=@equ VB=B*p*d/(log(C*p*d))
c3c=@equ C=A/log(1+1/γ)
c4=@equ Der(nj,t)+Dot(∇,Γj)=Sj
c5=@equ Sj=ne*α*ue
c6=@equ E=-∇V
c7=@equ ∇^2*V=0
#boundary conditions
c8=@equ n*Γi_anode=0 #ions
c9=@equ n*Γe_cathode=-γse*n*Γi_cathode

#D
d1=@equ Γi=ni*c̄i/4 #ion thermal flux
d1b=@equ c̄i=sqrt(8*e*Ti/(pi*mi))
d2=@equ Γe=ne*c̄e/4 #electron thermal flux
d2b=@equ c̄e=sqrt(8*e*Te/(pi*me))

#E
e1=@equ 1/2*M*u^2+e*V=1/2*M*us^2
e2=@equ ni*u=ns*us
e3=@equ ni=ns*(1-2*e*V/(M*us^2))^(-0.5) #ion density in sheath
e4=@equ ne=ns*exp(V/Te) #electron density in sheath
e5=@equ Der(Der(V,x),x)=-(ni-ne)*e/ϵ0 #Poisson's euqation in sheath
e6=@equ ub=sqrt(e*Te/M)#≤us #Bohm's criterion
e7=@equ ns*uB=0.61n0*sqrt(e*Te/M) #ion flux to a wall
e8=@equ e*ns*ub*A=0.61*e*A*n0*sqrt(e*Te/M) #ion current to a probe area A
e9=@equ Vs=Te/2*log(M/(2*pi*m))#~4.7Te for argon #sheath voltage drop
e10=@equ ϵi=e*Te/2*log(M/2.3m)#~5.2e*Te #Ion energy to a wall


#Week 7
#B
b1=@equ ΔEf=ΔEα+ΔEn
b2=@equ RDT*ΔEf=nD*nT*σDT*v*ΔEf	#fusion power density, depends on v
b3=@equ nD*nT*σv*ΔEf=1/4*n^2*σv*ΔEf #whole plasma, avg σv
b4=@equ Pb/volume=A*n^2*Zeff*sqrt(Te) #Bremsstrahlung
b4b=@equ A=5e-37 #Wm^-3
b4c=@equ Zeff=nj*Zj^2/n #sum over j
b5=@equ Pdl/volume=3n*T/τE #losses
b6=@equ Q=Pf/Pin
b7=@equ fα=Pα/(Pα+Pin)
b8=@equ QE=(Pout_E-Pin_E)/Pin_E #conversion efficiency
b8b=@equ Pin_E=Pin/ηe
b8c=@equ Pout_E=ηt*(Pf+Pin)

#C
c1=@equ El=1/((ϵl*ϵth)^3*ϵc^4)*(n0/n)^2	#driver energy

#D
d1=@equ thickness=1/(number_density*cross_section)	#required wall thickness
d2=@equ I=I0*exp(-x/λtot)

#E
e1=@equ Γr=D*Der(n,r)
