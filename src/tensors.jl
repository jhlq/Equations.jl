abstract AbstractTensor<:NonAbelian
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
function allnum(a::Array)
	for n in a
		if !isa(n,Number)
			return false
		end
	end
	return true
end
type Ten<:AbstractTensor
	x
	indices::Array{Any}
end
Ten(x,s::Symbol)=Ten(x,[s])
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
sumconv(ex)=simplify(ex,Ten)
function sumconv_dep(ex)
	inds=indsin(ex,Ten)
	#println(inds)
	for te in 1:length(inds)
		it1=inds[te][2] 
		termi=inds[te][1]
		indices=Array[]
		for i in 1:length(it1)
			push!(indices,Any[])
			pushall!(indices[i],ex[termi][it1[i]].indices)
		end
		ii=[0,0]
		iii=[1,1]
		for i in 1:length(indices)
		for i2 in 1:length(indices[i])
			b=false
			for j in 1:length(indices)
			for j2 in 1:length(indices[j])
				if i==j&&i2==j2
					continue
				elseif indices[i][i2]==indices[j][j2]
					ii[1]=it1[i]
					ii[2]=it1[j]
					iii[1]=i2
					iii[2]=j2
					b=true
					break
				end
			end
			end
			if b
				break
			end
		end
		end
#		println(indices,ii,iii)
		if ii[1]!=0
#		println(ex[termi][ii[1]])
#		println(ex[termi][ii[2]])
			if isa(ex[termi][ii[1]].x,Array)&&isa(ex[termi][ii[2]].x,Array)
				nex=0
				for t in 1:termi-1
					#println(ex[termi-t])
					nex=expression(ex[termi-t])+nex
				end
				s1=size(ex[termi][ii[1]].x)
				s2=size(ex[termi][ii[2]].x)
				xxi1=Any[]
				xxi2=Any[]
				for si in 1:length(s1)
					push!(xxi1,:)
				end
				xxi1[end]=0
				for si in 1:length(s2)
					push!(xxi2,:)
				end
				xxi2[end]=0
				nind1=deepcopy(indices[ii[1]])
				deleteat!(nind1,iii[1])
				nind2=deepcopy(indices[ii[2]])
				deleteat!(nind2,iii[2])
				for xi in 1:s1[end]
					nt=deepcopy(ex[termi])
					xxi1[end]=xi
					xxi2[end]=xi
					if isempty(nind1)
						nt[ii[1]]=nt[ii[1]].x[xxi1...]
					else
						nt[ii[1]]=Ten(nt[ii[1]].x[xxi1...],nind1)
					end
					if isempty(nind2)
						nt[ii[2]]=nt[ii[2]].x[xxi2...]
					else
						nt[ii[2]]=Ten(nt[ii[2]].x[xxi2...],nind2)
					end
					nex=nex+expression(nt)
				end
				for t in termi+1:length(ex)
					nex=nex+expression(ex[t])
				end
				return simplify(nex)
			end
		end
	end
	return ex
end
function sumconv!(t::Term)
	inds=indsin(t,Ten)
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
function sumconv(t::Ten)
	if isa(t.indices,Array)
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
function simplify(ex::Expression,t=Type{Ten})
	nat=Term[]
	for t in ex
		pushall!(nat,sumconv(t))
	end
	return Expression(nat)
end
function simplify(t::Ten)
	if duplicates(t.indices)!=0
		for i in 1:30
			nt=sumconv(t)
			if nt==t
				break
			else
				t=nt
			end
		end
		return simplify(t)
	elseif isempty(t.indices)&&!isa(t.x,Array)
		return t.x
	elseif isa(t.x,Array)
		if isa(t.indices,Number)
			return t.x[t.indices]
		elseif isa(t.indices,Array)
			if allnum(t.indices)
				return t.x[t.indices...]
			elseif isa(t.indices[end],Number)
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
	x::Array{Any}
end
function print(io::IO,a::Alt)
	print(io,"ϵ($(a.x))")
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
	if isa(a.x,Array)
		if allnum(a.x)
			return permsign(a.x)
		elseif duplicates(a.x)!=0
			return 0
		end
	end
	return a
end
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
function print(io::IO,tp::TensorProduct) #rewrite with macro
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

