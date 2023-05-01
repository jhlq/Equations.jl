import LinearAlgebra.det, Base.inv

abstract type AbstractTensor<:NonAbelian end
mutable struct Ten<:AbstractTensor
	x
	indices::Array{Any}
end
#@delegate Ten.x [getindex, setindex!, iterate, length, size]
function Ten(x,i::Union{Array,Factor})
	if isa(x,Array)&&!isa(x,Array{Any})
		x=convert(Array{Any},x)
	end
	if !isa(i,Array)
		i=Any[i]
	elseif !isa(i,Array{Any})
		i=convert(Array{Any},i)
	end
	Ten(x,i)
end
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
function alltyp(a::Array,typ)
	for n in a
		if !isa(n,typ)
			return false
		end
	end
	return true
end
mutable struct Tensor<:AbstractTensor
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
abstract type AbstractIndex<:Component end
mutable struct Up<:AbstractIndex
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
			elseif arr[aa]==arr[bb]&&!isa(arr[aa],Number)
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
			if arr1[aa]==arr2[bb]&&!isa(arr1[aa],Number)
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
function dimsmatch(t::Ten)
	dims=length(t.indices)
	if isa(t.x,Array)
		return dims==length(size(t.x))
	elseif isa(t.x,Fun)
		return dims==length(size(sample(t.x)))
	end
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
		t1=t[ti1];t2=t[ti2]
		iii=iiii[2]
		if !(isa(t1.x,Union{Array,Fun})&&isa(t2.x,Union{Array,Fun}))||!dimsmatch(t1)||!dimsmatch(t2)
			return Term[t]
		end
		t1f=isa(t1.x,Fun)
		t2f=isa(t2.x,Fun)
		if t1f
			if isa(t1.x.x,Symbol)
				ra=rand(1)[1]
			else
				ra=rand(length(t1.x.x))
			end
			st1=size(t1.x.y(ra))
		else
			st1=size(t1.x)
		end
		if t2f
			if isa(t2.x.x,Symbol)
				ra=rand(1)[1]
			else
				ra=rand(length(t2.x.x))
			end
			st2=size(t2.x.y(ra))
		else
			st2=size(t2.x)
		end
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
		if t1f
			newinds=deepcopy(t1.indices)
			newinds[iii[1]]=1
			nt1=Ten(t1.x,newinds)
		else
			nt1=Ten(t1.x[iti1...],deleteat!(deepcopy(t1.indices),iii[1]))
		end
		if t2f
			newinds=deepcopy(t2.indices)
			newinds[iii[2]]=1
			nt2=Ten(t2.x,newinds)
		else
			 nt2=Ten(t2.x[iti2...],deleteat!(deepcopy(t2.indices),iii[2]))
		end
		newterm[ti1]=nt1;newterm[ti2]=nt2
		at=Term[newterm]
		for di1 in 1:st1[end-lit1+iii[1]]-1
			iti1[end-lit1+iii[1]]+=1
			iti2[end-lit2+iii[2]]+=1
			newnewterm=deepcopy(t)
			if t1f
				newinds=deepcopy(t1.indices)
				newinds[iii[1]]=iti1[end-lit1+iii[1]]
				nt1=Ten(t1.x,newinds)
			else
				nt1=Ten(t1.x[iti1...],deleteat!(deepcopy(t1.indices),iii[1]))
			end
			if t2f
				newinds=deepcopy(t2.indices)
				newinds[iii[2]]=iti2[end-lit2+iii[2]]
				nt2=Ten(t2.x,newinds)
			else
				nt2=Ten(t2.x[iti2...],deleteat!(deepcopy(t2.indices),iii[2]))
			end
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
	if isa(t.indices,Array)&&isa(t.x,Array)&&length(t.indices)==length(size(t.x))
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
		tt1=popfirst!(tt)
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
					if length(s)==1&&length(t.indices)==1&&isa(t.indices[1],Number)
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
function simplify(ex::Expression,typ::Type{Ten})
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
	#check each tensor, stride and break on nonabelian, then do tensor multiplication
	nnnat=nnat
	dofirst=true
	nit=0
	while nnnat!=nnat||dofirst
		dofirst=false
		nnat=nnnat
		nnnat=Term[]
		for ter in nnat
			foundT1=false
			foundT2=false
			tenprodded=false
			nfacs=Factor[]
			T1i=0
			for faci in 1:length(ter)
				skipfac=false
				fac=ter[faci]
				if !foundT1
					if isa(fac,Ten)&&isa(fac.x,Array)
						foundT1=true
						T1i=faci
						skipfac=true
					end
				elseif !foundT2
					if isa(fac,Ten)&&isa(fac.x,Array)
						foundT2=true
						skipfac=true
						T1=ter[T1i]
						#=
						T1l=length(T1.x)
						T2l=length(fac.x)
						newm=Array{Any,2}(undef,T1l,T2l)
						for i in 1:T1l
							for j in 1:T2l
								newm[i,j]=T1.x[i]*fac.x[j]
							end
						end
						push!(nfacs,Ten(newm,[T1.indices[1],fac.indices[1]]))
						=#
						nind=Any[]
						pushall!(nind,T1.indices)
						pushall!(nind,fac.indices)
						sr1=size(T1.x)
						sr1l=length(sr1)
						sr2=size(fac.x)
						td=Int64[]
						for i in sr1
							push!(td,i)
						end
						for i in sr2
							push!(td,i)
						end
						newm=Array{Any}(undef,td...)
						for k in Iterators.product(Base.OneTo.(td)...)
							newm[k...]=T1.x[k[1:sr1l]...]*fac.x[k[sr1l+1:end]...]
						end
						push!(nfacs,Ten(newm,nind))
						tenprodded=true
					elseif isa(fac,NonAbelian)
						break
					end
				end
				if !skipfac
					push!(nfacs,fac)
				end
			end
			if tenprodded
				push!(nnnat,nfacs)
			else
				push!(nnnat,ter)
			end
		end
		nit+=1
		if nit>90
			@warn("Stuck in Tensor multiplication loop")
			break
		end
	end
	return Expression(nnat)
end
function simplify(t::Ten)
	t=deepcopy(t)
	if isa(t.x,Union{Component,Expression})
		t.x=simplify(t.x)
	end
	if isa(t.x,Array)
		if t.x==zeros(size(t.x))
			return 0
		end
		if !isa(t.x,Array{Any})
			t.x=convert(Array{Any},t.x)
		end
		for si in 1:length(t.x)
			t.x[si]=simplify(t.x[si])
		end
		
	end	
	if duplicates(t.indices)!=0&&isa(t.x,Array)&&length(t.indices)==length(size(t.x)) #or Fun, TODO. Is it really necessary? Might just convoliute the expression
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
		if length(size(t.x))==length(t.indices)
			if length(t.indices)==1&&isa(t.indices[1],Number)
				return t.x[t.indices[1]]
			else#if isa(t.indices,Array)
				if allnum(t.indices)&&dimsmatch(t)
					return t.x[t.indices...]
				end
				for tindi in 1:length(t.indices)
					if isa(t.indices[tindi],Number)
						s=size(t.x)
						i=Any[]
						for l in 1:length(s)
							if l==tindi
								push!(i,t.indices[tindi])
							else
								push!(i,:)
							end
						end
						ninds=Any[]
						for tindii in 1:length(t.indices)
							if tindii!=tindi
								push!(ninds,t.indices[tindii])
							end
						end
						return Ten(t.x[i...],ninds)
					end
				end
				#=if isa(t.indices[end],Number)
					if length(t.indices)>1
						s=size(t.x)
						i=Any[]
						for l in 1:length(s)-1
							push!(i,:)
						end
						push!(i,t.indices[end])
						return Ten(t.x[i...],t.indices[1:end-1])
					elseif !isa(t.x[t.indices[end]],Array)&&!isa(t.x[t.indices[end]],Fun)
						return t.x[t.indices[end]]
					end
				end=#
			end
		elseif isa(t.x,Vector)
			if isa(t.indices[1],Number)
				t.x=t.x[t.indices[1]]
				popfirst!(t.indices)
			elseif isa(t.x[1],Array)
				sp=size(t.x[1])
				samesize=true
				nelem=length(t.x)
				for i in 2:nelem
					if sp!=size(t.x[i])
						samesize=false
					end
				end
				if samesize
					spl=length(sp)
					td=Int64[nelem]
					for i in sp
						push!(td,i)
					end
					newm=Array{Any}(undef,td...)
					for k in Iterators.product(Base.OneTo.(td)...)
						newm[k...]=t.x[k[1]][k[2:end]...]
					end
					t.x=newm
				end
			end
		end
	end
	t
end
mutable struct Alt<:AbstractTensor #Alternating tensor
	x
	indices::Array{Any}
end
Alt(inds::Array)=Alt(maltx(length(inds)),inds)
Alt(inds...)=Alt(Any[inds...])
dimsmatch(a::Alt)=true
function maltx(r)
	x=zeros(fill!(zeros(Integer,r),r)...)
	i=collect(1:r)
	for ip in permutations(i)
		x[ip...]=permsign(ip)
	end
	x
end
#function print(io::IO,a::Alt)
#	print(io,"ϵ($(a.indices))")
#end
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
mutable struct Bra<:Component
	x
end

mutable struct Ket<:Component
	x
end
mutable struct BraKet<:Component
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

mutable struct Delta<:AbstractTensor
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

mutable struct D<:NonAbelian
	x
end
function print(io::IO,d::D)
	if isa(d.x,Symbol)
		print(io,"d$(d.x)")
	else
		print(io,"d($(d.x))")
	end
end

mutable struct TensorProduct <: AbstractTensor
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
mutable struct Wedge <: AbstractTensor
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

mutable struct Form<:Component
	x
	T
	w
	p
end
mutable struct Trace<:Component
	x
end
mutable struct Commutator<:Component
	x
	y
end
mutable struct Transp<:Component
	x
end
function simplify(t::Transp)
	t=Transp(simplify(t.x))
	if isa(t.x,Ten)&&isa(t.x.x,Matrix)&&length(t.x.indices)==2&&allnum(t.x.x)
		return Ten(convert(Array{Any},t.x.x'),[t.x.indices[2],t.x.indices[1]]) #t.x.indices) #[t.x.indices[2],t.x.indices[1]]) #switching indices is inverse of transposing. But if we switch the indices we can sum transposed matrix with its equivalent
	end
	if isa(t.x,Matrix)&&allnum(t.x)
		return convert(Array{Any},t.x')
	end
	return t
end
mutable struct Inv<:Component
	x
end
inv(ex::Ex)=Inv(ex)
function simplify(c::Inv)
	c=Inv(simplify(c.x))
	if isa(c.x,Matrix)
		for cxc in c.x
			if !isa(cxc,Number)
				return c
			end
		end
		return inv(c.x)
	end
	if isa(c.x,Ten)
		if isa(c.x.x,Matrix)&&allnum(c.x.x)
			return Ten(inv(convert(Array{Number},c.x.x)),c.x.indices)
		end
	end
	return c
end
