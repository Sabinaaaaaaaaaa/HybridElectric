#Power Management
#how much energy comes from the battery vs generator
#adjust for during each flight stage
#input Ptotal: sum of the maximum powers, ϕ: hybridization factor
#ϕ - defined as Pelectricrequired/Prequiredtotal where ϕ=0 is conventional 
#output Pelectricrequired, Pfuelrequired


function powersplit(P_total_req, ϕ)
    
    P_EM_req = ϕ*P_total_req
    P_FB_req = (1-ϕ)*P_total_req
    return P_EM_req, P_FB_req
end


function powerrequired(drag, V, Weight, g, dVdt, ROC)
    #Cinar P_req = D*V+ d/dt( W*V^2/2g + W*h ) = steady drag power + Kinetic energy rate + Potential energy rate
    D=drag
    W=Weight
    P_drag=D*V
    P_kinetic=(W*V/g)*dVdt
    P_potential=W*g*ROC #ROC is rate of climb, positive for climb, negative for descent, dV/dt=0 for steady flight

    P_total_req=P_drag + P_kinetic + P_potential
    return P_total_req
end