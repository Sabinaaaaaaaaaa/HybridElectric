#simulation of one time step of the mission profile using cinar equations to compute the weight
# This function implements the complete Cinar methodology for one time step:
# 1. Calculate current aircraft weight
# 2. Calculate required power
# 3. Split power between electric and fuel
# 4. Update battery SOC
# 5. Update fuel weight
# 6. Return new state

#initialise the state 
function runmission(FULLMISSION, Propulsion, Aircraft, W_PGD, batt, num_battery_packs, W_fuel_initial, g, η, μ, LD_takeoff)
    #this state describes the cumulative effect of each state on the TIME, SOC, W_fuel, W_total 
    state = MissionState(
        0.0,
        1.0,
        W_fuel_initial,
        0.0
    )

    #total amount of capacity that the battery can provide!
    batterycapacity = batt.energystoragecapacity * num_battery_packs #Wh
    W_battery = batt.weight * num_battery_packs #kg
    BatteryPowerRating=batt.maxcontinuouspower * num_battery_packs #W

    batterydepleted=false
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

            if segment.name=="takeoff"
                P_req=takeoffpowerrequired(weight, segment.load*g, segment.V, μ, segment.dVdt, LD_takeoff)/η
            else
                P_req=powerrequired(drag, segment.V, weight, segment.load*g, segment.dVdt, segment.ROC)/η 
            end


            #power split
            P_EM_req, P_FB_req =powersplit(P_req, segment.ϕ)



            #validation checks to see if engine is able to deliver this!
            if P_FB_req>Propulsion.P_max_engine 
                println("Power FB required exceeds maximum available power at time $(state.time) seconds. Required: $(P_FB_req) W, Available: $(Propulsion.P_max_engine) W")
                return false, state.SOC, batterydepleted, state.W_fuel
            end

            if P_EM_req>BatteryPowerRating
                println("Power EM required exceeds maximum available power at time $(state.time) seconds. Required: $(P_EM_req) W, Available: $(BatteryPowerRating) W")
                return false, state.SOC, batterydepleted, state.W_fuel
            end
            


            #update State Of Charge SOC
            if P_EM_req > 0
                P_battery = batterypower(P_EM_req, Propulsion.η_motor, Propulsion.η_controller, Propulsion.η_battery)
                SOC_new, E_used = stateofcharge(state.SOC, P_battery, dt, batterycapacity)

                #check if battery is depleted
                if SOC_new < Propulsion.SOC_min
                    println("Battery depleted during mission segment after $(state.time) seconds! SOC dropped below 20%.")
                    batterydepleted=true
                    # Don't update SOC below minimum
                    return false, state.SOC, batterydepleted, state.W_fuel
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
                    return false, state.SOC, batterydepleted, state.W_fuel
                end
            end
            
            state.time+=dt
        end

        println("Completed segment: $(segment.name), Time: $(state.time) seconds, SOC: $(round(state.SOC*100,digits=2))%, Remaining Fuel Mass: $(round(state.W_fuel,digits=2)) kg")

    end
    #mission is complete!
    return true, state.SOC, batterydepleted, state.W_fuel
end





function batteryandfuelsizing(Max_iterations, FULLMISSION, Propulsion, Aircraft, W_PGD, batt, g, η, μ, LD_takeoff)
    W_batt = 0.0
    W_f = 0.0
    last_leftoverfuel = 0.0
    num_battery_packs = 0.0 #number of battery packs

    fully_electric = all(seg -> seg.ϕ == 1, FULLMISSION)

    #volume constraints 
    FuelMax=Aircraft.maxfuelweight           # Maximum Fuel Capacity [kg] 
    BattVolumeMax=Aircraft.maxbatteryvolume  # Maximum Battery Volume [m^3]

    for j in 1:Max_iterations
        VolumeBatt=batt.volume * num_battery_packs
        if VolumeBatt > BattVolumeMax
            println("Battery volume exceeds maximum limit of $(BattVolumeMax) m^3. Cannot add more battery packs.")
            break
        end

        if W_f > FuelMax
            println("Fuel weight exceeds maximum limit of $(FuelMax) kg. Cannot add more fuel.")
            break   
        end

        Valid, SOCstate, batterydepleted, leftoverfuel = runmission(FULLMISSION, Propulsion, Aircraft, W_PGD, batt, num_battery_packs, W_f, g, η, μ, LD_takeoff); 
                
        last_leftoverfuel = leftoverfuel
                            
        if !Valid #not valid if it does not meet the mission requirements
            if batterydepleted #if battery was depleted increase battery
                W_batt +=batt.weight;
                num_battery_packs+=1
            end
            if (leftoverfuel <= 10) && !fully_electric #if fuel was depleted and it is not fully electric increase fuel
                W_f += 2
            end
        end

        if Valid #if it is valid, we can stop iterating
            println("Mission requirements met with $(num_battery_packs) battery packs, Battery Weight: $(round(W_batt,digits=2)) kg, Fuel Weight: $(round(W_f,digits=2)) kg")
            break
        end 

    end
    return num_battery_packs, W_batt, W_f, last_leftoverfuel
end
