#Based on the book about Loop Quantum Gravity by Rodolfo Gambini and Jorge Pullin.

#Ch 2.
#The pole in the barn paradox.
#Lorentz transformation:
gam=@equ γ=1/(1-v^2)	#c=1
tp=@equ t´=γ*(t-v*x)
xp=@equ x´=γ*(x-v*t)
println("A 3 meters long pole is traveling quickly (0.5c) toward a barn that is 2 meters deep. The pole and the barn both agree that a flagpole 3 meters in front of the barn shall be a common reference point where x=0.")

println("l=length of pole")
println("At time 0:")
a=[gam;@equs(x=0,t=0,v=0.5)];println("Base of pole: ", xp&a,",\t",tp&a)
a=[gam;@equs(x=l,t=0,v=0.5)];println("Tip of pole: ", xp&a,",\t",tp&a)
println("At time t:")
a=[gam;@equs(x=0+t*v,v=0.5)];println("Base of pole: ", xp&a,",\t",tp&a)
a=[gam;@equs(x=l+t*v,v=0.5)];println("Tip of pole: ", xp&a,",\t",tp&a)
println("The time at the tip is earlier than the base, hence when the tip touches the barn wall the base has had time to enter.")

#The pole is rotated about the time axis of the barn. When one object is rotated relative to another their projections become dwarfed, like when drawing a line at right angle from the minute pointer of a clock to its hour pointer, the projection becomes progressively smaller until it disappears at ninety degrees which in this analogy is light speed. Photons can therefore be complete universes that are rotated at right angles with respect to this universe.
