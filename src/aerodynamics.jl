function atmosphere(altitude)
    #ISA model
    if altitude < 11000.0
        T = 288.15 - 0.0065 * altitude  #Temperature (K)
        P = 101325.0 * (T / 288.15) ^ 5.2561  #Pressure (Pa)
    elseif altitude < 20000.0
        T = 216.65  #Temperature (K)
        P = 22632.06 * exp(-0.0001577 * (altitude - 11000.0))  #Pressure (Pa)
    else
        T = 216.65 + 0.001 * (altitude - 20000.0)  #Temperature (K)
        P = 5474.89 * (T / 216.65) ^ -34.1632  #Pressure (Pa)
    end
    ρ = P / (287.05 * T)  #Density (kg/m³)
    return T, P, ρ
end


function dragforce(Aircraft, W, g, MissionSegment)
    q = 0.5*(MissionSegment.ρ)*(MissionSegment.V^2)
    K = 1/(π*Aircraft.e*Aircraft.AR)
    Cl = W*MissionSegment.load*g/(q*Aircraft.S)
    Cd = Aircraft.Cd0 + K*Cl^2; #drag coefficient
    D = 0.5*(MissionSegment.ρ)*(MissionSegment.V^2)*Aircraft.S*Cd #drag force
    return D
end

#fuel consumption for given power over time
function fuelconsumption(P_FB_req, SFC, dt) #W_fuel_old, dt
    P_kW=P_FB_req/1000.0
    m_dot_fuel = P_kW * SFC                 #sfc usually defined in kg/(kW·h)
    Δm_dot_fuel = m_dot_fuel * dt/3600
    fuelburn=Δm_dot_fuel
    return fuelburn                       
end