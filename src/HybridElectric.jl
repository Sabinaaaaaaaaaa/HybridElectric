module HybridElectric

## Package imports
#==========================================================================================#
using Base.Math
using StaticArrays
using CoordinateTransformations
using Rotations
using Roots 
using SplitApplyCombine
using Plots
using DelimitedFiles
using Interpolations


## Types
#==========================================================================================#
include("batterystorage.jl") 

#==========================================================================================#
include("combustion.jl") 
import .combustion: enginecombustion
export enginecombustion

#==========================================================================================#
include("electricmotor.jl") 
import .electricmotor: emotor
export emotor

#==========================================================================================#
include("powermanagement.jl") 
import .powermanagement: powerdistrubution
export powerdistrubution

#==========================================================================================#
include("sizing.jl") 
import .sizing: fuelreq, totalmass
export fuelreq, totalmass

#==========================================================================================#
include("airfoildata.jl") 
import .airfoildata: calculateclcd
export calculateclcd


#==========================================================================================#
include("BEMT.jl") 
import .BEMT: BEMT
export BEMT

#==========================================================================================#

end


