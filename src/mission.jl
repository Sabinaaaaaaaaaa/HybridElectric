#simulation of one time step of the mission profile using cinar equations to compute the weight
# This function implements the complete Cinar methodology for one time step:
# 1. Calculate current aircraft weight
# 2. Calculate required power
# 3. Split power between electric and fuel
# 4. Update battery SOC
# 5. Update fuel weight
# 6. Return new state

#initialise the state 
function runmission(MissionSegment, drag, Propulsion, Aircraft, W_PGD, W_battery, W_fuel_initial, g)
    state = MissionState(
        0.0,
        MissionSegment.SOC_initial,
        W_fuel_initial,
        0.0
    )

    batterycapacity = total_battery_energycapacity(W_battery, Propulsion.specificenergy) 


    for segment in MissionSegment
        #time discretisation
        dt=1.0 #seconds 
        #time refers to the time of the current flight segment
        N = Int(floor(segment.duration/ dt)) #number of steps

        for i in 1:N
            #calculate CURRENT WEIGHT at moment in time
            #the battery weight and everything is constant but the fuel changes
            weight=Aircraft.W_empty + Aircraft.W_payload + W_PGD + W_battery + state.W_fuel + Propulsion.W_engine
            state.W_total=weight



            #ELECTRICAL INTEGRATION PART
            #calculate power required with the current weight estimate at this flight stage
            P_req=powerrequired(drag, segment.V, weight, g, segment.dVdt, segment.ROC) #acceleration dV/dt=0 for steady flight

            #power split
            P_EM_req, P_FB_req =powersplit(P_req, segment.ϕ)
            
            #update State Of Charge SOC
            if P_EM_req > 0
                P_battery = batterypower(P_EM_req, Propulsion.η_motor, Propulsion.η_controller, Propulsion.η_battery)
                SOC_new, E_used = stateofcharge(state.SOC, P_battery, dt, batterycapacity)
                state.SOC=SOC_new

                #check if battery is depleted
                if state.SOC < 0.2
                    @warn "Battery depleted!" 
                    return false, state.SOC
                end
                
            end


            #FUEL INTEGRATION PART
            if P_FB_req > 0
                fuelburn = fuelconsumption(P_FB_req, Propulsion.SFC, dt)
                state.W_fuel -= fuelburn
                if state.W_fuel < 0
                    @warn "Out of fuel!"
                    return false
                end
            
            end
            
            state.time+=dt
        end
    end
    #misison is complete!
    return true, state.SOC
end