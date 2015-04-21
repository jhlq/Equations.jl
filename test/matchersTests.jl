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
	@test simplify(replace(pattern,md))==ex
end
ex=:x*3*:x
pattern=:a*3*:a
@test !isempty(matches(ex,pattern))
