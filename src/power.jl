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
    W=Weight*g
    P_drag=D*V
    P_kinetic=(W*V/g)*dVdt
    P_potential=W*ROC #ROC is rate of climb, positive for climb, negative for descent, dV/dt=0 for steady flight

    P_total_req=P_drag + P_kinetic + P_potential
    return P_total_req
end

function takeoffpowerrequired(Weight,g, Vtakeoff, μ, dVdt, LD)
    #P=W V  ( μ(1-( v/vto)^2 )  +1/(L/D) (v/vto)^2   + dVdT/g  )      W is N (mg) 
    #assume v=0.7vtakeoff
    W = Weight*g
    V = 0.7*Vtakeoff
    α=V/Vtakeoff
    P_takeoff = W*V*(  μ*(1-α^2)   +  (1/LD)*α^2 +  dVdt/g  )
    return P_takeoff
end
