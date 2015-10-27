ex=Ten([1,2,3],:i)*Ten([90,80,70],:i)
@test simplify(ex,Ten)==460

ex=Ten(:A,:i)*Ten(:A,:j)
@test simplify(ex&@equs(A=[1,2,3], j=i),Ten)==14
