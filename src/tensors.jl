import LinearAlgebra.det, Base.inv

abstract type AbstractTensor<:NonAbelian end
mutable struct Ten<:AbstractTensor
	x
	indices::Array{Any}
	td
end
@delegate Ten.x [getindex, setindex!, iterate, length, size]
function Ten(x,i::Union{Array,Factor},td=1)
	if isa(x,Array)&&!isa(x,Array{Any})
		x=convert(Array{Any},x)
	end
	if !isa(i,Array)
		i=Any[i]
	elseif !isa(i,Array{Any})
		i=convert(Array{Any},i)
	end
	Ten(x,i,td)
end
function applytd!(t::Ten)
	if t.td!=1&&dimsmatch(t)
		if isa(t.td,Array)
			tddims=length(size(t.td))
			ts=size(t.x)
			its=Int64[]
			for i in ts
				push!(its,i)
			end
			for k in Iterators.product(Base.OneTo.(its)...)
				t[k...]=simplify(t.td[k[1:tddims]...]*t[k...])
			end
		else 
			for txi in 1:length(t.x)
				t.x[txi]=simplify(t.td*t.x[txi])
			end
		end
		t.td=1
	end
	t
end
function allnum(a::Array)
	if isempty(a)
		return false
	end
	for n in a
		if !isa(n,Number)
			return false
		end
	end
	return true
end
function alltyp(a::Array,typ)
	if isempty(a)
		return false
	end
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
sumconv(a)=simplify(a)
function sumconv(ex::Expression)
	nat=Term[]
	for t in ex
		pushall!(nat,sumconv(t))
	end
	Expression(nat)
end
function dimsmatch(t::Ten,allowfun=false)
	dims=length(t.indices)
	fdims=0
	if allowfun
		f=fetch(t.x,Fun)
		if f!=false
			fdims=length(size(sample(f)))
		end
	end
	if isa(t.x,Array)
		return dims==length(size(t.x))+fdims
	elseif isa(t.x,Fun)&&allowfun
		return dims==fdims
	end
	return false
end
function sumconv!(t::Term)
	inds=indsin(t,Union{Ten,Alt})
	for i in inds
		t[i]=sumconv(t[i])
	end
	inds=indsin(t,Union{Ten,Alt})
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
		arrhasfun=false
		if !isa(t1.x,Fun)&&has(t1.x,Fun)
			arrhasfun=true
		elseif !isa(t2.x,Fun)&&has(t2.x,Fun)
			arrhasfun=true
		end
		if !(isa(t1.x,Union{Array,Fun})&&isa(t2.x,Union{Array,Fun}))||!dimsmatch(t1,true)||!dimsmatch(t2,true)||arrhasfun
			return Term[t]
		end
		t1f=isa(t1.x,Fun)
		t2f=isa(t2.x,Fun)
		if t1f
			st1=size(sample(t1.x))
		else
			st1=size(t1.x)
		end
		if t2f
			st2=size(sample(t2.x))
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
			nt1=Ten(t1.x,newinds,t1.td)
		else
			nt1=Ten(t1.x[iti1...],deleteat!(deepcopy(t1.indices),iii[1]),t1.td)
		end
		nt1.td=t1.td
		if t2f
			newinds=deepcopy(t2.indices)
			newinds[iii[2]]=1
			nt2=Ten(t2.x,newinds,t2.td)
		else
			 nt2=Ten(t2.x[iti2...],deleteat!(deepcopy(t2.indices),iii[2]),t2.td)
		end
		nt2.td=t2.td
		newterm[ti1]=nt1;newterm[ti2]=nt2
		at=Term[newterm]
		for di1 in 1:st1[end-lit1+iii[1]]-1
			iti1[end-lit1+iii[1]]+=1
			iti2[end-lit2+iii[2]]+=1
			newnewterm=deepcopy(t)
			if t1f
				newinds=deepcopy(t1.indices)
				newinds[iii[1]]=iti1[end-lit1+iii[1]]
				nt1=Ten(t1.x,newinds,t1.td)
			else
				nt1=Ten(t1.x[iti1...],deleteat!(deepcopy(t1.indices),iii[1]),t1.td)
			end
			nt1.td=t1.td
			if t2f
				newinds=deepcopy(t2.indices)
				newinds[iii[2]]=iti2[end-lit2+iii[2]]
				nt2=Ten(t2.x,newinds,t2.td)
			else
				nt2=Ten(t2.x[iti2...],deleteat!(deepcopy(t2.indices),iii[2]),t2.td)
			end
			nt2.td=t2.td
			newnewterm[ti1]=nt1;newnewterm[ti2]=nt2
			push!(at,newnewterm)
		end
		tex=expression(at)
		tex=simplify!(tex)
		at=terms(tex)
		if isa(at,Factor)
			at=Term[Factor[at]]
		end
		return at
	end
	return Term[t]
end
sumconv(t::Term)=sumconv!(deepcopy(t))
function sumconv!(tt::Array{Term})
	nat=Term[]
	for t in tt
		pushall!(nat,sumconv!(t))
	end
	nat
end
sumconv(tt::Array{Term})=sumconv!(deepcopy(tt))
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
			nex=Ten(t.x[slind...],deleteat!(deepcopy(t.indices),iii),t.td)
			for s1 in 1:si[iii[1]+idif]-1
				slind[iii[1]+idif]+=1
				slind[iii[2]+idif]+=1
				nex=nex+Ten(t.x[slind...],deleteat!(deepcopy(t.indices),iii),t.td)
			end
			return simplify(nex)
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
function sumlify!(tt::Array{Term})
	ntt=Term[]
	while !isempty(tt)
		tt1=popfirst!(tt)
		tensi=indsin(tt1,Ten)
		typ=N
		if length(tensi)==1&&(isempty(tt1[1:tensi[1]-1])||alltyp(tt1[1:tensi[1]-1],typ))&&(isempty(tt1[tensi[1]+1:end])||alltyp(tt1[tensi[1]+1:end],typ))&&dimsmatch(tt1[tensi[1]])
			nt=tt1[tensi[1]]
			for n in tt1[1:tensi[1]-1]
				if isa(nt.td,Array)
					for tdi in 1:length(nt.td)
						nt.td[tdi]=n*nt.td[tdi]
					end
				else
					nt.td=n * nt.td
				end
			end
			for n in tt1[tensi[1]+1:end]
				if isa(nt.td,Array)
					for tdi in 1:length(nt.td)
						nt.td[tdi]=nt.td[tdi]*n
					end
				else
					nt.td=nt.td * n
				end
			end
			nt.td=simplify(nt.td)
			if dimsmatch(nt)
				applytd!(nt)
			end
			del=Integer[]
			for ti2 in 1:length(tt)
				tt2=tt[ti2]
				tensi2=indsin(tt2,Ten)
				if length(tensi2)==1 #this can be simplified to remove the second such check
					nt2=tt[ti2][tensi2[1]]
					if isa(nt2.x,Array)&&length(nt2.indices)==length(nt.indices)&&nt2.indices!=nt.indices&&dimsmatch(nt2,false)
						allin=true
						for i in nt.indices
							if !isa(i,Symbol)
								continue
							end
							if !in(i,nt2.indices)
								allin=false
								break
							end
						end
						if allin
							nit=0
							while isa(nt,Ten)&&nt.indices!=nt2.indices
								nit+=1
								transis=Symbol[]
								transed=false
								for nti in 1:length(nt.indices)
									i=nt.indices[nti]
									if !isa(i,Symbol)||i==nt2.indices[nti]
										continue
									end
									push!(transis,i)
									for nti2 in nti+1:length(nt2.indices)
										j=nt2.indices[nti2]
										if !isa(j,Symbol)
											continue
										end
										if j==transis[1]
											push!(transis,nt.indices[nti2])
										end
										if length(transis)>1
											nt=trans(nt,transis[1],transis[2])
											transed=true
											break
										end
									end
									if transed
										break
									end
								end
								if nit>90
									@warn "Stuck in transloop.\n$(nt.indices)\n$(nt2.indices)\n"
									break
								end
							end
						end
					end
				end
				if nt==0
					break
				end
				if isa(nt,Ten)&&length(tensi2)==1&&dimsmatch(tt2[tensi2[1]])&&size(nt.x)==size(tt[ti2][tensi2[1]].x)&&nt.indices==tt[ti2][tensi2[1]].indices&&(isempty(tt2[1:tensi2[1]-1])||alltyp(tt2[1:tensi2[1]-1],typ))&&(isempty(tt2[tensi2[1]+1:end])||alltyp(tt2[tensi2[1]+1:end],typ))
					t2=tt[ti2][tensi2[1]]
					for n in tt2[1:tensi2[1]-1]
						if isa(t2.td,Array)
							for tdi in 1:length(t2.td)
								t2.td[tdi]=n*t2.td[tdi]
							end
						else
							t2.td=n * t2.td
						end
					end
					for n in tt2[tensi2[1]+1:end]
						if isa(t2.td,Array)
							for tdi in 1:length(t2.td)
								t2.td[tdi]=t2.td[tdi]*n
							end
						else
							t2.td=t2.td * n
						end
					end
					if dimsmatch(nt,false)&&dimsmatch(t2,false)
						applytd!(nt)
						applytd!(t2)
						for xi in 1:length(nt.x)
							nt.x[xi]=nt.x[xi]+t2.x[xi]
						end
					else
						if nt.td!=1||t2.td!=1
							applytd!(nt)
							applytd!(t2)
							#@warn("td+td undefined, ignoring tds: $(nt.td) and $(t2.td) of $nt and $t2.")
						end
						nt.x=simplify(nt.x+t2.x)
					end
					push!(del,ti2)
				end
			end
			deleteat!(tt,del)
			push!(ntt,Factor[nt])
		else
			push!(ntt,tt1)
		end
	end
	ntt
end
sumlify(tt::Array{Term})=sumlify!(deepcopy(tt))
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
						break
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
	nnat=sumconv!(nat) 
	nit=0
	while length(nnat)!=length(nat)
		nit+=1
		nat=nnat;nnat=sumconv!(nnat)
		if nit>90
			@warn "Stuck in sumconv loop, breaking."
			break
		end
	end
	for n in 1:length(nnat)
		for m in 1:length(nnat[n])
			nnat[n][m]=simplify!(nnat[n][m])
		end
	end
	untensify!(nnat)
	if has(nnat,Fun)
		nnat=terms(simplify!(Expression(nnat),Fun))
	end
	#check each tensor, stride and break on nonabelian, then do tensor multiplication
	nnnat=nnat
	redo=true
	nit=0
	while redo
		redo=false
		nnat=deepcopy(nnnat)
		nnnat=Term[]
		for ter in nnat
			foundT1=false
			foundT2=false
			tenprodded=false
			T1i=0
			delfac=0
			tpt="1"
			lter=length(ter)
			for facii in 1:lter
				#skipfac=false
				faci=lter+1-facii
				fac=ter[faci]
				if !foundT1
					if isa(fac,Ten)&&dimsmatch(fac,true)
						if !alltyp(fac.indices,Symbol)
							break
						end
						foundT1=true
						T1i=faci
					end
				elseif !foundT2
					if isa(fac,Ten)&&dimsmatch(fac,true)
						if !alltyp(fac.indices,Symbol)
							break
						end
						foundT2=true
						delfac=faci
						T1=fac
						T2=ter[T1i] #yes the T1 and T2 are reversed because I reversed the direction in which to tenprod
						nind=Any[]
						sr1=size(T1.x)
						sr1l=length(sr1)
						sr2=size(T2.x)
						sr2l=length(sr2)
						for i in 1:sr1l
							push!(nind,T1.indices[i])
						end
						for i in 1:sr2l
							push!(nind,T2.indices[i])
						end
						for i in sr1l+1:length(T1.indices)
							push!(nind,T1.indices[i])
						end
						for i in sr2l+1:length(T2.indices)
							push!(nind,T2.indices[i])
						end
						td=Int64[]
						for i in sr1
							push!(td,i)
						end
						for i in sr2
							push!(td,i)
						end
						if isempty(td)
							newm=simplify(T1.x*T2.x)
						else
							newm=Array{Any}(undef,td...)
							for k in Iterators.product(Base.OneTo.(td)...)
								if isempty(sr1)
									newm[k...]=simplify(T1.x*T2.x[k...])
								elseif isempty(sr2)
									newm[k...]=simplify(T1.x[k...]*T2.x)
								else
									newm[k...]=simplify(T1.x[k[1:sr1l]...]*T2.x[k[sr1l+1:end]...])
								end
							end
						end
						if isa(T1.td,Factor)
							if isa(T2.td,Factor)
								newtd=T1.td*T2.td
							else
								newtd=[]
								for ftd in T2.td
									push!(newtd,T1.td*ftd)
								end
							end
						elseif isa(T2.td,Factor)
							newtd=[]
							for Ttd in T1.td
								push!(newtd,Ttd*T2.td)
							end
						else
							sr1=size(T1.td)
							sr1l=length(sr1)
							sr2=size(T2.td)
							td=Int64[]
							for i in sr1
								push!(td,i)
							end
							for i in sr2
								push!(td,i)
							end
							newtd=Array{Any}(undef,td...)
							for k in Iterators.product(Base.OneTo.(td)...)
								newtd[k...]=simplify(T1.td[k[1:sr1l]...]*T2.td[k[sr1l+1:end]...])
							end
						end
						tpt=Ten(newm,nind,newtd)
						tenprodded=true
						break
					elseif isa(fac,NonAbelian)
						foundT1=false
						continue
					end
				end
			end
			if tenprodded
				redo=true
				ter[T1i]=tpt
				deleteat!(ter,delfac)
			end
			push!(nnnat,ter)
		end
		nit+=1
		if nit>90
			@warn("Stuck in Tensor multiplication loop with \n$nnat\nnot equal to\n$nnnat\nBreaking.")
			break
		end
	end
	nnat=sumlify!(nnnat)
	return Expression(nnat)
end
function simplify!(t::Ten)
	if t.td==0
		return 0
	end
	if isa(t.x,Adjoint)
		t.x=convert(Array,t.x)
	end
	applytd!(t)
	if isa(t.x,Union{Component,Expression})
		t.x=simplify!(t.x)
	end
	if isa(t.x,Fun)&&allnum(t.indices)
		#nf=t.x
		nf=deepcopy(t.x)
		y=t.x.y
		nf.y=a->y(a)[t.indices...]
		return nf
	end
	pti=0
	ptxl=0
	for nit in 1:90
		if isa(t.x,Array)
			txl=length(t.x)
		else
			txl=1
		end
		if t.indices==pti&&ptxl==txl
			break
		end
		if nit==90
			@warn "Stuck in Ten simplification.\n$t\nnot equal to\n$pt"
			break
		end
		pti=deepcopy(t.indices)
		if isa(t.x,Array)
			ptxl=length(t.x)
		else
			ptxl=1
		end
		if isa(t.x,Array)
			if has(t.x,Expression)
				fifun=fetch(t.x,Fun)
				if fifun!=false&&length(size(sample(fifun)))>0
					funmat=convert(Array{Any},ones(size(t.x)))
					for ltxi in 1:length(t.x)
						if isa(t.x[ltxi],Expression)
							t.x[ltxi]=simplify(t.x[ltxi])
							if isa(t.x[ltxi],Expression)&&length(t.x[ltxi])==1 #matrixmulting should never add a second term. Unless it has such an expression already...
								delfis=Int64[]
								for exi in 1:length(t.x[ltxi][1])
									if isa(t.x[ltxi][1][exi],Fun) #components containing functions causes undefined behaviour
										push!(delfis,exi)
									end
								end
								if length(delfis)>0
									fun=t.x[ltxi][1][delfis[1]]
									for funi in 2:length(delfis)
										fun=fun*t.x[ltxi][1][delfis[1]]
									end
									funmat[ltxi]=fun
									deleteat!(t.x[ltxi][1],delfis)
								end
							elseif isa(t.x[ltxi],Expression)&&length(t.x[ltxi])>1
								error("Expression $(t.x[ltxi]) contains more than one term, only implemented for the possibility of one.")
							end
						elseif isa(t.x[ltxi],Fun)
							funmat[ltxi]=t.x[ltxi]
							t.x[ltxi]=1
						end
					end
					allequal=true
					tx1=t.x[1]
					for tx in t.x
						if tx!=tx1
							allequal=false
							break
						end
					end
					if allequal
						if isa(t.td,Array)
							for i in 1:length(t.td)
								t.td[i]=simplify(tx1*t.td[i])
							end
						else
							t.td=simplify(tx1*t.td)
						end
						t=Ten(funmat,t.indices,t.td)
					else
						ptd=t.td
						t=Ten(funmat,t.indices,t.x)
						if isa(ptd,N)
							if ptd!=1
								t.td=t.td .* ptd
							end
						elseif isa(ptd,Factor)
							for tdi in 1:length(t.td)
								t.td[i]=t.td[i]*ptd
							end
						else
							t.td=tenprod(t.td,ptd)
						end
						t.td=simplify(t.td)
					end
				end
			end
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
			arr=0
			for x in t.x
				if isa(x,Array)
					arr=x
					break
				end
			end
			if arr!=0#isa(t.x[1],Array)
				dims1=size(t.x)
				dims2=size(arr) #assume all arrays are same size
				td=Int64[dims1...]
				for i in dims2
					push!(td,i)
				end
				d1l=length(dims1)
				newm=Array{Any}(undef,td...)
				for k in Iterators.product(Base.OneTo.(td)...)
					try
						newm[k...]=t.x[k[1:d1l]...][k[d1l+1:end]...]
					catch
						newm[k...]=0
					end
					#newm[k...]=t.x[k[1:d1l]...][k[d1l+1:end]...]
				end
				if !isa(newm[1],Union{Array,Fun})
					t.x=newm
					applytd!(t)
				else
					t.x=newm
				end
			end
			if length(size(t.x))==length(t.indices)
				if length(t.indices)==1&&isa(t.indices[1],Number)
					return t.x[t.indices[1]]
				else
					if allnum(t.indices)
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
							return simplify(Ten(t.x[i...],ninds,t.td))
						end
					end
				end
			else
				s=size(t.x)
				for tindi in 1:length(s)
					if isa(t.indices[tindi],Number)
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
						return simplify(Ten(t.x[i...],ninds,t.td))
					end
				end
				if has(t.indices[length(s)+1:end],Number)&&alltyp(t.x,Fun)
					for tindi in length(s)+1:length(t.indices)
						if isa(t.indices[tindi],Number)
							i=Any[]
							for l in length(s)+1:length(t.indices)
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
							for txi in 1:length(t.x)
								nf=deepcopy(t.x[txi])
								of=t.x[txi]
								nf.y=a->of.y(a)[i...]
								t.x[txi]=nf
							end
							t.indices=ninds
							return simplify(t)
						end
					end
				end
			end
		elseif isa(t.x,Fun)&&has(t.indices,Number)
			for tindi in 1:length(t.indices)
				if isa(t.indices[tindi],Number)
					i=Any[]
					for l in 1:length(t.indices)
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
					nf=deepcopy(t.x)
					of=t.x
					nf.y=a->of.y(a)[i...]
					t.x=nf
					t.indices=ninds
					return simplify(t)
				end
			end
		end
	end
	t
end
simplify(t::Ten)=simplify!(deepcopy(t))
mutable struct Alt<:AbstractTensor #Alternating tensor
	x
	indices::Array{Any}
	td
end
Alt(inds::Array)=Alt(maltx(length(inds)),inds,1)
Alt(inds...)=Alt(Any[inds...])
dimsmatch(a::Alt,b=false)=true
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
			error("Invalid indices: $p")
		end
	end
	det(A)
end
function simplify(a::Alt)
	if isa(a.indices,Array)
		if allnum(a.indices)
			#return permsign(a.indices)
			return a.x[a.indices...]
		elseif duplicates(a.indices)!=0
			return 0
		end
	end
	return a
end
simplify(a::Alt,t::Type)=simplify(a)
function asymmetrize(t::Ten,inds::Array=[])
	if isempty(inds)
		inds=deepcopy(t.indices)
	end
	pinds=collect(1:length(inds))
	iinds=Int64[]
	for i in 1:length(t.indices)
		for ii in 1:length(inds)
			if t.indices[i]==inds[ii]
				push!(iinds,i)
				break
			end
		end
	end
	nts=Expression[]
	for ppinds in permutations(pinds)
		ninds=deepcopy(t.indices)
		for i in 1:length(iinds)
			ninds[iinds[i]]=inds[ppinds[i]]
		end
		nt=Ten(t.x,ninds,t.td)
		push!(nts,permsign(ppinds)*nt)
	end
	ex=nts[2]
	for i in 3:length(nts)
		ex=ex+nts[i]
	end
	ex=ex+nts[1]
	ex=ex/factorial(length(inds))
	return simplify(ex)
end
mutable struct ExtD<:Component #exterior derivative
	x
	d
end
function simplify!(d::ExtD)
	d.x=simplify!(d.x)
	if isa(d.x,Fun)
		fp=a->ForwardDiff.gradient(d.x.y,a)
		nf=Fun(fp,d.x.x,d.x.pds)
		return Ten(nf,[d.d])
	end
	t=false
	if isa(d.x,Ten)
		t=d.x
	elseif isa(d.x,Expression)&&length(d.x)==1
		ti=indsin(d.x[1],Ten)
		if length(ti)==1
			t=d.x[1][ti[1]]
		end
	end
	if t!=false
		f=false
		if isa(t.x,Fun)
			f=t.x
		elseif isa(t.x,Array)&&isa(t.x[1],Fun)
			f=t.x[1]
		end
		if f!=false
			pda=[]
			if isa(f.x,Symbol)
				push!(pda,PD(f.x))
			else
				for x in f.x
					push!(pda,PD(x))
				end
			end
			nt=simplify(Ten(pda,d.d)*t)
			if isa(nt,Ten)
				ex=length(nt.indices)*asymmetrize(nt)
				if isa(d.x,Expression)
					d.x[1][ti[1]]=ex
					ex=d.x
				end
				return simplify(ex)
			end
		end
	end
	d
end
simplify(d::ExtD)=simplify!(deepcopy(d))
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
	tensors::Array{Any,1}#Term
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
function ∧(t1::Ten,t2::Ten)
	t3=simplify(t1*t2)
	if isa(t3,Ten)
		p=length(t1.indices)
		q=length(t2.indices)
		return simplify(factorial(p+q)/(factorial(p)*factorial(q))*asymmetrize(t3))
	end
	return Wedge([t1,t2])
end
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
mutable struct Trace<:SingleArg
	x
end
mutable struct Commutator<:Component
	x
	y
end
mutable struct Transp<:SingleArg
	x
end
function simplify!(t::Transp)
	t=Transp(simplify!(t.x))
	if isa(t.x,Ten)&&isa(t.x.x,Matrix)&&length(t.x.indices)==2&&allnum(t.x.x)
		return Ten(convert(Array{Any},t.x.x'),[t.x.indices[2],t.x.indices[1]],t.x.td) #t.x.indices) #[t.x.indices[2],t.x.indices[1]]) #switching indices is inverse of transposing. But if we switch the indices we can sum transposed matrix with its equivalent
	end
	if isa(t.x,Matrix)&&allnum(t.x)
		return convert(Array{Any},t.x')
	end
	return t
end
simplify(t::Transp)=simplify!(deepcopy(t))
mutable struct GenTrans<:Component
	x
	i1::Symbol
	i2::Symbol
end
function simplify!(t::GenTrans)
	t=GenTrans(simplify!(t.x),t.i1,t.i2)
	if t.x==0
		return 0
	end
	if isa(t.x,Ten)&&isa(t.x.x,Array)&&length(t.x.indices)==length(size(t.x.x))&&in(t.i1,t.x.indices)&&in(t.i2,t.x.indices)
		i1=indin(t.x.indices,t.i1)
		i2=indin(t.x.indices,t.i2)
		ninds=deepcopy(t.x.indices)
		ninds[i1]=t.x.indices[i2]
		ninds[i2]=t.x.indices[i1]
		oldsize=size(t.x.x)
		newsize=Int64[]
		for o in oldsize
			push!(newsize,o)
		end
		newsize[i1]=oldsize[i2]
		newsize[i2]=oldsize[i1]
		newm=Array{Any}(undef,newsize...)
		for k in Iterators.product(Base.OneTo.(newsize)...)
			oldk=Int64[]
			for ki in k
				push!(oldk,ki)
			end
			oldk[i1]=k[i2]
			oldk[i2]=k[i1]
			newm[k...]=t.x.x[oldk...]
		end
		return Ten(newm,ninds,t.x.td)
	end
	if isa(t.x,Array)
		error("No way to determine which indices to GenTrans in raw Array.") #allow Int64 indices in GenTrans?
	end
	return t
end
simplify(t::GenTrans)=simplify!(deepcopy(t))
trans(t::Ten,i::Symbol,j::Symbol)=simplify(GenTrans(t,i,j))
mutable struct Inv<:SingleArg
	x
end
inv(ex::Ex)=Inv(ex)
function simplify!(c::Inv)
	c=Inv(simplify!(c.x))
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
			if !isa(c.x.x[1],ForwardDiff.Dual)
				x=convert(Array{Number},c.x.x)
			else
				x=[c.x.x[1]]
				for i in 2:length(c.x.x)
					push!(x,c.x.x[i])
				end
			end
			return Ten(inv(x),c.x.indices,c.x.td)
			#return Ten(inv(convert(Array{Number},c.x.x)),c.x.indices,c.x.td)
		end
	end
	return c
end
simplify(c::Inv)=simplify!(deepcopy(c))
mutable struct Det<:SingleArg
	x
end
det(ex::Ex)=Det(ex)
function simplify!(c::Det)
	c=Det(simplify!(c.x))
	if isa(c.x,Matrix)
		for cxc in c.x
			if !isa(cxc,Number)
				return c
			end
		end
		return det(c.x)
	end
	if isa(c.x,Ten)
		if isa(c.x.x,Matrix)&&allnum(c.x.x)
			return Ten(Det(convert(Array{Number},c.x.x)),c.x.indices,c.x.td)
		end
	end
	return c
end
simplify(c::Det)=simplify!(deepcopy(c))
function tenprod(a1::Array,a2::Array)
	sr1=size(a1)
	sr1l=length(sr1)
	sr2=size(a2)
	td=Int64[]
	for i in sr1
		push!(td,i)
	end
	for i in sr2
		push!(td,i)
	end
	newa=Array{Any}(undef,td...)
	for k in Iterators.product(Base.OneTo.(td)...)
		newa[k...]=a1[k[1:sr1l]...]*a2[k[sr1l+1:end]...]
	end
	return newa
end
