#Based on the book about Loop Quantum Gravity by Rodolfo Gambini and Jorge Pullin.

#Ch 2.
#1. The pole in the barn paradox.
#Lorentz transformation:
gam=@equ γ=1/(1-v^2)	#c=1
tp=@equ t´=γ*(t-v*x)
xp=@equ x´=γ*(x-v*t)
println("A 3 meters long pole is traveling quickly toward a barn that is that is shorter than its length.")

println("l=length of pole")
println("At time 0:")
a=[gam;@equs(x=0,t=0,v=0.5)];println("Base of pole: ", xp&a,",\t",tp&a)
a=[gam;@equs(x=l,t=0,v=0.5)];println("Tip of pole: ", xp&a,",\t",tp&a)
println("At time t:")
a=[gam;@equs(x=0+t*v,v=0.5)];println("Base of pole: ", xp&a,",\t",tp&a)
a=[gam;@equs(x=l+t*v,v=0.5)];println("Tip of pole: ", xp&a,",\t",tp&a)
println("Time at the tip is earlier than at the base, hence when the tip touches the barn wall the base has had time to enter.")

println("The pole is rotated about the time axis of the barn. When one object is rotated relative to another their projections become dwarfed, like when drawing a line at right angle from the minute pointer of a clock to its hour pointer, the projection becomes progressively smaller until it disappears at ninety degrees which in this analogy is light speed. Photons can therefore be complete universes that are rotated at right angles with respect to this universe.")



g=@equ g=Ten(diagm([-1,1,1,1]),[μ,v])
#3
eq2_8=@equ Δs^2=-(c*Δt)^2+(Δx1)^2+(Δx2)^2+(Δx3)^2
eq2_11=@equ Λ=Ten([Cosh(ϕ) -Sinh(ϕ) 0 0;-Sinh(ϕ) Cosh(ϕ) 0 0;0 0 1 0;0 0 0 1], [μ´,μ])
#Δs^2 should be invariant under 2_11
dX=[:Δt, :Δx1, :Δx2, :Δx3]
dX=@equ ΔX=Ten([Δt, Δx1, Δx2, Δx3], v)
ds´=@equ Δs´^2=Λ*(-(c*Δt)^2+(Δx1)^2+(Δx2)^2+(Δx3)^2)
#Λ*ΔX
@assert simplify(g*dX)&@equ(μ=2) == (:g*:ΔX ≖ :Δx1)

simplify(@equ(1=Λ*ΔX)&eq2_11&dX)&@equ(μ´=1)
@equ(Ten(ΔX´,μ´)=Λ*g*ΔX)&eq2_11&g&dX&@equ(μ´=1)
@equ(Ten(ΔX´,μ´)=Λ*ΔX)&eq2_11&g&dX&@equ(v=μ)&@equ(μ´=1)

ds2=@equ(Δs^2=g*Ten([Δt, Δx1, Δx2, Δx3], v)*Ten([Δt, Δx1, Δx2, Δx3], μ))&g
@assert randeval(ds2.rhs)==randeval(eq2_8.rhs&@equ(c=1))
