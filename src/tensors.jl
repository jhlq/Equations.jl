abstract AbstractTensor<:NonAbelian
type Ten<:AbstractTensor
	x
	indices::Array{Any}
end
Ten(x,s::N)=Ten(x,[s])
function print(io::IO,t::Ten)
	print(io,"$(t.x)(")
	if isa(t.indices,Array)
		if !isempty(t.indices)
			print(io,t.indices[1])
			for i in 2:length(t.indices)
				print(io,' ',t.indices[i])
			end
		end
	else
		print(io,t.indices)
	end
	print(io,")")
end
function allnum(a::Array)
	for n in a
		if !isa(n,Number)
			return false
		end
	end
	return true
end
type Tensor<:AbstractTensor
	x
	upper
	lower
	rank
end
Tensor(a,b,c)=Tensor(a,b,c,-1)
Tensor(a)=Tensor(a,-1,-1,-1)
function print(io::IO,t::Tensor)
	print(io,"$(t.x)($(t.upper),$(t.lower))")
end
abstract AbstractIndex<:Component
type Up<:AbstractIndex
	x
end
function duplicates(arr)
	larr=length(arr)
	for a in 1:larr
		aa=larr-a+1
		for b in 1:larr
			bb=larr-b+1
			if a==b
				continue
			elseif arr[aa]==arr[bb]
				return [bb,aa]
			end
		end
	end
	return 0
end
function duplicates(arr1,arr2)
	larr1=length(arr1)
	for a in 1:larr1
		aa=larr1-a+1
		larr2=length(arr2)
		for b in 1:larr2
			bb=larr2-b+1
			if arr1[aa]==arr2[bb]
				return [aa,bb]
			end
		end
	end
	return 0
end
function arrduplicates(arrs...)
	larrs=length(arrs)
	for i in 1:larrs-1
		for j in i+1:larrs
			d=duplicates(arrs[i],arrs[j])
			if d!=0
				return ([i,j],d)
			end
		end
	end
	return 0
end
sumconv(a)=simplify(a,Ten)
function sumconv(ex::Expression)
	nat=Term[]
	for t in ex
		pushall!(nat,sumconv(t))
	end
	Expression(nat)
end
function sumconv!(t::Term)
	inds=indsin(t,AbstractTensor)
	for i in inds
		t[i]=sumconv(t[i])
	end
	indsa=Array[]
	for i in inds
		push!(indsa,t[i].indices)
	end
	iiii=arrduplicates(indsa...)
	if iiii!=0
		ti1=inds[iiii[1][1]]
		ti2=inds[iiii[1][2]]
		iii=iiii[2]
		t1=t[ti1];t2=t[ti2]
		if !(isa(t1.x,Array)&&isa(t2.x,Array))
			return Term[t]
		end
		st1=size(t1.x);st2=size(t2.x)
		lst1=length(st1);lst2=length(st2)
		iti1=Any[];iti2=Any[]
		for l in 1:lst1
			push!(iti1,:)
		end
		for l in 1:lst2
			push!(iti2,:)
		end
		lit1=length(t1.indices);lit2=length(t2.indices)
		iti1[end-lit1+iii[1]]=1
		iti2[end-lit2+iii[2]]=1
		newterm=deepcopy(t)
		nt1=Ten(t1.x[iti1...],deleteat!(deepcopy(t1.indices),iii[1]))
		nt2=Ten(t2.x[iti2...],deleteat!(deepcopy(t2.indices),iii[2]))
		newterm[ti1]=nt1;newterm[ti2]=nt2
		at=Term[newterm]
		for di1 in 1:st1[end-lit1+iii[1]]-1
			iti1[end-lit1+iii[1]]+=1
			iti2[end-lit2+iii[2]]+=1
			newnewterm=deepcopy(t) 
			nt1=Ten(t1.x[iti1...],deleteat!(deepcopy(t1.indices),iii[1]))
			nt2=Ten(t2.x[iti2...],deleteat!(deepcopy(t2.indices),iii[2]))
			newnewterm[ti1]=nt1;newnewterm[ti2]=nt2
			push!(at,newnewterm)
		end
		return at
	end
	return Term[t]
end
sumconv(t::Term)=sumconv!(deepcopy(t))
function sumconv(tt::Array{Term})
	nat=Term[]
	for t in tt
		pushall!(nat,sumconv(t))
	end
	nat
end
function sumconv(t::Ten)
	if isa(t.indices,Array)&&isa(t.x,Array)
		iii=duplicates(t.indices)
		if iii!=0
			ni=length(t.indices)
			si=size(t.x)
			idif=length(si)-ni
			slind=Any[]
			for n in 1-idif:ni
				if n==iii[1]
					push!(slind,1)
				elseif n==iii[2]
					push!(slind,1)
				else
					push!(slind,:)
				end
			end
			nex=Ten(t.x[slind...],deleteat!(deepcopy(t.indices),iii))
			for s1 in 1:si[iii[1]+idif]-1
				slind[iii[1]+idif]+=1
				slind[iii[2]+idif]+=1
				nex=nex+Ten(t.x[slind...],deleteat!(deepcopy(t.indices),iii))
			end
			return nex
		end
	end
	t
end
function indsmatch(inds1,inds2)
	l1=length(inds1)
	if l1==length(inds2)
		for i in 1:l1
			if !isa(inds1[i],typeof(inds2[i]))
				return false
			end
		end
		return true
	end
	false
end
function sumlify(tt::Array{Term})
	tt=deepcopy(tt)
	ntt=Term[]
	while !isempty(tt)
		tt1=shift!(tt)
		tensi=indsin(tt1,Ten)
		if length(tensi)==1&&allnum(tt1[1:tensi[1]-1])&&allnum(tt1[tensi[1]+1:end])&&isa(tt1[tensi[1]].x,Array)
			nt=tt1[tensi[1]]
			num=1
			for n in [tt1[1:tensi[1]-1];tt1[tensi[1]+1:end]]
				num=num*n
			end
			nt.x=simplify(num*convert(Array{Any},nt.x))
			del=Integer[]
			for ti2 in 1:length(tt)
				tt2=tt[ti2]
				tensi2=indsin(tt2,Ten)
				if length(tensi2)==1&&isa(tt2[tensi2[1]].x,Array)&&size(nt.x)==size(tt[ti2][tensi2[1]].x)&&nt.indices==tt[ti2][tensi2[1]].indices&&allnum(tt2[1:tensi2[1]-1])&&allnum(tt2[tensi2[1]+1:end])
					t2=tt[ti2][tensi2[1]]
					nums=1
					for n in [tt2[1:tensi2[1]-1];tt2[tensi2[1]+1:end]]
						nums=nums*n
					end
					nt.x=simplify(nt.x+nums*t2.x)
					push!(del,ti2)
				end
			end
			deleteat!(tt,del)
			push!(ntt,Factor[nt])
#		elseif length(tensi)>1
#
		else
			push!(ntt,tt1)
		end
	end
	ntt
end
function untensify!(tt::Array{Term})
	del=Integer[]
	for ti in 1:length(tt)
		for fi in 1:length(tt[ti])
			if isa(tt[ti][fi],Ten)
				t=tt[ti][fi]
				if isempty(t.indices)&&isa(t.x,Number)
					tt[ti][fi]=t.x
				elseif isa(t.x,Array)
					if t.x==zeros(size(t.x))
						push!(del,ti)
					end
					s=size(t.x)
					if in(1,s)&&length(s)>length(t.indices)
						ns=Integer[]
						for ts in s
							if ts!=1
								push!(ns,ts)
							end
						end
						t.x=reshape(t.x,ns...)
					end
					s=size(t.x)
					if length(s)==1&&isa(t.indices[1],Number)
						tt[ti][fi]=t.x[t.indices[1]]
					elseif length(s)==length(t.indices)&&allnum(t.indices)
						tt[ti][fi]=t.x[t.indices...]
					end
				end
			end
		end
	end
	deleteat!(tt,del)
	tt
end
function simplify(ex::Expression,typ=Type{Ten})
	nat=Term[]
	for t in ex
		pushall!(nat,sumconv(t))
	end
	nnat=sumconv(nat)
	while nnat!=nat
		nat=nnat;nnat=sumconv(nnat)
	end
	for n in 1:length(nnat)
		for m in 1:length(nnat[n])
			nnat[n][m]=simplify(nnat[n][m])
		end
	end
	untensify!(nnat)
	nnat=sumlify(nnat)
	return Expression(nnat)
end
function simplify(t::Ten)
	if isa(t.x,Array)
		if t.x==zeros(size(t.x))
			return 0
		end
	end	
	if duplicates(t.indices)!=0&&isa(t.x,Array)
		nt=sumconv(t)
		for i in 1:30
			if nt==t
				break
			else
				t=nt
			end
			if isa(t,Ten)&&duplicates(t.indices)!=0
				nt=sumconv(t)
			else
				break
			end
		end
		return simplify(t)
	elseif isempty(t.indices)&&!isa(t.x,Array)
		return t.x
	elseif isa(t.x,Array)
		if isa(t.indices,Number)&&length(size(t.x))==1
			return t.x[t.indices]
		elseif isa(t.indices,Array)
			if allnum(t.indices)#&&length(size(t.x))==length(t.indices)
				return t.x[t.indices...]
			end
			if isa(t.indices[end],Number)
				s=size(t.x)
				i=Any[]
				for l in 1:length(s)-1
					push!(i,:)
				end
				push!(i,t.indices[end])
				return Ten(t.x[i...],t.indices[1:end-1])
			end
		end
	end
	t
end
type Alt<:AbstractTensor #Alternating tensor
	x
	indices::Array{Any}
end
Alt(inds::Array)=Alt(maltx(length(inds)),inds)
function maltx(r)
	x=zeros(fill!(zeros(Integer,r),r)...)
	i=collect(1:r)
	for ip in permutations(i)
		x[ip...]=permsign(ip)
	end
	x
end
function print(io::IO,a::Alt)
	print(io,"ϵ($(a.indices))")
end
function permsign(p)
	n = length(p)
	A = zeros(n,n)
	if minimum(p)==0
	p+=1
	end
	for i in 1:n
		try
			A[i,p[i]] = 1
		catch er
			error("Correct the indices of the Alt tensor: $p")
		end
	end
	det(A)
end
function simplify(a::Alt)
	if isa(a.indices,Array)
		if allnum(a.indices)
			return permsign(a.indices)
		elseif duplicates(a.indices)!=0
			return 0
		end
	end
	return a
end
simplify(a::Alt,t::Type)=simplify(a)
type Bra<:Component
	x
end

type Ket<:Component
	x
end
type BraKet<:Component
	x
	y
	o #middle element
end
BraKet(x,y)=BraKet(x,y,1)
function print(io::IO,bk::BraKet)
	print(io,'⟨')
	print(io,bk.x)
	print(io,'|')
	if bk.o!=1
		print(io,"$(bk.o)|")
	end
	print(io,bk.y)
	print(io,'⟩')
end

type Delta<:AbstractTensor
	x
	y
end
function simplify(d::Delta)
	if d.x==d.y
		return 1
	elseif isa(d.x,Number)&&isa(d.y,Number)
		return 0
	end
	return d
end
function print(io::IO,d::Delta)
	print(io,"δ($(d.x),$(d.y))")
end

type D<:NonAbelian
	x
end
function print(io::IO,d::D)
	if isa(d.x,Symbol)
		print(io,"d$(d.x)")
	else
		print(io,"d($(d.x))")
	end
end

type TensorProduct <: AbstractTensor
	tensors
end
function ⊗(tp1::TensorProduct,tp2::TensorProduct)
	tp=deepcopy(tp1)
	for t in tp2.tensors
		push!(tp.tensors,t)
	end
	tp
end
⊗(tp::TensorProduct,t)=begin;tp=deepcopy(tp);push!(tp.tensors,t);tp;end
⊗(t,tp::TensorProduct)=begin;tp=deepcopy(tp);unshift!(tp.tensors,t);tp;end
⊗(t1,t2)=TensorProduct([t1,t2])
function print(io::IO,tp::TensorProduct) 
	print(io,"$(tp.tensors[1]) ⊗")
	for i in 2:length(tp.tensors)-1
		print(io," $(tp.tensors[i]) ⊗")
	end
	print(io," $(tp.tensors[end])")
end
type Wedge <: AbstractTensor
	tensors::Term
end
function ∧(tp1::Wedge,tp2::Wedge)
	tp=deepcopy(tp1)
	for t in tp2.tensors
		push!(tp.tensors,t)
	end
	tp
end
∧(tp::Wedge,t)=begin;tp=deepcopy(tp);push!(tp.tensors,t);tp;end
∧(t,tp::Wedge)=begin;tp=deepcopy(tp);unshift!(tp.tensors,t);tp;end
∧(t1,t2)=Wedge([t1,t2])
function print(io::IO,tp::Wedge)
	print(io,"$(tp.tensors[1]) ∧")
	for i in 2:length(tp.tensors)-1
		print(io," $(tp.tensors[i]) ∧")
	end
	print(io," $(tp.tensors[end])")
end

type Form<:Component
	x
	T
	w
	p
end
type Trace<:Component
	x
end
type Commutator<:Component
	x
	y
end
type Transpose<:Component
	x
end
function simplify(t::Transpose)
	if isa(t.x,Ten)&&isa(t.x.x,Matrix)&&length(t.x.indices)==2
		return Ten(t.x.x',[t.x.indices[2],t.x.indices[1]])
	end
	t
end

