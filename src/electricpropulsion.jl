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

packspecificenergy(specificenergy, packagingfactor)= specificenergy * packagingfactor

function battery(name) #user selects battery from dropdown menu
    filepath = joinpath(@__DIR__, "batteries", "$name.txt")  
    data = readlines(filepath)
    
    usage = data[2]
    company = data[3]
    nominalvoltage= data[4]
    outputcurrent= data[5]
    amperehourcapacity= data[6]
    energystoragecapacity= data[7]
    weight= data[8]
    volume= data[9]
    height= data[10]
    width= data[11]
    depth= data[12]
    radius= data[13]
    cell_energy_density= data[14]
    cell_specific_energy= data[15]
    specific_power= data[16]
    max_voltage= data[17]
    min_voltage= data[18]
    continuous_discharge_rate= data[19]
    continuous_charge_rate= data[20]
    return (usage=usage, company=company, nominalvoltage=nominalvoltage, outputcurrent=outputcurrent, amperehourcapacity=amperehourcapacity, energystoragecapacity=energystoragecapacity, weight=weight, volume=volume, height=height, width=width, depth=depth, radius=radius, cell_energy_density=cell_energy_density, cell_specific_energy=cell_specific_energy, specific_power=specific_power, max_voltage=max_voltage, min_voltage=min_voltage, continuous_discharge_rate=continuous_discharge_rate, continuous_charge_rate=continuous_charge_rate) 
end