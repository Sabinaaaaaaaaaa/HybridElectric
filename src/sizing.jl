#sizing

#total cruise energy=Pcruise(electrical demand)*time

#battery share = Ebat_req=(%of how much energy it supplies)*Pcruise
#battery capacity=Ebat nom=Ebat req/(battery usable *efficiency of the system)
#battery mass=Ebat nom/specific energy (Wh/kg)
#generator share 70% Egen=70%*Pcruise
#fuel mass=SFC*Egen


#motor mass =8.138e-5 * P_out


#battery sizing
#highest density of lithium ion battery = 365Wh/kg
#mission energy E_phase=P_phase*t_phase
#batterynominalcapacity =E_bat,req/(DoD*efficiency)   DoD is useable depth of discharge fraction 
#battery mass (from energy) m_bat, energy=Ebat,nom/specific energy
#battery mass(from power) m_bat,power=P_peak/(specific power)
#battery mass = max(m_bat,energy, m_bat,power)



#fuel sizing
#define power requirements
#compute total fuel requirements
function fuelreq(m_fuel, t)
    fuelmass=m_fuel*t
    fuelvolume=
    return (fuelmass=fuelmass, fuelvolume=fuelvolume)
end

function totalmass(fuelmass, batterymass, motormass, enginemass)
    total_mass = fuelmass + batterymass + motormass + enginemass
    return total_mass
end

#define where and how this is stored?