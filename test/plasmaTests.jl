constants=[:me≖9.1094e-31,:qe≖1.6022e-19,:kB≖1.3807e-23,:ε0≖8.8542e-12]

# Solar wind
ne=:ne≖10.0^7
Te=:Te≖10.0*:qe
variables=[ne,Te]
# Debye length lD
lD=:λD≖sqrt(:ε0*:Te/(:ne*:qe^2)) #valid when Te>>Ti
# plasma frequency wp
wp=:ωp≖sqrt(:ne*:qe^2/(:ε0*:me))
# particles in a debye cube ND
ND=:ND≖:ne*:λD^3

@test_approx_eq (lD&variables&constants).rhs 7.433892903446526
@test_approx_eq (wp&lD&variables&constants).rhs 178400.95597166813
@test_approx_eq (ND&lD&variables&constants).rhs 4.108174668936227e9

# Drifts
ve=:ve≖Cross(:E⊥,:B)/norm(:B)^2
ex=[1,0,0];ey=[0,1,0];ez=[0,0,1]
B=:B≖:Bt*Vec(ez)
Bt=:Bt≖1.5
r=:r≖1
dBt=:dBt≖0.3
Eperp=:E⊥≖-:r/2*:dBt*Vec(ey)
vars=[B,Bt,Eperp,r,dBt]

@test_approx_eq (ve&vars).rhs[1][1] -0.1
@test (ve&vars).rhs[1][2]==Vec([1,0,0])

# Temperatures
equ=Equation
Ekin=equ(:Ekin,0.5*:Tpa+:Tpe)
parfac=1
Tpa1=equ(:Tpa1,parfac*:T0) #is parallel temperature affected?
Tpe1=equ(:Tpe1,2*:T0)
Ek1=equ(:Ek1,0.5*:Tpa1+:Tpe1)
Ek2=equ(:Ek1,0.5*:T2+:T2)
Ek1s=Ek1&Tpa1&Tpe1 #s=solved
T2=(Ek2&Ek1s)/1.5
T2=equ(T2.rhs,T2.lhs)
Tpa3=equ(:Tpa3,1/parfac*:T2) #is it?
Tpe3=equ(:Tpe3,:T2/2)
Ek3=equ(:Ek3,0.5*:Tpa3+:Tpe3)
Ekf=[equ(:Ekf,0.5*:Tf+:Tf),equ(:Ekf,:Ek3)]
Tf=(Ekf[1]&Ekf[2]&Ek3&Tpa3&Tpe3&T2)/1.5

@test_approx_eq T2.rhs[1][1] 1.6666666666666665
@test_approx_eq Tf.lhs[1][1] 1.111111111111111
