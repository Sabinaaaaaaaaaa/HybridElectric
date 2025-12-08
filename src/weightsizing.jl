#Cinar iterative battery sizing method
#repeatedly calls rumission until battery size is adequate

# This implements the TRUE Cinar methodology where:
# 1. Estimate MTOW take-off +40% margin
# 2. Calculate power requirements throughout the mission
# 3. Size the batteries and the fuel
# 4. Add component weights
# 5. Update structural weights estimate
# 6. Calculate new empty weight
# 7. Check if it converges

#note as battery increases, fuel decreases to keep MTOW constant!

#size the PG&D components
#adjust guess for MTOW? and plot on graph!


#done for cruise
function batteryweightsizing(MissionSegment, g, drag, max_iterations, tolerance)
    damping=0.5;
    #input MTOW estimate
    W_cruise_estimate=Aircraft.MTOW

    P_total_req=powerrequired(drag, MissionSegment.V, W_cruise_estimate, g, MissionSegment.dVdt, MissionSegment.ROC)

    P_EM_req, P_FB_req = powersplit(P_total_req, MissionSegment.ϕ)

    #may want to check these equations!!!
    W_motor = component_weight(P_EM_req, Propulsion.power_to_weight_motor)
    W_controller = component_weight(P_EM_req/Propulsion.η_motor, Propulsion.power_to_weight_controller)

    W_PGD= W_motor + W_controller

    #iterative battery sizing
    #initial battery guess, rough sizing using energy-based estimate
    energy_estimate = batterypower(P_EM_req, Propulsion.η_motor, Propulsion.η_controller, Propulsion.η_battery)*MissionSegment.duration/3600.0 
    W_battery = energy_estimate / (Propulsion.specificenergy * (1.0 - Propulsion.SOC_min))


    for i in 1:max_iterations
        #compute fuel to maintain MTOW
        W_fuel_initial = Aircraft.MTOW - Aircraft.W_empty - Aircraft.W_payload - W_PGD - W_battery

        if W_fuel_initial <0
            println("Battery is too heavy! Negative fuel weight.")
            return nothing
        end
        
        #simulate mission with current battery size and fuel weight
        check, SOC_end = runmission(MissionSegment, drag, Propulsion, Aircraft, W_PGD, W_battery, W_fuel_initial , g)

        #check convergence
        SOC_margin = SOC_end - Propulsion.SOC_min
        if !check
            #battery depleted, need more battery
            println("Battery depleted! SOC dropped below $(Propulsion.SOC_min*100)%")
            
            if SOC_end <= 0
                scale_factor = 1.5 #if it did not work, multiply by a scale factor!
            #else
                #SOC_used = MissionSegment.SOC_initial - SOC_end
                #SOC_available = MissionSegment.SOC_initial - Propulsion.SOC_min
                #scale_factor = (SOC_used / SOC_available) * 1.05
            end

            W_battery_new = W_battery * scale_factor #resize batteries

            #need to check if battery is stuck at this size, small convergence
            if abs(W_battery_new - W_battery)<0.01
                println("Does not converge!")
                break
            end

            W_battery=W_battery +damping*(W_battery_new - W_battery) #damping to prevent oscillations
        
        elseif SOC_margin < Propulsion.SOC_min #battery sized well!
            println("The battery weight sizing has converged. The battery is optimally sized.")
            break

        elseif SOC_margin > 0.35 #battery oversized, can be reduced!
            println("Battery oversized (SOC = $(SOC_end*100)%, min = $(Propulsion.SOC_min*100)%)")
            E_bat=total_battery_energycapacity(W_battery, Propulsion.specificenergy)
            E_excess=E_bat*(SOC_margin - 0.05) #keep 5% margin
            W_battery_new = W_battery - (E_excess / Propulsion.specificenergy)
            if abs(W_battery_new - W_battery)<tolerance
                println("The battery weight sizing has converged.")
                break
            end
            W_battery=W_battery +damping*(W_battery_new - W_battery) 
        else 
            #suitable range
            println("The battery weight sizing has converged. SOC in acceptable range.")
            break
        end
        
    end

    W_fuel = Aircraft.MTOW - Aircraft.W_empty - Aircraft.W_payload - W_PGD - W_battery
    E_bat= total_battery_energycapacity(W_battery, Propulsion.specificenergy)

    return W_fuel, W_battery, W_PGD, E_bat, SOC_end
end