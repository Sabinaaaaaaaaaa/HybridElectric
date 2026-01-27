# Parameters
#From Aircraft struct 
#NOTE THESE ARE KG IN STRUCTS! so convert to N
# W_empty: Aircraft empty weight N 
# W_payload: Aircraft payload weight N

#From Propulsion Struct
# e_batt: Battery energy density Wh/kg converted to J in function
# η_em: Electric motor efficiency
# η_eg: Electric generator efficiency
# η_gt: Gas turbine efficiency
# η_p: Propulsive efficiency from BEMT
# η_gb: Gearbox efficiency
# e_f: Energy density of aviation fuel Wh/kg converted to J in function

# E_0total: Total input energy J
# LD: Lift-to-drag ratio
# g: Acceleration due to gravity m/s²
# ϕ: Hybridization ratio

#parameter sweep: ϕ, LD, e_batt, W_empty , W_payload


function Range_parallel(Aircraft, Propulsion, E_0total, ϕ, LD, g; e_batt_Whkg = Propulsion.specificenergy, W_empty_override = nothing, W_payload_override = nothing)
    # allow sweeping weights without rebuilding structs
    W_empty   = isnothing(W_empty_override)   ? Aircraft.W_empty   : W_empty_override
    W_payload = isnothing(W_payload_override) ? Aircraft.W_payload : W_payload_override

    W_empty   *= g
    W_payload *= g
    
    η_em= Propulsion.η_motor
    η_p =Propulsion.η_propulsive_efficiency
    η_gt= Propulsion.η_gas_turbine_efficiency
    η_gb = Propulsion.η_gearbox_efficiency
    e_f = Propulsion.energy_density_fuel * 3600.0 #in J
    e_batt = e_batt_Whkg*3600 #Wh/kg to J/kg
    numerator   = W_empty + W_payload + (E_0total *g /e_batt)*( ϕ/η_em + (e_batt*(1-ϕ))/(e_f*η_gt) )
    denominator = W_empty + W_payload + (g*ϕ*E_0total)/(e_batt*η_em)
    Range = η_gt * η_gb * η_p * (LD)  *  (1 + ϕ/(1-ϕ) )* (e_f/g) * log( numerator/denominator)
    return Range #in metres
end


function Range_series(Aircraft, Propulsion, E_0total, ϕ, LD, g; e_batt_Whkg = Propulsion.specificenergy, W_empty_override = nothing, W_payload_override = nothing)
    # allow sweeping weights without rebuilding structs
    W_empty   = isnothing(W_empty_override)   ? Aircraft.W_empty   : W_empty_override
    W_payload = isnothing(W_payload_override) ? Aircraft.W_payload : W_payload_override

    W_empty   *= g
    W_payload *= g
    η_em= Propulsion.η_motor
    η_p =Propulsion.η_propulsive_efficiency
    η_gt= Propulsion.η_gas_turbine_efficiency
    η_gb = Propulsion.η_gearbox_efficiency
    η_eg = Propulsion.η_electric_generator_efficiency
    e_f = Propulsion.energy_density_fuel * 3600.0 #in J
    e_batt = e_batt_Whkg*3600 #Wh/kg to J/kg
     numerator   = W_empty + W_payload + (E_0total *g /e_batt)*( ϕ + (e_batt*(1-ϕ))/(e_f*η_gt*η_eg) )
     denominator = W_empty + W_payload + (g*ϕ*E_0total)/(e_batt)
     Range = η_gt * η_eg *η_em * η_gb * η_p * (LD)  *  (1 + ϕ/(1-ϕ) )* (e_f/g) * log( numerator/denominator)
     return Range
 end



 #coding notes
#  function Range_parallel(ac::Aircraft, pr::Propulsion, E0, ϕ;
#                         energy_density_fuel_Whkg=11900.0,
#                         gas_turbine_efficiency=0.35,
#                         gearbox_efficiency=0.95,
#                         propulsive_efficiency=0.8,
#                         LD=12.0,
#                         g=9.81,
#                         specificenergy_Whkg=pr.specificenergy)
# means stuff before the ; is the original inputs that you have to do...
# calling normally without override
#     R = Range_parallel(Aircraft1, Propulsion1, E_0total, ϕ)

# Override just battery specific energy for a graph
#     R800 = Range_parallel(Aircraft1, Propulsion1, E_0total, ϕ; specificenergy_Whkg=800.0)
# used for parameter sweep!