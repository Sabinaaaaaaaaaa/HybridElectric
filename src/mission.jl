#simulation of one time step of the mission profile using cinar equations to compute the weight
# This function implements the complete Cinar methodology for one time step:
# 1. Calculate current aircraft weight
# 2. Calculate required power
# 3. Split power between electric and fuel
# 4. Update battery SOC
# 5. Update fuel weight
# 6. Return new state

#initialise the state 
function runmission(FULLMISSION, Propulsion, Aircraft, W_PGD, W_battery, W_fuel_initial, g, η)
    #this state describes the cumulative effect of each state on the TIME, SOC, W_fuel, W_total 
    state = MissionState(
        0.0,
        1.0,
        W_fuel_initial,
        0.0
    )

    #total amount of capacity that the battery can provide!
    batterycapacity = total_battery_energycapacity(W_battery, Propulsion.specificenergy) 


    for segment in FULLMISSION #this iterates across the FULLMISSION ARRAY, each segment is a MissionSegment


        #time discretisation
        dt=1.0 #seconds 
        #time refers to the time of the current flight segment
        N = Int(floor(segment.duration/ dt)) #number of steps

        for _ in 1:N
            #calculate CURRENT WEIGHT at moment in time
            #the battery weight and everything is constant but the fuel changes
                      
            weight=Aircraft.W_empty + Aircraft.W_payload + W_PGD + W_battery + state.W_fuel + Propulsion.W_engine
            state.W_total=weight

            drag = dragforce(Aircraft, state.W_total, g, segment)


            #ELECTRICAL INTEGRATION PART
            #calculate power required with the current weight estimate at this flight stage
            P_req=powerrequired(drag, segment.V, weight, segment.load*g, segment.dVdt, segment.ROC)/η 

            #validation checks to see if battery and engine are able to deliver this!
            P_max_available = Propulsion.P_max_motor + Propulsion.P_max_engine
            if P_req>P_max_available
                println("Power required exceeds maximum available power at time $(state.time) seconds. Required: $(P_req) W, Available: $(P_max_available) W")
                return false, state.SOC
            end

            #power split
            P_EM_req, P_FB_req =powersplit(P_req, segment.ϕ)

            if P_EM_req>Propulsion.P_max_motor 
                println("Power EM required exceeds maximum available power at time $(state.time) seconds. Required: $(P_EM_req) W, Available: $(P_max_motor) W")
                return false, state.SOC
            end

            if P_FB_req>Propulsion.P_max_engine 
                println("Power FB required exceeds maximum available power at time $(state.time) seconds. Required: $(P_FB_req) W, Available: $(P_max_engine) W")
                return false, state.SOC
            end

            
            #update State Of Charge SOC
            if P_EM_req > 0
                P_battery = batterypower(P_EM_req, Propulsion.η_motor, Propulsion.η_controller, Propulsion.η_battery)
                SOC_new, E_used = stateofcharge(state.SOC, P_battery, dt, batterycapacity)

                #check if battery is depleted
                if SOC_new < Propulsion.SOC_min
                    println("Battery depleted during mission segment! SOC dropped below 20%, need to increase battery size.")
                    println("Battery depleted after $(state.time) seconds! Switching additional load to fuel-based propulsion")
                    P_FB_req += P_EM_req  
                    P_EM_req = 0
                    # Don't update SOC below minimum
                else
                    state.SOC = SOC_new
                end 
    
                
            end


            #FUEL INTEGRATION PART
            if P_FB_req > 0
                fuelburn = fuelconsumption(P_FB_req, Propulsion.SFC, dt)
                state.W_fuel -= fuelburn
                if state.W_fuel < 0
                    println("Fuel exhausted during mission segment! Need to increase fuel size.")
                    return false, state.SOC
                end
            end
            
            state.time+=dt
        end
    end
    #misison is complete!
    return true, state.SOC
end