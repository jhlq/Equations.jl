using Equations
using Test

print("Running test # ")
i=1
print(i," ")
include("commonTests.jl")
i+=1
print(i," ")
include("DivTests.jl")
i+=1
print(i," ")
include("equationsTests.jl")
i+=1
print(i," ")
include("matchersTests.jl")
i+=1
print(i," ")
include("PowTests.jl")
i+=1
print(i," ")
include("DerTests.jl")
i+=1
print(i," ")
include("VecTests.jl")
i+=1
print(i," ")
include("plasmaTests.jl")
i+=1
print(i," ")
include("LogTests.jl")
i+=1
print(i," ")
include("TenTests.jl")
i+=1
print(i," ")
include("gravity.jl")
i+=1
print(i," ")
include("readmeTests.jl")
i+=1
print(i," ")
include("SqrtTests.jl")
i+=1
print(i," ")
include("examplesTests.jl")
i+=1
println(i," ")
include("formulariesTests.jl")
