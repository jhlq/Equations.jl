v=:v≖Cross(:A,:B)
e1=[1,0,0];e2=[0,1,0];e3=[0,0,1]
A=:A≖3*:c*Vec(e2)
B=:B≖0.5*Vec(e3)
c=:c≖299792458
vs=v&[A,B,c]
@test vs.rhs==4.49688687e8*Vec(e1)
