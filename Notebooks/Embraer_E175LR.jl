### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 4580f93b-25b0-4f41-bdfa-a0cd2f503278
# ╠═╡ show_logs = false
begin
	using Pkg
	using Plots
    using PlutoUI
    import PlutoUI: Slider, NumberField, TextField, CheckBox
	Pkg.add("Revise")
	Pkg.develop(path="C:\\Users\\sabin\\OneDrive\\Desktop\\FYP\\HybridElectric")
	using HybridElectric
	using AeroFuse
	TableOfContents()
end

# ╔═╡ f4515400-d2f0-11f0-a3cd-db9046777251
md"# Embraer E175LR"

# ╔═╡ 5f1441ea-2158-4b08-98db-7c85b92307d4
md"""
This demonstration explores the design space of Embraer E175LR. The following parameters will be varied, and their impact on range, battery weight, and fuel weight will be assessed.

|Variable name  		   | Range  | 
|----     				   |----    |
|Hybridization Ratio ϕ 	   |  0-->1 |
|Electric Motor P/W 	   |  0-->1 |
|Power Converter P/W 	   |  0-->1 |
|Battery Specific Energy   |  0-->1 |


"""

# ╔═╡ 44d1c167-fc6c-4124-b1ac-5c643308f203
md"**Define Packages**"

# ╔═╡ 3404927e-e10a-447c-8917-89600f442cb9
md"### Define Aircraft Parameters"

# ╔═╡ 0cf0ae61-1fc6-4b7e-8d09-95f0b33bf362
begin
	MTOW= 38789.86 ;
	W_payload = 9814.0;
	W_empty = 21499.83 ;
    S   = 72.72;
    AR  = 9.5;
    e   = 0.85;
    Cd0 = 0.0220;
end;

# ╔═╡ 415043c5-d227-469a-8b73-bea59e3d6adb
aircraft = Aircraft(MTOW, W_payload, W_empty, S, AR, e, Cd0)

# ╔═╡ a6aecfef-c4ee-4fdd-a593-344209f5f5db
begin
	η_motor                    		= 0.97 #95-97% efficiency   
	η_controller               		= 0.96
	η_battery                 		= 0.95
	SOC_min                    		= 0.2
	SFC                        		= 0.414
	W_engine 				   		= 760*2
	P_max_engine 			   		= 6.6e6*2 
	#Note turbofans are thrust rated not power rated so this uses thrust rating of 14,500lbs and takeoff/climb velocity 102.9 m/s 
	No_Engines                 		= 2
	energy_density_fuel       	    = 11900.0
	η_gas_turbine_efficiency 		= 0.35  
	η_gearbox_efficiency 			= 0.95
	η_propulsive_efficiency 		= 0.8
	η_electric_generator_efficiency = 0.98
end;

# ╔═╡ ab2abbe5-baa2-4b1c-bfe6-1699a62535a1


# ╔═╡ 07cba5c3-8a95-4f45-bf72-754f6ea76ec1
md"### Define Aircraft Mission Segments"

# ╔═╡ 0b4a6af4-f701-443a-b5e8-393c2b0fb6c7
begin
	name1           = "Takeoff"
	h1   			= 0.0
	V1 				= 69.45
	duration1 		= 25
	ROC1 			= 0.0
	load1 			= 1.0
	dVdt1 			= 0.0
	T1, P1, ρ1  = atmosphere(h1);
end;

# ╔═╡ 04efbcfd-50b0-4cfb-ac84-71840620cc5b
begin
	name2           = "Climb"
	h2   			= 914.4
	V2 				= 102.9
	duration2 		= 18*60
	ROC2 			= 11.43
	load2 			= 1.0
	dVdt2 			= 0.0
	T2, P2, ρ2  = atmosphere(h2);
end;

# ╔═╡ 928b7621-f7e3-40d2-903b-b01b177f7b91
begin
	name3           = "Cruise"
	h3   			= 10668
	V3 				= 267.54
	duration3 		= 5*60*60 #5 hours
	ROC3 			= 0
	load3 			= 1.0
	dVdt3 			= 0.0
	T3, P3, ρ3  = atmosphere(h3);
end;

# ╔═╡ 4c36e0a0-15da-46e3-b9f8-c9c79d1d024e
begin
	name4           = "Land"
	h4   			= 914
	V4 				= 102.89
	duration4 		= 15*60
	ROC4 			= 0.0
	load4 			= 1.0
	dVdt4 			= 0.0
	T4, P4, ρ4  = atmosphere(h4);
end;

# ╔═╡ 3c66a4ae-e98f-47d3-9a2b-748d19e7a839
md"## Iteration Function - Change Parameters Here"

# ╔═╡ bbdd793a-650c-4176-9c3d-86da99f56458
#stuff that is constant/being kept the same
begin
	ϕ = 0.1
	power_to_weight_motor      		= 5200
	power_to_weight_controller 		= 3702.70

	TAKEOFF = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ, load1, dVdt1, ρ1)
	CLIMB = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ, load2, dVdt2, ρ2)
	CRUISE = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ, load3, dVdt3, ρ3)
	LAND = MissionSegment(name4, h4, V4, duration4, ROC4, ϕ, load4, dVdt4, ρ4)
	
	FULLMISSION=[TAKEOFF, CLIMB, CRUISE, LAND]

	g=9.81
	η=1

	W_battery_initial=500
	W_fuel_initial = 7000
	Max_iterations=1000
end

# ╔═╡ 492a4f53-f58e-497c-b9f0-bc1112140efc
# ╠═╡ disabled = true
#=╠═╡
begin
	for i =1:Max_iterations
		Valid, SOCstate, batterydepleted, leftoverfuel = runmission(FULLMISSION, propulsion, aircraft, W_PGD, W_battery, W_fuel_initial, g, η); 
		if Valid==false
			if batterydepleted==true
				W_battery=W_battery+500;
			end
			if leftoverfuel<=10
				W_fuel_initial = W_fuel_initial+500;
			end
		else
			break
		end
	end
end
  ╠═╡ =#

# ╔═╡ 97ff6cfe-bba1-4aaa-b01d-ca7f6a9ade2e
begin
	plot(
	    specificenergy,
	    TotalWeight,
	    xlabel = "Battery specific energy [Wh/kg]",
	    ylabel = "Weight [kg]",
	    label = "Battery weight",
	    linewidth = 2
	)

end

# ╔═╡ 4f8d879d-f479-4b1e-a662-a9f692681ad5
# ╠═╡ disabled = true
#=╠═╡
md"
Battery Mass = $W_battery kg
Fuel Mass = $W_fuel_initial kg
Aircraft Weight = $TotalWeight kg
"
  ╠═╡ =#

# ╔═╡ 986bce6c-3ef0-42e2-8a80-1da7c9e79611
# ╠═╡ disabled = true
#=╠═╡
begin 
	println("battery weight: ", W_battery, "kg")
	println("fuel weight: ", W_fuel_initial, "kg")
	TotalWeight= W_fuel_initial + aircraft.W_empty + aircraft.W_payload + W_PGD + W_battery ;
	println("Total aircraft weight: ", TotalWeight, "kg")
	Valid, SOCstate, batterydepleted, leftoverfuel = runmission(FULLMISSION, propulsion, aircraft, W_PGD, W_battery, W_fuel_initial, g, η)
end
  ╠═╡ =#

# ╔═╡ b2c282b2-7914-4c39-acc1-419f91282bbd
#stuff that is being changed
begin	
	specificenergy = Base.range(0.0, 3000, length=121)
	n = length(specificenergy)

	propulsion = Vector{Any}(undef, n)  # or Vector{Propulsion}(undef, n)

    W_motor      = zeros(n)
    W_controller = zeros(n)
    W_PGD        = zeros(n)
    output       = Vector{Any}(undef, n)
	
	W_battery = zeros(n)
    W_fuel    = zeros(n)
	TotalWeight = zeros(n)
	
	
	for i =1:length(specificenergy)
		
		propulsion[i] = Propulsion(η_motor, η_controller, η_battery, specificenergy[i], SOC_min, SFC, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_propulsive_efficiency, η_electric_generator_efficiency)

		
		W_motor[i] = component_weight(propulsion[i].P_max_engine * ϕ, propulsion[i].power_to_weight_motor)
        W_controller[i] = component_weight(propulsion[i].P_max_engine * ϕ / propulsion[i].η_motor,propulsion[i].power_to_weight_controller)
        W_PGD[i] = W_motor[i] + W_controller[i]

		
        W_batt = W_battery_initial
        W_f    = W_fuel_initial
		
		
		for j in Max_iterations
			Valid, SOCstate, batterydepleted, leftoverfuel = runmission(FULLMISSION, propulsion[i], aircraft, W_PGD[i], W_batt, W_f, g, η); 


			if !Valid
                if batterydepleted
                    W_batt += 500
                end
                if leftoverfuel <= 10
                    W_f += 500
                end
            else
                break
            end
			
			
			
			
			#if Valid #resizing so that battery can do what it needs to do
			#	if batterydepleted
			#			W_batt +=50; 
			#	else
			#		break
			#	end
				
			#else #not valid
			#	if batterydepleted
			#			W_batt +=50;
			#	end
			#	if leftoverfuel<=10
			#		W_f+=500;
			#	end
			#end

			
		end
		
	    W_battery[i] = W_batt
        W_fuel[i]    = W_f
        output[i] = runmission(FULLMISSION, propulsion[i], aircraft, W_PGD[i], 	W_batt, W_f, g, η)
		TotalWeight[i]=  W_fuel[i] + aircraft.W_empty + aircraft.W_payload + W_PGD[i] + W_battery[i] ;

	end
end

# ╔═╡ Cell order:
# ╟─f4515400-d2f0-11f0-a3cd-db9046777251
# ╟─5f1441ea-2158-4b08-98db-7c85b92307d4
# ╟─44d1c167-fc6c-4124-b1ac-5c643308f203
# ╟─4580f93b-25b0-4f41-bdfa-a0cd2f503278
# ╟─3404927e-e10a-447c-8917-89600f442cb9
# ╠═0cf0ae61-1fc6-4b7e-8d09-95f0b33bf362
# ╟─415043c5-d227-469a-8b73-bea59e3d6adb
# ╠═a6aecfef-c4ee-4fdd-a593-344209f5f5db
# ╟─ab2abbe5-baa2-4b1c-bfe6-1699a62535a1
# ╟─07cba5c3-8a95-4f45-bf72-754f6ea76ec1
# ╠═0b4a6af4-f701-443a-b5e8-393c2b0fb6c7
# ╠═04efbcfd-50b0-4cfb-ac84-71840620cc5b
# ╠═928b7621-f7e3-40d2-903b-b01b177f7b91
# ╠═4c36e0a0-15da-46e3-b9f8-c9c79d1d024e
# ╟─3c66a4ae-e98f-47d3-9a2b-748d19e7a839
# ╠═bbdd793a-650c-4176-9c3d-86da99f56458
# ╠═b2c282b2-7914-4c39-acc1-419f91282bbd
# ╠═97ff6cfe-bba1-4aaa-b01d-ca7f6a9ade2e
# ╠═492a4f53-f58e-497c-b9f0-bc1112140efc
# ╠═986bce6c-3ef0-42e2-8a80-1da7c9e79611
# ╠═4f8d879d-f479-4b1e-a662-a9f692681ad5
