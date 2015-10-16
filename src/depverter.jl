function skipto(str,char)
	for ci in 1:length(str)
		#print(str[ci])
		if str[ci]==char
			return ci
		end
	end
	return 0
end
function depvert(fname)
	text=readall("$fname.jl")
	deploc=search(text,"Union(")
	while !isempty(collect(deploc))
		depend=skipto(text[deploc[end]:end],')')
		#println(depend,text,deploc)
		text=text[1:deploc[end]-1]*"{"*text[deploc[end]+1:end]
		text=text[1:deploc[end]-2+depend]*"}"*text[deploc[end]+depend:end]
		deploc=search(text[deploc[end]+depend:end],"Union(")+deploc[end]+depend-1
	end
	f=open("$fname.jl","w")
	write(f,text)
	close(f)
end
