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
type Ten<:AbstractTensor
	x
	indices
end
function print(io::IO,t::Ten)
	print(io,"$(t.x)($(t.indices))")
end
abstract Index
function simplify(ex,t=Type{Ten})
	inds=indsin(ex,Ten)
	for te in 1:length(inds)
		it1=inds[te][2] 
		termi=it1[te][1]
		indices=Array[]
		for i in it1
			push!(indices,Any[])
			pushall!(indices[i],ex[termi][i].indices)
		end
		ii=[0,0]
		for i in 1:length(indices)
			b=false
			for j in 1:length(indices)
				if i==j
					continue
				elseif indices[i]==indices[j]
					ii[1]=it1[i]
					ii[2]=it1[j]
					b=true
					break
				end
			end
			if b
				break
			end
		end
		if ii[1]!=0
			if isa(ex[termi][ii[1]].indices,Array)
				#handle
			else
				l=length(ex[termi][ii[1]].x)
				nx=0
				for i in 1:l
					nx+=ex[termi][ii[1]].x[i]*ex[termi][ii[2]].x[i]
					#println(nx)
				end
				ex[termi][ii[1]]=nx
				ex[termi][ii[2]]=1
				ex=simplify(ex)
			end
		end
	end
	return ex
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

