#battery storage module - state of charge, compute voltage, current, energy capacity. 
#State of Charge(t)=SOC(t0)-1/Emax *integral(Pload(t)dt)between t0 and T
#Energy balance E(t)=E(t0)-integral(Pload(t)/efficiency discharge)dt between t0 to t
#Battery mass = Emax/specific energy (Wh/kg)
#track energy left, SOC,supplieselectric power
#input:load demand ... output: soc, available power 

#SoC(t)=SoC(t0)+(1/Crated)*∫I_battery dt between t0and t0+tau


