function enginecombustion(ϕ, Pmax, eta_P, LHV)
     P1 = 1-ϕ*Pmax
     m_fuel = P1 / (eta_P * LHV)
     return (P1=P1, m_fuel=m_fuel)
end


#LHV = lower heat value= energy available to the engine

#testung example
#P_split = 0.7
#P_total = 300e3
#ICE_data = combustion.enginecombustion(ϕ, 300e3, 0.35, 43e6)