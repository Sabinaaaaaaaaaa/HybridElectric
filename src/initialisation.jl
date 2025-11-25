#copy from the excel spreadsheet

#define g in the Pluto notebook! multiply with the load
#Aircraft Parameters
struct Aircraft
    MTOW::Float64          # Maximum Take-Off Weight [kg]
    W_payload::Float64     # Payload Weight [kg]
    W_empty::Float64       # Baseline Empty Weight [kg]
    S::Float64             # Wing Area [m²]
    AR::Float64            # Aspect Ratio
    e::Float64             # Oswald Efficiency Factor
    Cd0::Float64           # Zero-lift Drag Coefficient
end


#Propulsion System Parameters
#Battery, Engine, Fuel
struct Propulsion
    η_motor::Float64                        # Motor Efficiency
    η_controller::Float64                   # Controller Efficiency
    η_battery::Float64                      # Battery Efficiency
    specificenergy::Float64                 # Battery Specific Energy [Wh/kg]
    SOC_min::Float64                        # Minimum State of Charge
    SFC::Float64                            # Specific Fuel Consumption [kg/(kW·h)]
    power_to_weight_motor::Float64          # Motor Power-to-Weight Ratio [W/kg]
    power_to_weight_controller::Float64     # Controller Power-to-Weight Ratio [W/kg]
    W_engine::Float64                       # Engine weight [kg]
end

#Mission segments
struct MissionSegment
    name::String
    h::Float64                  # Altitude [m]
    V::Float64                  # Velocity [m/s]
    duration::Float64           # Duration [s]
    ROC::Float64                # Rate of Climb [m/s]
    ϕ::Float64                  # Hybrization Fraction of power from electric system
    load::Float64               # Load factor
    SOC_initial::Float64        # Initial State of Charge
    weight_fraction::Float64    # Weight fraction at this segment
    dVdt::Float64               # Acceleration [m/s²]
    ρ::Float64                  # Air density [kg/m³]
end