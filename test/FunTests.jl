ex=Fun(a->a,:x)*:a*Fun(a->a,:y)*:b*Fun(a->a,:y)
sex=simplify(ex)
@test length(sex[1])==4
