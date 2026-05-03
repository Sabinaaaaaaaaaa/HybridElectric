### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

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
md"# NASA Altair"

# ╔═╡ 5f1441ea-2158-4b08-98db-7c85b92307d4
md"""
This demonstration explores the design space of NASA's Altair small UAV. The following parameters will be varied, and their impact on range, battery weight, and fuel weight will be assessed.

|Variable name  		   | Range  | 
|----     				   |----    |
|Hybridization Ratio ϕ 	   |  0-->1 |
|Electric Motor P/W 	   |  2000-->7000 | #5000
|Power Converter P/W 	   |  2000-->6000 | #2000
|Battery Specific Energy   |  0-->500 |


"""

# ╔═╡ 44d1c167-fc6c-4124-b1ac-5c643308f203
md"**Define Packages**"

# ╔═╡ a68db7ec-1042-4689-82a4-992963482d76
md"### Define Battery "

# ╔═╡ 60b6bc84-abac-481d-b547-ac1d9c493ee2
@bind batteryselection Select(["PB345V124E-L"])

# ╔═╡ 87f4784b-323f-47f7-843b-ebe2c247230f
batt=battery(batteryselection)

# ╔═╡ 7b2fcfee-edf0-4c79-928a-57fcfcb864c8
# ╠═╡ disabled = true
#=╠═╡
md"""
**$batteryselection** 

| Parameter     			| Value   | Units| 
| ----- 					| ---- 	            |----|
| Maximum Continuous Power 			| $(batt.maxcontinuouspower)                     |W|
| Energy Storage Capacity 					| $(batt.energystoragecapacity)                   |Wh|
| Pack Specific Energy    | $(batt.packspecificenergy)            |Wh/kg|
| Weight | $(batt.weight)             |kg|
| Volume      | $(batt.volume)        |m^3|
| Nominal Voltage   | $(batt.nominalvoltage)     |V|

"""
  ╠═╡ =#

# ╔═╡ 20012e75-c631-47ea-b021-b0e4a0430ed4


# ╔═╡ 3404927e-e10a-447c-8917-89600f442cb9
md"### Define Aircraft Parameters"

# ╔═╡ 0cf0ae61-1fc6-4b7e-8d09-95f0b33bf362
begin
	MTOW= 3175
	W_payload = 340
	W_empty = 1475
    S   = 29.24
    AR  = 23.5
    e   = 0.8
    Cd0 = 0.018
	maxfuelweight = 1360.77
	maxbatteryvolume = 2.71 
end;

# ╔═╡ 415043c5-d227-469a-8b73-bea59e3d6adb
aircraft = Aircraft(MTOW, W_payload, W_empty, S, AR, e, Cd0, maxfuelweight, maxbatteryvolume)

# ╔═╡ a6aecfef-c4ee-4fdd-a593-344209f5f5db
begin
	η_motor                    		= 0.97 #95-97% efficiency   
	η_controller               		= 0.96
	η_battery                 		= 0.95
	SOC_min                    		= 0.2
	SFC                        		= 0.32
	W_engine 				   		= 175
	P_max_engine 			   		= 700958
	No_Engines                 		= 1
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
	name1           = "Taxi"
	h1   			= 0
	V1 				= 3
	duration1 		= 180
	ROC1 			= 0
	load1 			= 1
	dVdt1 			= 0
	T1, P1, ρ1  = atmosphere(h1);
end;

# ╔═╡ 04efbcfd-50b0-4cfb-ac84-71840620cc5b
begin
	name2           = "takeoff"
	h2   			= 457.2
	V2 				= 40
	duration2 		= 60
	ROC2 			= 0
	load2 			= 1
	dVdt2 			= 0
	T2, P2, ρ2  = atmosphere(h2);
	μ=0.02
	LD_takeoff=11
end;

# ╔═╡ 928b7621-f7e3-40d2-903b-b01b177f7b91
begin
	name3           = "Climb"
	h3   			= 4267.2
	V3 				= (45+50)/2
	duration3 		= 480
	ROC3 			= 10.2
	load3 			= 1
	dVdt3 			= 0
	T3, P3, ρ3  = atmosphere(h3);
end;

# ╔═╡ 4c36e0a0-15da-46e3-b9f8-c9c79d1d024e
begin
	name4           = "Cruise"
	h4   			= 4267.2
	V4 				= 51.44
	duration4 		= 1440
	ROC4 			= 0.0
	load4 			= 1
	dVdt4 			= 0.0
	T4, P4, ρ4  = atmosphere(h4);
end;

# ╔═╡ 4d6e0c76-2699-426d-9da9-976904e7707f
begin
	name5           = "Descent"
	h5   			= 457.2
	V5 				= (35+40)/2
	duration5 		= 960
	ROC5 			= 0.0
	load5 			= 1
	dVdt5 			= 0.0
	T5, P5, ρ5  = atmosphere(h5);
end;

# ╔═╡ fe6e4969-f985-4123-9ebb-8af530e7e663
begin
	name6           = "Landing"
	h6   			= 0
	V6 				= 32.5
	duration6 		= 300
	ROC6 			= 0.0
	load6 			= 1
	dVdt6 			= 0.0
	T6, P6, ρ6  = atmosphere(h6);
end;

# ╔═╡ 4b73459d-6f4a-4778-859d-4ebb7a5ff6a0
begin
	name7           = "Taxi"
	h7   			= 0
	V7 				= 3
	duration7 		= 180
	ROC7 			= 0.0
	load7 			= 1
	dVdt7 			= 0.0
	T7, P7, ρ7  = atmosphere(h7);
end;

# ╔═╡ f656498f-5dd6-45fa-9bf7-0255856c7b34


# ╔═╡ 04f5332d-8555-40ba-9c34-957fddb89034
md"### Baseline Code"

# ╔═╡ 734faa23-3471-491b-bf04-b4464e14fab6


# ╔═╡ 3c66a4ae-e98f-47d3-9a2b-748d19e7a839
md"## Variation of Specific Energy"

# ╔═╡ 362f16ea-04d2-408d-b9a1-5327ff32bd96


# ╔═╡ 2e5cac5e-edd9-497b-b0e1-68607dfaf856
md"## Variation of Hybridization Ratio ϕ"

# ╔═╡ 6156c4fb-73ba-4b9f-810e-9d61d58faa1c
#md"## Variation of Controller P/W"
md"## Variation of Electric Motor P/W"

# ╔═╡ 97ff6cfe-bba1-4aaa-b01d-ca7f6a9ade2e
# ╠═╡ disabled = true
#=╠═╡
begin
	plot(
	    specificenergy,
	    W_battery,
	    xlabel = "Battery specific energy (Wh/kg)",
		ylabel = "Weight (kg)",
		label = "Battery Weight (kg)",
		title = "ϕ = $(ϕ)",
	    linewidth = 2
	)
	plot!(specificenergy,
	    W_fuel,
	    linewidth = 2,
		label = "Fuel Weight (kg)"
	)
		
	plot!(specificenergy,
	    unusedfuel,
	    linewidth = 2,
		label = "Unused Fuel (kg)"
	)

end
  ╠═╡ =#

# ╔═╡ 87520646-7ec2-4c50-b456-40922945fc13
# ╠═╡ disabled = true
#=╠═╡
begin
	plot(ϕ, W_battery,
	    xlabel = "Hybridization Ratio ϕ",
		ylabel = "Weight (kg)",
		label = "Battery Weight (kg)",
	    linewidth = 2
		#ylims = (0, 500) 
	)
	plot!(ϕ, W_fuel,
	    linewidth = 2,
		label = "Fuel Weight (kg)"
	)
		
	plot!(ϕ, unusedfuel,
	    linewidth = 2,
		label = "Unused Fuel (kg)"
	)

end
  ╠═╡ =#

# ╔═╡ 77cc9a93-a94f-419e-826b-739a0b64d245
# ╠═╡ disabled = true
#=╠═╡
begin
	plot(ϕ,	    TotalWeight,
	    xlabel = "Hybridization Ratio ϕ",
	    ylabel = "Total Aircraft Weight (kg)",
	    linewidth = 2,
		legend=false
		#ylims = (340, 370) 
	)

end
  ╠═╡ =#

# ╔═╡ be028496-e829-4d2d-b6ae-468080731524
# ╠═╡ disabled = true
#=╠═╡
begin
	plot(power_to_weight_motor, W_battery,
	    xlabel = "Motor P/W (W/kg)",
		ylabel = "Weight (kg)",
		label = "Battery Weight (kg)",
	    linewidth = 2,
		#xlims = (0, 1500) ,
		title="ϕ = $(ϕ)"
			
	)
	#plot!(power_to_weight_motor, W_fuel,
	 #   linewidth = 2,
		#label = "Fuel Weight (kg)"
	#)
		
	#plot!(power_to_weight_motor, unusedfuel,
	 #   linewidth = 2,
		#label = "Unused Fuel (kg)"
	#)
	

end
  ╠═╡ =#

# ╔═╡ a1a6593e-703b-4113-9fdd-e6dbed800fd2
# ╠═╡ disabled = true
#=╠═╡
begin
	plot(power_to_weight_motor,	    TotalWeight, #power_to_weight_controller
	    xlabel = "Motor P/W (W/kg)",
	    ylabel = "Total Aircraft Weight (kg)",
	    linewidth = 2,
		legend=false,
		 title="ϕ = $(ϕ)"
		#ylims = (340, 370) 
	)
end
  ╠═╡ =#

# ╔═╡ 5b48d066-26fa-484b-b749-8fc207f5867e
# ╠═╡ disabled = true
#=╠═╡
#stuff that is constant/being kept the same
begin
	ϕ = 0.5 #0.3, 0.5, 0.9, 
	#power_to_weight_motor       = 5000
	power_to_weight_controller 		= 2000

	TAXI = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ, load1, dVdt1, ρ1)
	takeoff = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ, load2, dVdt2, ρ2)
	CLIMB = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ, load3, dVdt3, ρ3)
	CRUISE = MissionSegment(name4, h4, V4, duration4, ROC4, ϕ, load4, dVdt4, ρ4)
	DESCENT = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ, load5, dVdt5, ρ5)
	LAND = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ, load6, dVdt6, ρ6)
	TAXI2 = MissionSegment(name7, h7, V7, duration7, ROC7, ϕ, load7, dVdt7, ρ7)
	
	FULLMISSION=[TAXI, takeoff, CLIMB, CRUISE, DESCENT, LAND, TAXI2]

	g=9.81
	η=1

	Max_iterations=1000
end;
  ╠═╡ =#

# ╔═╡ d008b166-0841-48b8-86ad-6478ed95be88
# ╠═╡ disabled = true
#=╠═╡
#stuff that is constant/being kept the same
begin
	power_to_weight_motor      		= 5000
	power_to_weight_controller 		= 2000
	g=9.81
	η=1

	W_battery_initial=0
	W_fuel_initial = 0
	Max_iterations=1000

	propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, SFC, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_propulsive_efficiency, η_electric_generator_efficiency)
end;
  ╠═╡ =#

# ╔═╡ b2c282b2-7914-4c39-acc1-419f91282bbd
# ╠═╡ disabled = true
#=╠═╡
#stuff that is being changed
begin	
	specificenergy = Base.range(0.0, 500, length=121)
	n = length(specificenergy)

	propulsion = Vector{Any}(undef, n)  # or Vector{Propulsion}(undef, n)
    output       = Vector{Any}(undef, n)
	
	W_battery = zeros(n)
    W_fuel    = zeros(n)
	TotalWeight = zeros(n)
	
	
	for i =1:length(specificenergy)
		
		propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy[i], SOC_min, SFC, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_propulsive_efficiency, η_electric_generator_efficiency)

		
		W_motor = component_weight(propulsion.P_max_engine * ϕ, propulsion.power_to_weight_motor)
        W_controller = component_weight(propulsion.P_max_engine * ϕ / propulsion.η_motor,propulsion.power_to_weight_controller)
        W_PGD = W_motor + W_controller
		
		feasible, num_battery_packs, W_f = batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, aircraft, W_PGD, batt, g, η, μ, LD_takeoff)
		if !feasible
			break
		end
	    W_battery[i] = batt.weight*num_battery_packs
        W_fuel[i]    = W_f
		TotalWeight[i] =  W_fuel[i] + aircraft.W_empty + aircraft.W_payload + W_PGD + W_battery[i] ;

	end
end
  ╠═╡ =#

# ╔═╡ bbdd793a-650c-4176-9c3d-86da99f56458
# ╠═╡ disabled = true
#=╠═╡
#stuff that is constant/being kept the same
begin
	ϕ = 1
	power_to_weight_motor      		= 5000
	power_to_weight_controller 		= 2000

	TAXI = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ, load1, dVdt1, ρ1)
	takeoff = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ, load2, dVdt2, ρ2)
	CLIMB = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ, load3, dVdt3, ρ3)
	CRUISE = MissionSegment(name4, h4, V4, duration4, ROC4, ϕ, load4, dVdt4, ρ4)
	DESCENT = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ, load5, dVdt5, ρ5)
	LAND = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ, load6, dVdt6, ρ6)
	TAXI2 = MissionSegment(name7, h7, V7, duration7, ROC7, ϕ, load7, dVdt7, ρ7)
	
	FULLMISSION=[TAXI, takeoff, CLIMB, CRUISE, DESCENT, LAND, TAXI2]

	g=9.81
	η=1
	Max_iterations=2000
end;
  ╠═╡ =#

# ╔═╡ 783b2ab8-25bd-426e-868f-57ce6ae38873
# ╠═╡ disabled = true
#=╠═╡
#stuff that is being changed
begin	
	ϕ = Base.range(0.0, 1.0, length=121)
	n = length(ϕ)
	
	W_battery = zeros(n)
    W_fuel    = zeros(n)
	TotalWeight = zeros(n)
	
	
	for i =1:n	
		W_motor = component_weight(propulsion.P_max_engine * ϕ[i], propulsion.power_to_weight_motor)
        W_controller= component_weight(propulsion.P_max_engine * ϕ[i] / propulsion.η_motor,propulsion.power_to_weight_controller)
        W_PGD = W_motor + W_controller

		TAXI = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ[i], load1, dVdt1, ρ1)
		takeoff = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ[i], load2, dVdt2, ρ2)
		CLIMB = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ[i], load3, dVdt3, ρ3)
		CRUISE = MissionSegment(name4, h4, V4, duration4, ROC4, ϕ[i], load4, dVdt4, ρ4)
		DESCENT = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ[i], load5, dVdt5, ρ5)
		LAND = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ[i], load6, dVdt6, ρ6)
		TAXI2 = MissionSegment(name7, h7, V7, duration7, ROC7, ϕ[i], load7, dVdt7, ρ7)
	
		FULLMISSION=[TAXI, takeoff, CLIMB, CRUISE, DESCENT, LAND, TAXI2]


		feasible, num_battery_packs, W_f = batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, aircraft, W_PGD, batt, g, η, μ, LD_takeoff)
		if !feasible
			break
		end
	    W_battery[i] = batt.weight*num_battery_packs
        W_fuel[i]    = W_f
		TotalWeight[i]=  W_fuel[i] + aircraft.W_empty + aircraft.W_payload + W_PGD + W_battery[i] ;

	end
end
  ╠═╡ =#

# ╔═╡ afb4ba00-115c-4a42-a2ca-d4366bbfe021
specificenergy= batt.packspecificenergy

# ╔═╡ 3dc7c369-dc0c-4996-9f80-feb0ec912a35
#=╠═╡
begin 
	W_batt=batt.weight*num_battery_packs
	println("battery weight: ", W_batt, "kg")
	println("fuel weight: ", W_f, "kg")
	TotalWeight= W_f + aircraft.W_empty + aircraft.W_payload + W_PGD + W_batt ;
	println("Total aircraft weight: ", TotalWeight, "kg")
	
	Valid, SOCstate, batterydepleted, leftoverfuel = runmission(FULLMISSION, propulsion, aircraft, W_PGD, batt, num_battery_packs, W_f, g, η, μ, LD_takeoff)
end;
  ╠═╡ =#

# ╔═╡ 2979e0b6-c4ef-4bf8-8561-7a3d27d088f1
# ╠═╡ disabled = true
#=╠═╡
#stuff that is being changed
begin	
	power_to_weight_motor      		= Base.range(2000, 7000, length=200)
	#power_to_weight_controller 		= Base.range(2000, 6000, length=200)
	n = length(power_to_weight_motor)

    output       = Vector{Any}(undef, n)
	
	W_battery = zeros(n)
    W_fuel    = zeros(n)
	TotalWeight = zeros(n)
	unusedfuel=zeros(n)
	
	
	for i =1:n
		
		propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, SFC, power_to_weight_motor[i], power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_propulsive_efficiency, η_electric_generator_efficiency)

		
		W_motor = component_weight(propulsion.P_max_engine * ϕ, propulsion.power_to_weight_motor)
        W_controller = component_weight(propulsion.P_max_engine * ϕ / propulsion.η_motor,propulsion.power_to_weight_controller)
        W_PGD= W_motor + W_controller

		
        feasible, num_battery_packs, W_f= batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, aircraft, W_PGD, batt, g, η, μ, LD_takeoff)
		
		if !feasible
			break
		end
	    W_battery[i] = batt.weight*num_battery_packs
        W_fuel[i]    = W_f
		TotalWeight[i]=  W_fuel[i] + aircraft.W_empty + aircraft.W_payload + W_PGD + W_battery[i] ;

	end
end
  ╠═╡ =#

# ╔═╡ dc267ffa-2525-48b1-b6ac-9eccb6827918
#=╠═╡
begin
	ϕ = 0.5
	power_to_weight_motor      		= 5000
	power_to_weight_controller 		= 2000

	TAXI = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ, load1, dVdt1, ρ1)
	TAKEOFF = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ, load2, dVdt2, ρ2)
	CLIMB = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ, load3, dVdt3, ρ3)
	CRUISE = MissionSegment(name4, h4, V4, duration4, ROC4, ϕ, load4, dVdt4, ρ4)
	DESCENT = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ, load5, dVdt5, ρ5)
	LAND = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ, load6, dVdt6, ρ6)
	TAXI2 = MissionSegment(name7, h7, V7, duration7, ROC7, ϕ, load7, dVdt7, ρ7)
	
	FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, DESCENT, LAND, TAXI2]

	g=9.81
	η=1
	Max_iterations=1000

	propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, SFC, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_propulsive_efficiency, η_electric_generator_efficiency)
	
	W_motor = component_weight(propulsion.P_max_engine * ϕ, propulsion.power_to_weight_motor)
    W_controller = component_weight(propulsion.P_max_engine * ϕ / propulsion.η_motor,propulsion.power_to_weight_controller)
    W_PGD= W_motor + W_controller

	feasible, num_battery_packs, W_f = batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, aircraft, W_PGD, batt, g, η, μ, LD_takeoff)

end;

  ╠═╡ =#

# ╔═╡ Cell order:
# ╟─f4515400-d2f0-11f0-a3cd-db9046777251
# ╟─5f1441ea-2158-4b08-98db-7c85b92307d4
# ╟─44d1c167-fc6c-4124-b1ac-5c643308f203
# ╟─4580f93b-25b0-4f41-bdfa-a0cd2f503278
# ╟─a68db7ec-1042-4689-82a4-992963482d76
# ╟─60b6bc84-abac-481d-b547-ac1d9c493ee2
# ╠═87f4784b-323f-47f7-843b-ebe2c247230f
# ╟─7b2fcfee-edf0-4c79-928a-57fcfcb864c8
# ╠═afb4ba00-115c-4a42-a2ca-d4366bbfe021
# ╟─20012e75-c631-47ea-b021-b0e4a0430ed4
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
# ╠═4d6e0c76-2699-426d-9da9-976904e7707f
# ╠═fe6e4969-f985-4123-9ebb-8af530e7e663
# ╠═4b73459d-6f4a-4778-859d-4ebb7a5ff6a0
# ╟─f656498f-5dd6-45fa-9bf7-0255856c7b34
# ╟─04f5332d-8555-40ba-9c34-957fddb89034
# ╠═dc267ffa-2525-48b1-b6ac-9eccb6827918
# ╠═3dc7c369-dc0c-4996-9f80-feb0ec912a35
# ╟─734faa23-3471-491b-bf04-b4464e14fab6
# ╟─3c66a4ae-e98f-47d3-9a2b-748d19e7a839
# ╠═bbdd793a-650c-4176-9c3d-86da99f56458
# ╠═b2c282b2-7914-4c39-acc1-419f91282bbd
# ╟─97ff6cfe-bba1-4aaa-b01d-ca7f6a9ade2e
# ╟─362f16ea-04d2-408d-b9a1-5327ff32bd96
# ╟─2e5cac5e-edd9-497b-b0e1-68607dfaf856
# ╠═d008b166-0841-48b8-86ad-6478ed95be88
# ╠═783b2ab8-25bd-426e-868f-57ce6ae38873
# ╟─87520646-7ec2-4c50-b456-40922945fc13
# ╟─77cc9a93-a94f-419e-826b-739a0b64d245
# ╟─6156c4fb-73ba-4b9f-810e-9d61d58faa1c
# ╠═5b48d066-26fa-484b-b749-8fc207f5867e
# ╠═2979e0b6-c4ef-4bf8-8561-7a3d27d088f1
# ╟─be028496-e829-4d2d-b6ae-468080731524
# ╟─a1a6593e-703b-4113-9fdd-e6dbed800fd2
