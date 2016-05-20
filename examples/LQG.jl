#Based on the book about Loop Quantum Gravity by Rodolfo Gambini and Jorge Pullin.

#Ch 2.
#1. The pole in the barn paradox. ✓
#Lorentz transformation:
gam=@equ γ=1/(1-v^2)	#c=1
tp=@equ t´=γ*(t-v*x)
xp=@equ x´=γ*(x-v*t)
println("A 3 meters long pole is traveling quickly toward a barn that is shorter than its length.")

println("l=length of pole")
println("At time 0:")
a=[gam;@equs(x=0,t=0,v=0.5)];println("Base of pole: ", xp&a,",\t",tp&a)
a=[gam;@equs(x=l,t=0,v=0.5)];println("Tip of pole: ", xp&a,",\t",tp&a)
println("At time t:")
a=[gam;@equs(x=0+t*v,v=0.5)];println("Base of pole: ", xp&a,",\t",tp&a)
a=[gam;@equs(x=l+t*v,v=0.5)];println("Tip of pole: ", xp&a,",\t",tp&a)
println("Time at the tip is earlier than at the base, hence when the tip touches the barn wall the base has had time to enter.")

println("The pole is rotated about the time axis of the barn. When one object is rotated relative to another their projections become dwarfed, like when drawing a line at right angle from the minute pointer of a clock to its hour pointer, the projection becomes progressively smaller until it disappears at ninety degrees which in this analogy is light speed. Photons can therefore be complete universes that are rotated at right angles with respect to this universe.")


#2
M=[:t^2 :t*:x1 :q :q;:x1*:t :x1^2 :q :q;:q :q :x2 :q;:q :q :q :x3]
d=@equ Ten(D,[v,w])=Ten($(M),[v,w]) #D is not mentioned in the texts...
η=@equ Ten(η,[μ,v])=Ten($(diagm([-1,1,1,1])),[μ,v])
eq2_11=@equ Ten(Λ,[μ´,μ])=Ten([Cosh(ϕ) -Sinh(ϕ) 0 0;-Sinh(ϕ) Cosh(ϕ) 0 0;0 0 1 0;0 0 0 1], [μ´,μ])
d´=(eq2_11*(d&@equ(v=μ)))
d2´=(eq2_11*η*d)
#print(d´&@equ w=μ´) #should not be invariant
#print(d2´&@equ w=μ´) #should be invariant
#should make sense...

#3 ✓
a=@equs(Δt=0.91,Δx1=3.5,Δx2=5,Δx3=-1.54,ϕ=1.59,c=1)
eq2_8=@equ Δs^2=-(c*Δt)^2+(Δx1)^2+(Δx2)^2+(Δx3)^2
#2_8 Δs^2 should be invariant under 2_11
dX=@equ ΔX=Ten([Δt, Δx1, Δx2, Δx3], v)
@assert (η*dX)&@equ(μ=2) == (Ten(:η,Any[2,:v])*:ΔX ≖ :Δx1)

dX´=@equ(ΔX´=Ten(Λ,[μ´,μ])*Ten([Δt, Δx1, Δx2, Δx3], μ))&eq2_11
eq2_8´=@equ(Δs^2=-($(dX´.rhs)&@equ(μ´=1))^2+($(dX´.rhs)&@equ(μ´=2))^2+(Δx2)^2+(Δx3)^2)
@assert isapprox(eq2_8.rhs&a, eq2_8´.rhs&a) #Yay, distance is unchanged!
#eq2_8´=@equ(Δs^2=-(Δt*Cosh(ϕ)-Δx1*Sinh(ϕ))^2+(-Δt*Sinh(ϕ)+Δx1*Cosh(ϕ))^2+(Δx2)^2+(Δx3)^2) #substituting manually gives this

#4 ✓
emM=[0 -:E1 -:E2 -:E3;:E1 0 :B3 -:B2;:E2 -:B3 0 :B1;:E3 :B2 -:B1 0]
eq2_31=@equ Ten(F,[μ,v])=Ten($emM,[μ,v])
eq2_35=@equ Alt([m,n,o,p])*Ten([∂t,∂1,∂2,∂3],:n)*Ten($emM,[o,p])=0
print(eq2_35&@equ m=1)

n1=Ten(diagm([-1,1,1,1]),[:j,:j´])
n2=Ten(diagm([-1,1,1,1]),[:k,:k´])
simplify(@equ(2*Delta(i,m)=Alt([i,j,k])*($n1*$n2*Alt([j,k,m]))))

