#Battery ---> Controller ---> Motor ---> Propeller

#power draw from batteries
function batterypower(P_EM_req, η_motor, η_controller, η_battery)
    P_battery = P_EM_req/ (η_motor*η_controller*η_battery)
    return P_battery
end

#update state of charge
#battery state of charge after draining power over time dt
#dt: time step, SOC: current state of charge (0 to 1), E_battery_total: Wh, total battery energy capacity
function stateofcharge(SOC_old, P_battery, dt, E_battery_total)
    E_used=P_battery*dt/3600
    SOC_new = SOC_old - (E_used / E_battery_total)
    return SOC_new, E_used
end

#calculate total battery energy capacity
total_battery_energycapacity(W_battery, specificenergy) = W_battery * specificenergy #Wh


component_weight(P_max, power_to_weight)= P_max / power_to_weight