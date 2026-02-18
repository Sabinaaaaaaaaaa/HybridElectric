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

component_weight(P_max, power_to_weight)= P_max / power_to_weight


function battery(name) #user selects battery from dropdown menu
    filepath = joinpath(@__DIR__, "batteries", "$name.txt")  
    data = readlines(filepath)
    function fparse(x)
        if x==""
            return 0.0
        else
            strip(x)
            return parse(Float64, x)
        end
    end

    maxcontinuouspower          = fparse(data[2]) #W
    energystoragecapacity       = fparse(data[3]) #Wh
    packspecificenergy          = fparse(data[4]) #Wh/kg
    weight                      = fparse(data[5]) #kg
    volume                      = fparse(data[6]) #m^3
    nominalvoltage              = fparse(data[7]) #V
    return (maxcontinuouspower=maxcontinuouspower, energystoragecapacity=energystoragecapacity, packspecificenergy=packspecificenergy, weight=weight, volume=volume, nominalvoltage=nominalvoltage)
end