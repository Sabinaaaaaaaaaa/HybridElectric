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
include("initialisation.jl")
export Aircraft, Propulsion, MissionSegment, MissionState

#==========================================================================================#
include("aerodynamics.jl") 
export dragforce, atmosphere

#==========================================================================================#
include("electricpropulsion.jl") 
export batterypower, stateofcharge, total_battery_energycapacity, component_weight
                    
#==========================================================================================#
include("BEMT.jl") 
#import .BEMT: BEMT
export BEMT

#==========================================================================================#
include("mission.jl")
export runmission

#==========================================================================================#
include("fuelpropulsion.jl") 
export fuelconsumption

#==========================================================================================#
include("power.jl") 
export powersplit, powerrequired

#==========================================================================================#
include("weightsizing.jl")
export batteryweightsizing


end
