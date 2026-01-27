#fuel consumption for given power over time
function fuelconsumption(P_FB_req, SFC, dt) #W_fuel_old, dt
    P_kW=P_FB_req/1000.0
    m_dot_fuel = P_kW * SFC                 #sfc usually defined in kg/(kW·h)
    Δm_dot_fuel = m_dot_fuel * dt/3600
    fuelburn=Δm_dot_fuel
    return fuelburn                         #W_fuel_new=W_fuel_new)
end