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
md"# Hybrid Electric Aircraft Demo (run mission)"

# ╔═╡ 5f1441ea-2158-4b08-98db-7c85b92307d4
md"""
This Demo shows how to use the runmission module. The runmission module computes the final state of charge of the mission segment. It also returns true/false depending on whether the mission was successful. 

Below is a summary table of the module inputs.


| Inputs               | Units   | 
|----------------------|---------|
| MissionSegment       | Struct  | 
| Propulsion       | Struct  | 
| Aircraft       | Struct  | 
| g                    | m/s^2   | 
| drag                 | N       | 
| `W_PGD`   | kg   | 
| `W_battery`   | kg   | 
| `W_fuel_initial`    | kg       | 

"""

# ╔═╡ 44d1c167-fc6c-4124-b1ac-5c643308f203
md"**Define Packages**"

# ╔═╡ 3404927e-e10a-447c-8917-89600f442cb9
md"## Define Aircraft Parameters"

# ╔═╡ 0cf0ae61-1fc6-4b7e-8d09-95f0b33bf362
begin
	MTOW= 13990.0;
	W_payload = 3847.0;
	W_empty = 7940.2 ;
    S   = 40.0;
    AR  = 11.0;
    e   = 0.80;
    Cd0 = 0.0220;
end;

# ╔═╡ 415043c5-d227-469a-8b73-bea59e3d6adb
aircraft = Aircraft(MTOW, W_payload, W_empty, S, AR, e, Cd0)

# ╔═╡ a6aecfef-c4ee-4fdd-a593-344209f5f5db
begin
	η_motor                    		= 0.97 #95-97% efficiency   
	η_controller               		= 0.96
	η_battery                 		= 0.95
	specificenergy             		= 250# 250.0
	SOC_min                    		= 0.2
	SFC                        		= 0.332
	power_to_weight_motor      		= 5200
	power_to_weight_controller 		= 3702.70
	W_engine 				   		= 411.4*2
	P_max_engine 			   		= 3251252
	No_Engines                 		= 2
	energy_density_fuel       	    = 11900.0
	η_gas_turbine_efficiency 		= 0.35  
	η_gearbox_efficiency 			= 0.95
	η_propulsive_efficiency 		= 0.8
	η_electric_generator_efficiency = 0.98
end;

# ╔═╡ 9f550590-c2ac-4b7c-a679-e30c9b605cf9
propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, SFC, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_propulsive_efficiency, η_electric_generator_efficiency)

# ╔═╡ ab2abbe5-baa2-4b1c-bfe6-1699a62535a1


# ╔═╡ 07cba5c3-8a95-4f45-bf72-754f6ea76ec1
md"## Define Aircraft Mission Segments"

# ╔═╡ 3b65b3da-e51a-4483-afa3-0fe16afedc9e
md"### Hybridization Ratio"

# ╔═╡ 6523b68d-3ee0-4ea2-8671-b51476dfaedc
ϕ = [0.5, 0.5, 0.0, 0.0, 0.0]

# ╔═╡ 3eb20a1e-0324-4d95-a85f-54830460657e
begin
	ϕ1 				= ϕ[1]
	ϕ2 				= ϕ[2]
	ϕ3 				= ϕ[3]
	ϕ4 				= ϕ[4]
	ϕ5 				= ϕ[5]
end;

# ╔═╡ b9315b34-f28e-4c89-8c06-231b316d0eb7
md"### Taxi"

# ╔═╡ 0b4a6af4-f701-443a-b5e8-393c2b0fb6c7
begin
	name1            = "Taxi"
	h1   			= 0.0
	V1 				= 10.0
	duration1 		= 180.0
	ROC1 			= 0.0
	load1 			= 1.0
	dVdt1 			= 0.0
	T1, P1, ρ1  = atmosphere(h1);
end;

# ╔═╡ 60e25379-1dae-490a-9162-c7d40a168176
TAXI = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ1, load1, dVdt1, ρ1)

# ╔═╡ 00bc0215-39f7-4844-973b-bdad89cc7e45


# ╔═╡ 44f4fafd-2933-4160-817a-5145c08179ce
md"### Takeoff"

# ╔═╡ 04efbcfd-50b0-4cfb-ac84-71840620cc5b
begin
	name2            = "Takeoff"
	h2   			= 457.178
	V2 				= 70.0
	duration2 		= 60 #60 or 30
	ROC2 			= 0.0
	load2 			= 1.0
	dVdt2 			= 0.0
	T2, P2, ρ2  = atmosphere(h2);
end;

# ╔═╡ 7686b8ea-9c1a-42e0-8d46-4aba71c90d2c
TAKEOFF = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ2, load2, dVdt2, ρ2)

# ╔═╡ fd5eff41-ddfb-4ee0-89eb-c97d618e4ece


# ╔═╡ f80a5b88-6688-495d-87a8-4ef2d298c743
md"### Climb"

# ╔═╡ 928b7621-f7e3-40d2-903b-b01b177f7b91
begin
	name3            = "Climb"
	h3   			= 9448.338921
	V3 				= 200.0
	duration3 		= 5.0*60.0 
	ROC3 			= 0.507872016
	load3 			= 1.0
	dVdt3 			= 0.0
	T3, P3, ρ3  = atmosphere(h3);
end;

# ╔═╡ fa920558-669b-4bb0-8e29-d63bc230a9a6
CLIMB = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ3, load3, dVdt3, ρ3)

# ╔═╡ 90777660-1116-4952-b52f-0b70bf3f81fd


# ╔═╡ b6cfbe4d-1def-4179-a180-124717c82126
md"### Cruise"

# ╔═╡ 4c36e0a0-15da-46e3-b9f8-c9c79d1d024e
begin
	name4            = "Cruise"
	h4   			= 9448.34
	V4 				= 202.37
	duration4 		= 10741.93548 #10741.93548  #5000
	ROC4 			= 0.0
	load4 			= 1.0
	dVdt4 			= 0.0
	T4, P4, ρ4  = atmosphere(h4);
end;

# ╔═╡ 6fb7d665-d080-4f3d-a33e-8d90814cb96d
CRUISE = MissionSegment(name4, h4, V4, duration4, ROC4, ϕ4, load4, dVdt4, ρ4)

# ╔═╡ a53354e7-9486-4f0c-b9d8-351cf672c722


# ╔═╡ fe3b451f-e5fe-48a4-b42f-0aaad0b7370e
md"### Land"

# ╔═╡ 6c08dd47-b112-431b-98b4-5826cdc6ffc1
begin
	name5            = "Land"
	h5   			= 457.1776897
	V5 				= 56.6667
	duration5 		= 180.0
	ROC5 			= 0.0
	load5 			= 1.0
	dVdt5 			= 0.0
	T5, P5, ρ5  = atmosphere(h5);
end;

# ╔═╡ ca7c9e94-d932-4869-aa19-57519ae69a58
LAND = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ5, load5, dVdt5, ρ5)

# ╔═╡ 4de09479-85cd-4f80-ba97-112d83c7f2d8


# ╔═╡ b2462ab1-c57a-49e9-95ff-197c79302905
md"### Full Mission Matrix for Function to Iterate Through"

# ╔═╡ 133e4216-a3ee-4dcd-94ec-8f626b6b646d
FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, LAND]

# ╔═╡ 6123bcd5-2a06-407d-b2d8-e95132c514e1


# ╔═╡ 3c66a4ae-e98f-47d3-9a2b-748d19e7a839
md"## Define function input parameters"

# ╔═╡ dac65c45-7226-41ed-a1b5-a24b3cc75cc9
# ╠═╡ show_logs = false
begin
	g=9.81
	η=1
	#W_PGD=100
	phi=0.2
	W_motor = component_weight(propulsion.P_max_engine*2*phi, propulsion.power_to_weight_motor)
	W_controller = component_weight(propulsion.P_max_engine*2*phi/propulsion.η_motor, propulsion.power_to_weight_controller)
	W_PGD= W_motor + W_controller
	
	W_battery=500
	W_fuel_initial = 210
	for i =1:100
		Valid, SOCstate, batterydepleted, leftoverfuel = runmission(FULLMISSION, propulsion, aircraft, W_PGD, W_battery, W_fuel_initial, g, η); 
		if Valid==false
			if batterydepleted==true
				W_battery=W_battery+50;
			end
			if leftoverfuel<=10
				W_fuel_initial = W_fuel_initial+100;
			end
		else
			break
		end
	end
end;

# ╔═╡ 986bce6c-3ef0-42e2-8a80-1da7c9e79611
begin 
	println("battery weight: ", W_battery, "kg")
	println("fuel weight: ", W_fuel_initial, "kg")
	Valid, SOCstate, batterydepleted, leftoverfuel = runmission(FULLMISSION, propulsion, aircraft, W_PGD, W_battery, W_fuel_initial, g, η)
end

# ╔═╡ 4f8d879d-f479-4b1e-a662-a9f692681ad5
md"
Battery Mass = $W_battery kg
Fuel Mass = $W_fuel_initial kg
"

# ╔═╡ adfa7f37-fe55-4456-a5d1-12abfafa4fd4
TotalWeight= W_fuel_initial + aircraft.W_empty + aircraft.W_payload + W_PGD + W_battery 

# ╔═╡ Cell order:
# ╟─f4515400-d2f0-11f0-a3cd-db9046777251
# ╟─5f1441ea-2158-4b08-98db-7c85b92307d4
# ╟─44d1c167-fc6c-4124-b1ac-5c643308f203
# ╟─4580f93b-25b0-4f41-bdfa-a0cd2f503278
# ╟─3404927e-e10a-447c-8917-89600f442cb9
# ╠═0cf0ae61-1fc6-4b7e-8d09-95f0b33bf362
# ╟─415043c5-d227-469a-8b73-bea59e3d6adb
# ╠═a6aecfef-c4ee-4fdd-a593-344209f5f5db
# ╟─9f550590-c2ac-4b7c-a679-e30c9b605cf9
# ╟─ab2abbe5-baa2-4b1c-bfe6-1699a62535a1
# ╟─07cba5c3-8a95-4f45-bf72-754f6ea76ec1
# ╟─3b65b3da-e51a-4483-afa3-0fe16afedc9e
# ╠═6523b68d-3ee0-4ea2-8671-b51476dfaedc
# ╠═3eb20a1e-0324-4d95-a85f-54830460657e
# ╟─b9315b34-f28e-4c89-8c06-231b316d0eb7
# ╠═0b4a6af4-f701-443a-b5e8-393c2b0fb6c7
# ╟─60e25379-1dae-490a-9162-c7d40a168176
# ╟─00bc0215-39f7-4844-973b-bdad89cc7e45
# ╟─44f4fafd-2933-4160-817a-5145c08179ce
# ╠═04efbcfd-50b0-4cfb-ac84-71840620cc5b
# ╟─7686b8ea-9c1a-42e0-8d46-4aba71c90d2c
# ╟─fd5eff41-ddfb-4ee0-89eb-c97d618e4ece
# ╟─f80a5b88-6688-495d-87a8-4ef2d298c743
# ╠═928b7621-f7e3-40d2-903b-b01b177f7b91
# ╟─fa920558-669b-4bb0-8e29-d63bc230a9a6
# ╟─90777660-1116-4952-b52f-0b70bf3f81fd
# ╟─b6cfbe4d-1def-4179-a180-124717c82126
# ╠═4c36e0a0-15da-46e3-b9f8-c9c79d1d024e
# ╟─6fb7d665-d080-4f3d-a33e-8d90814cb96d
# ╟─a53354e7-9486-4f0c-b9d8-351cf672c722
# ╟─fe3b451f-e5fe-48a4-b42f-0aaad0b7370e
# ╠═6c08dd47-b112-431b-98b4-5826cdc6ffc1
# ╟─ca7c9e94-d932-4869-aa19-57519ae69a58
# ╟─4de09479-85cd-4f80-ba97-112d83c7f2d8
# ╟─b2462ab1-c57a-49e9-95ff-197c79302905
# ╟─133e4216-a3ee-4dcd-94ec-8f626b6b646d
# ╟─6123bcd5-2a06-407d-b2d8-e95132c514e1
# ╟─3c66a4ae-e98f-47d3-9a2b-748d19e7a839
# ╠═dac65c45-7226-41ed-a1b5-a24b3cc75cc9
# ╠═986bce6c-3ef0-42e2-8a80-1da7c9e79611
# ╠═4f8d879d-f479-4b1e-a662-a9f692681ad5
# ╠═adfa7f37-fe55-4456-a5d1-12abfafa4fd4
