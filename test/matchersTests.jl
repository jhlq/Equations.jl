ex=3*:x
pattern=:a*:b
@test !isempty(matches(ex,pattern))
ex=3*:x*:y
pattern=:a*:b
mds=matches(ex,pattern)
@test !isempty(mds)
for md in mds
	@test simplify(replace(pattern,md))==ex
end
ex=3*:x*:y
pattern=:a*:b
mds=matches(ex,pattern)
@test !isempty(mds)
for md in mds
	@test simplify(replace(pattern,md))==ex
end
ex=3*:x*:y*:z
pattern=:a*:b
mds=matches(ex,pattern)
@test !isempty(mds)
for md in mds
	@test simplify(replace(pattern,md))==ex
end
ex=3*:x*:y*:z
pattern=:a*:b*:c
mds=matches(ex,pattern)
@test !isempty(mds)
for md in mds
	@test simplify(replace(pattern,md))==ex
end
ex=:x*3*:y
pattern=:a*3*:b
mds=matches(ex,pattern)
@test !isempty(mds)
for md in mds
	@test simplify(replace(pattern,md))==simplify(ex)
end
ex=:x*3*:x
pattern=:a*3*:a
@test !isempty(matches(ex,pattern))
for md in mds
	@test simplify(replace(pattern,md))==simplify(ex)
end
@test {:a=>{:x,:x}}∈matches(3*:x*:x,3*:a)
@test {:a=>{:x,:x,:x,:y,:z}}∈matches(3*:x*:x*:y*:z*:x,3*:a)
@test {:b=>:y,:a=>:x}∈matches(:x+:y,:a+:b)
@test {:a=>:x}∈matches(:x+:x,:a+:a)
@test isempty(matches(:x+:y,:a+:a))
@test isempty(matches(:x+:x*:y,:a+:a)) #x can be 1 but a can't generically be x
@test {:a=>:x,:b=>:y}∈matches(:x+:x/:y,:a+:a/:b)
