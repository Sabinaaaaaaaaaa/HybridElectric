#module electricmotor
#takes electric power demand from battery

function emotor(V, ω, ηmotor, P2)
    motortorque = P2 / ω # Torque from required shaft power
    
    P_electric = P2 / ηmotor # Electrical power draw from battery
    
    I = P_electric / V
    #Kv=(V_max-i*R0)/ω_max
    #i_max=0.5*(sqrt(  Kv^2*ωbase^2 +1.63299*Pmax*R0)-Kv*ωbase)/R0
    return (motortorque=motortorque, P_electric=P_electric, I=I)
end

