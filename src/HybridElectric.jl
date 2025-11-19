module HybridElectric

## Package imports
#==========================================================================================#
using DelimitedFiles
using Interpolations

#==========================================================================================#
include("airfoildata.jl") 
#import .airfoildata: calculateclcd
export calculateclcd


#==========================================================================================#
include("BEMT.jl") 
#import .BEMT: BEMT
export BEMT

#==========================================================================================#

end


