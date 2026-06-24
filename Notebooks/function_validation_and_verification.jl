### A Pluto.jl notebook ###
# v0.20.24

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

# ╔═╡ 1d79cd2f-44d1-4db0-82c4-32e252d87b88
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

# ╔═╡ c988186c-8932-416d-8ead-c64a5ea65c88
#=╠═╡
begin
	file_path = "C:\\Users\\sabin\\OneDrive\\Desktop\\FYP\\HybridElectric\\src\\file.txt"
	using DelimitedFiles
	data = readdlm(file_path; skipstart=12)
	data
end
  ╠═╡ =#

# ╔═╡ b2afe8b0-d096-11f0-af04-7574eb00a750
md"# Function Validation and Verification"

# ╔═╡ ca59f52a-0dfc-4708-8418-5fb46252a9e8
md"**Define packages**"

# ╔═╡ 23e41e56-a07a-47c4-bd8d-7cbc30f45c96
md"## Functions"

# ╔═╡ e788f3ac-8e7c-4f44-aee4-e06751b40c52
md"""
| Function 	  	  				| Inputs           				 | Outputs   |
| ---- 			  				| ----- 		     			 | ----- 	 |
| battery| name | usage, company, nominalvoltage, outputcurrent, amperehourcapacity, energystoragecapacity, weight, volume, height, width, depth, radius, cell_energy_density, cell_specific_energy, specific_power, max_voltage, min_voltage, continuous_discharge_rate, continuous_charge_rate|
| packspecificenergy | specificenergy, packagingfactor | packspecificenergy|
| atmosphere 	 		  		| altitude	     	             | T, P, ρ   |
| dragforce 		 	  		| Aircraft, W, g, MissionSegment | D         |
| calculateclcd	 		  		| α				                 | CL, CD    |
| powerrequired 		  	    | drag, V, Weight, g, dVdt, ROC  |P _total _req|
| takeoffpowerrequired | Weight,g, Vtakeoff, μ, dVdt, LD | P_takeoff|
| powersplit 	   			    | P _total _req, ϕ        | P _EM _req, P _FB _req |
| batterypower 	    | P _EM _req, η _motor, η _controller, η _battery | P _battery |
| fuelconsumption 		  		| P _FB _req, SFC, dt  			 | Fuelburn  |
| total _battery _energy _capacity | W _battery, specificenergy      | E _bat     |
| stateofcharge  | SOC _old, P _battery, dt, E _battery _total | SOC _new, E _used |
| component _weight		  		| P _max, power _to _weight         | Weight    |
"""

# ╔═╡ cbfcc143-f63b-4f89-9a09-fe06cea630ab


# ╔═╡ a997018d-634a-4c5e-8db5-b495692f44f5
md" ### battery"

# ╔═╡ d54a0804-006d-4a27-a275-be5cb004ef33
md"""
For this function, the user selects a battery cell from the list of options provided. The function outputs the following features for the selected battery. 

* Typical usage
* Company
* Nominal output voltage (V)
* Continuous output current (max A)
* Ampere-hour capacity (Ah) 
* Energy Storage Capacity (Wh)
* Weight (kg)
* Volume (m^2)
* Height (m)
* Width (m)
* Depth (m)
* Radius (m) if cylindrical
* Cell-level energy density (Wh/m^3)
* Cell-level specific energy (Wh/kg)
* Specific power (W/kg)
* Maximum voltage (V)
* Minimum voltage (V)
* Continuous discharge rate (C-rate)
* Continuous charge rate (C-rate)

The typical usage will be particularly useful for GPB and VPB when calculating the pack specific energy.
"""

# ╔═╡ 6909eef8-8930-40d5-a112-8517ed91fce8
@bind batteryselection Select(["PB345V124E-L"])


# ╔═╡ 07f2b3e8-11f0-4aef-946a-9aaead57befb
batt=battery(batteryselection)

# ╔═╡ 39753a24-2b3c-4205-b752-fb4b69291301
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

# ╔═╡ 379897c5-35d6-44b3-b861-b2995efad223


# ╔═╡ e4ac0d48-6f8e-414b-af94-bdbba09e41f8
md"### Define Inputs: Dornier 328 Example"

# ╔═╡ 566dba61-de02-42b2-9da5-50b9376d87d5
begin
	W_payload = 3671.0;
	W_empty = 8900.0;
    S   = 40.0;
    AR  = 11.0;
    e   = 0.80;
    Cd0 = 0.0220;
	maxfuelweight = 3633.72848
	#cabin area: 42.5m^3
	#cargo volume: 7.8m^3 
	#assume battery volume is half the cargo volume
	maxbatteryvolume = 7.8/2
end;

# ╔═╡ d5dbd3b5-2135-49e9-bc4c-9d785b2d94b1
#=╠═╡
aircraft = Aircraft(MTOW, W_payload, W_empty, S, AR, e, Cd0, maxfuelweight)
  ╠═╡ =#

# ╔═╡ a5c65994-bc7f-4eca-b725-7f8f9ee21ffd
begin
	η_motor                    		= 0.95 #95-97% efficiency   
	η_controller               		= 0.96
	η_battery                  		= 0.95
	specificenergy                  =batt.packspecificenergy
	SOC_min                    		= 0.2
	SFC                        		= 0.332
	power_to_weight_motor      		= 5200
	power_to_weight_controller 		= 3702.70
	W_engine 				   		= 2270.0
	P_max_engine 			   		= 3251252
	No_Engines                 		= 2
	energy_density_fuel       	    = 11900.0
	η_gas_turbine_efficiency 		= 0.35  
	η_gearbox_efficiency 			= 0.95
	η_propulsive_efficiency 		= 0.8
	η_electric_generator_efficiency = 0.98
end;

# ╔═╡ dbc78b24-e597-47b0-95ef-c8aa5cdb7a81
propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_propulsive_efficiency, η_electric_generator_efficiency)

# ╔═╡ be304f17-40e9-447b-a9dc-592a05a3fd47
begin
	name            = "Cruise"
	h   			= 9448.34
	V 				= 202.37
	duration 		= 10741.93548
	ROC 			= 0.0
	ϕ 				= 0.5
	load 			= 1
	dVdt 			= 0.0
	T, P, ρ  = atmosphere(h);
end;

# ╔═╡ c3383805-8465-4650-92fa-c84095b7f1a4
CRUISE = MissionSegment(name, h, V, duration, ROC, ϕ, load, dVdt, ρ, 0.3)

# ╔═╡ 3efc6fc2-dec8-4727-82e1-bf2f65143933


# ╔═╡ f42b2d58-fdcf-4e32-88bf-a4782069ddf8
md"### atmosphere"

# ╔═╡ 406fd9ae-e2cd-4af4-a687-e8ad3e9dcfba
Tval, Pval, ρval = atmosphere(-609.6)

# ╔═╡ 27225595-6533-4691-8949-61add7a05904
Tval1, Pval1, ρval1 = atmosphere(0.0)

# ╔═╡ 9e4a46ea-a99b-4eee-bb03-f77e3332c2b1
Tval2, Pval2, ρval2 = atmosphere(18288.0)

# ╔═╡ 87d623cd-1faa-4fa7-9861-615d06d47f23


# ╔═╡ 37820190-bf34-4493-a275-a30fe835c9c6
md"### dragforce"

# ╔═╡ 9735528a-5b75-4fb6-809c-7134c8bf3f06
md"Define g, can alter depending on the load factor"

# ╔═╡ d40f0ae4-d0c1-402b-9790-fe897f11779b
g=9.81

# ╔═╡ 83c68da1-9867-4f52-8ed6-b77684dafcf7
md"$D = \frac{1}{2} ρ V^2 S C_d$"

# ╔═╡ cfdab272-c3b0-411d-b85a-8f03ac6f4939
#=╠═╡
D = dragforce(aircraft, MTOW, g, CRUISE)
  ╠═╡ =#

# ╔═╡ 24a979f9-7932-4f7d-8459-6ba43f8591a7
md"**Verification**"

# ╔═╡ a5c6a53d-079b-4233-88e0-7c1334356ea6
q=0.5*(CRUISE.ρ)*(CRUISE.V^2)

# ╔═╡ 2a408a96-5684-4cc6-8d0c-ea585ede7748
#=╠═╡
K=1/(π*aircraft.e*aircraft.AR)
  ╠═╡ =#

# ╔═╡ 6e59cd33-3343-4897-9a5b-bad08ab0859d
#=╠═╡
W=MTOW
  ╠═╡ =#

# ╔═╡ f1442b85-e9e6-4289-b730-86faa34e92ce
#=╠═╡
Cl=W*g/(q*aircraft.S)
  ╠═╡ =#

# ╔═╡ a41c320e-fc5b-4893-be41-5ab879d960ca
#=╠═╡
Cd  = aircraft.Cd0 + K*Cl^2 #drag coefficient
  ╠═╡ =#

# ╔═╡ 0190530c-dd77-43f6-bbdd-b824020079ec
#=╠═╡
Drag=0.5*(CRUISE.ρ)*(CRUISE.V^2)*aircraft.S*Cd
  ╠═╡ =#

# ╔═╡ 9de0bc16-ad1f-42ea-a013-a419e116ba24


# ╔═╡ b4b71505-7987-4f7f-aab5-7559a34bb2fa
md"### calculateclcd"

# ╔═╡ e67aff11-db63-4e43-9bec-29b6fd883ac1
md"
minimum α = -15.75
maximum α = 18.750
"

# ╔═╡ 5c5e0657-347a-4eef-ad42-24d228db53fc
#=╠═╡
begin
	alpha = data[:,1]
	CL = data[:,2]
	CD = data[:,3]
end;
  ╠═╡ =#

# ╔═╡ 33244633-2341-47b0-b094-a30d4fa62c67
#=╠═╡
begin
	
	p1 = plot(alpha, CL,
	     xlabel="α",
	     ylabel="CL",
	     title="CL vs α",
	     legend=false,
		 ylims=(-1.2, 1.8))
	
	p2 = plot(alpha, CD,
	     xlabel="α",
	     ylabel="CD",
	     title="CD vs α",
	     legend=false,
		 ylims=(0, 0.1))
	
	plot(p1, p2, layout=(1,2), size=(1200, 400))
end
  ╠═╡ =#

# ╔═╡ f69a98c9-433e-4349-8a1b-f46571a71c43
CLlow, CDlow = calculateclcd(-20) 

# ╔═╡ 881f49f3-7b2f-423b-a0cc-4fd148cb00eb
CLhigh, CDhigh = calculateclcd(20) 

# ╔═╡ 872d7135-8f1e-46a1-b5c1-158c422a8a4b
CLvalid, CDvalid = calculateclcd(0.0) 

# ╔═╡ 861c0a5a-c0e4-4c54-b4a7-903cf23fb60a
md"
The calculateclcd function calculates Cl and Cd at different values of α. It calls up the file containing the data points for the specific airfoil. It uses linear interpolation between the points to determine the value of Cl and Cd. It uses linear extrapolation outside of these points. This makes it unreliable at α far from the data points.
"

# ╔═╡ 2a992d29-5f8d-43e3-ac08-8870ed1fbe1b


# ╔═╡ 88279a24-e19b-4163-98c0-0e363b0409ba
md"### powerrequired"

# ╔═╡ 301e8d6f-3ef1-49a4-9aab-cb9c3d6a93f3
md"
This function is used within the other function formulations. It varies within flight and is used iteratively to validate the sizing. It is defined by the equation below and comes from Cinar. The power output is given in Watts!

$P_{req} = D V+ \frac{d}{dt}  \left(  \frac{W V^2}{2g} + W h  \right)$

Drag component: $P_{drag} = D V$

Kinetic component: $P_{kinetic} = \frac{d}{dt}  \left(  \frac{W V}{g}  \right)$ 

Potential component: $P_{potential} = W g ROC)$
"

# ╔═╡ f350490b-f639-4b41-9c70-2fb91efabbb1
#=╠═╡
P_drag=D*CRUISE.V
  ╠═╡ =#

# ╔═╡ 738d5e91-e491-4cd4-a540-2e14ea72d08f
#=╠═╡
P_kinetic = (MTOW*CRUISE.V/g)*CRUISE.dVdt
  ╠═╡ =#

# ╔═╡ eae68a35-c100-4071-bcd0-a07865a6b3a9
#=╠═╡
P_potential=MTOW*g*CRUISE.ROC
  ╠═╡ =#

# ╔═╡ 59ba8a65-1971-46bf-8c30-177a089c24a8
#=╠═╡
P_total_req = powerrequired(D, CRUISE.V, MTOW, g, CRUISE.dVdt, CRUISE.ROC) 
  ╠═╡ =#

# ╔═╡ 16d236e7-6580-4308-a81a-c219908890e9
md"
The aircraft engines have a maximum take-off power rating of 2x2180 shp which is 3207 kW. This fits what is expected. 

When using this value in the full mission analysis, BEMT function is used to generate an efficiency factor which is used to compute the actual power required.
"

# ╔═╡ 89091c1e-3ee2-44af-ba36-6cd68ed6812f


# ╔═╡ 8ddcb6bf-cd79-454e-89fd-7fd242fd603a
md"### takeoffpowerrequired"

# ╔═╡ dddcca4a-07d9-4c14-8285-7a28a8fd1cbb
md"""
This function is used to compute the power required during takeoff. The following equation was employed.

$P_{takeoff} = m g \left(  μ \left[  1 - \left( \frac{v}{v_{takeoff}}   \right)^2       \right]   +   \frac{1}{L/D} \left( \frac{v}{v_{takeoff}}   \right)^2  +   \frac{a}{g}                          \right)V$


A constant velocity was used during this period. $V=0.7V_{takeoff}$.
"""

# ╔═╡ ff19118c-8cc6-410d-b4e1-c25a60f6879a
begin
	Vtakeoff= 70 
	μ = 0.02
	LD=10
	runwaydistance=1000
end

# ╔═╡ c546b490-f38c-4ee4-bd0c-9f196bb718d0
takeoff = MissionSegment("Takeoff", h, Vtakeoff, Vtakeoff/1000, ROC, ϕ, load, 2, 1.225, 0.3)

# ╔═╡ 129ffe98-1444-43c2-b115-9335fed08816
#=╠═╡
Powerreq=takeoffpowerrequired(MTOW,g, takeoff.V, μ, takeoff.dVdt, LD)
  ╠═╡ =#

# ╔═╡ 03818506-af7e-4151-96e8-4b6b38248d19


# ╔═╡ 65563337-6448-4360-819a-1e227b5eb630
md"### powersplit"

# ╔═╡ f2637223-55ef-412c-bdeb-026e0d7c8c3e
md"
This function is used for the aircraft's power management. It splits the aircraft's Total power requirement into Engine and Battery power requirements using the Hybridization factor ϕ. As different flight stages have different ϕ, it can be adjusted during each flight stage.

$P_{total_{req}}= P_{EM_{req}} + P_{FB_{req}}$

$P_{EM_{req}}=\frac{ϕ}{P_{total_{req}}}$

When ϕ=0 the aircraft uses conventional propulsion.
When ϕ=1 the aircraft uses fully electric propulsion.

The units are the same units that the input $P_{total_{req}}$ is defined as. This correlates to the output the powerrequired function generates! In this case it is Watts.
"

# ╔═╡ e20e4f87-a763-47d6-b252-7e073b1e717e
#=╠═╡
P_EM_req, P_FB_req = powersplit(P_total_req, ϕ) 
  ╠═╡ =#

# ╔═╡ 20df341b-33e0-4460-8607-e40d606fbef4
#=╠═╡
P_EM_req0, P_FB_req0 = powersplit(P_total_req, 0) 
  ╠═╡ =#

# ╔═╡ 29356dd2-61d4-4d99-a69f-1e7466398143
#=╠═╡
P_EM_req1, P_FB_req1 = powersplit(P_total_req, 1) 
  ╠═╡ =#

# ╔═╡ 413fb4e9-13de-4554-9d81-0fd9e6de3f4d


# ╔═╡ 0a8f49c3-b44e-4822-ab89-987c4fcb0f3b
md"### fuelconsumption"

# ╔═╡ ec7818b4-8b15-4d1f-a0e8-8be51ad67be2
md"
This function calculates fuel consumption over a certain flight duration. For example, $P_{FB_{req cruise}}$ is computed from $P_{total_{req cruise}}$. 

The inputs are the engine SFC, segment duration and $P_{FB_{req}}$. SFC must be defined in kg/(kW·h). The computation converts $P_{FB_{req}}$ to kW and the segment duration to hrs.

$Fuel burn = t\times SFC\times P$

The fuel burn is returned with units kg.
"

# ╔═╡ 89970cdb-2fb1-445c-b075-6f78d9f57b21
# ╠═╡ disabled = true
#=╠═╡
Fuelburn = fuelconsumption(P_FB_req, propulsion.SFC, CRUISE.duration)
  ╠═╡ =#

# ╔═╡ 4a671fc1-c2e6-4c24-b8d0-612cdb1acdf2


# ╔═╡ ad1c351a-81df-46de-9fa7-f17802977c0f
md"### batterypower"

# ╔═╡ f0fc5885-dae8-492d-b12d-3358cbd1b41b
md"
This function simply uses the efficiencies of the motor, controller and batteries to determine the actual power required by the batteries.

$P_{battery} = \frac{P_{EM_{req}}}{η_{motor}\times η_{controller}\times η_{battery}}$

Again it returns the same units as the input $P_{EM_{req}}$ which is Watts.
"

# ╔═╡ 658233d5-c8e9-4ff1-ab8a-83f4ae89c8cb
# ╠═╡ disabled = true
#=╠═╡
P_battery = batterypower(P_EM_req, η_motor, η_controller, η_battery) 
  ╠═╡ =#

# ╔═╡ 92b88309-8f6f-443d-a314-bb91807ad0db


# ╔═╡ 532c3f84-7bc5-4f1d-b7ff-6436102a6794
md"### stateofcharge"

# ╔═╡ 0528db34-6696-4f45-95c8-ce699168741b
md"
This function is used to calculate the state of charge at the end of each segment, given the old state of charge. Where $E_{battery}$ is given in Wh.

$SoC(t)= SoC(t_0) - \frac{1}{E_{battery}} \int_{t_0}^{t}    P_{battery}(τ) dτ$

This equation continuous time integral SoC equation was adapted to a discrete equation using the following numerical approximation.

$SoC_{k+1} = SoC_k - \frac{P_k \Delta t}{E_{battery}}$


Note, the input $P_{battery}$ already includes the effects of efficiency losses.
Note, SoC usually have usuable limits ranging from 20% to 100%.
"

# ╔═╡ f2533010-84d9-476f-af78-8113d363ec53
begin
	SOC_old=1.0
	P_battery1=[16.9, 15.3, 14.7, 14.6, 14.5] #watts
	dt1 = [200, 200, 200, 1400] #seconds incremental
	E_battery_total1=3.7*11.3 #Voltage*Ah=Wh

	SOC_history = zeros(5)
	SOC_history[1] = SOC_old
	
	time_history = cumsum([0; dt1]) 
	
	
	for i =2:5
		#while SOC_old >= 0.2
		
		SOC_new, E_used = stateofcharge(SOC_old, P_battery1[i], dt1[i-1], E_battery_total1)
		
		
		SOC_history[i]=SOC_new
		SOC_old = SOC_new 
			
		#end
	end
	
	plot(time_history, SOC_history.*100, xlabel = "Time (s)", ylabel = "State of Charge (SoC) (%)", title = "Battery SoC Evolution", linewidth = 2)
end

# ╔═╡ d5613d7e-0eae-481c-8939-139d864715bf
md"
This plot has been validated against the same features as this paper DOI: 10.5152/tepes.2024.23024
"

# ╔═╡ 6026bd7e-dc5f-4e2c-b30a-63c6133de986


# ╔═╡ 6638f5a6-b243-42c7-b0d6-fe30b1a2f1f1
md"### total battery energycapacity and component weight"

# ╔═╡ f0355b00-7874-4b51-80ce-92a43f104ec4
md"
These following functions are simple equations given below. 

$Total Battery Energy Capacity = Weight of Battery * Specific Energy$ 

Where specific energy is given in Wh/kg and weight of battery is given in kg.

$Component Weight = \frac{P_{max}}{P/W}$

Where P/W is the power to weight ratio of the component to compute the weight of. 

These are simple sizing equations used at the initial sizing stage.

"

# ╔═╡ 5b77b855-89ff-46b3-a435-0a8eb279ec40
W_battery=1000

# ╔═╡ a449e644-8188-450c-9d4a-fb81cd2e1d82
E_bat = batt.energystoragecapacity

# ╔═╡ d90b32c1-a7eb-4732-b8e3-d357a00984a6
begin
	P_max=10000.0
	power_to_weight=10.0
end;

# ╔═╡ 60530e30-e409-4b64-b41a-28527390d864
Weight = component_weight(P_max, power_to_weight)

# ╔═╡ 5a340bcc-74bf-4761-a792-794b2f993c9f
# ╠═╡ disabled = true
#=╠═╡
md"""
MTOW
$(@bind MTOW Slider(5000.0:20000.0, default=13990.0, show_value=true)) kg
"""
  ╠═╡ =#

# ╔═╡ 703b5256-ae37-4e51-b9ea-e62530d89f8e
#=╠═╡
MTOW=13990.0
  ╠═╡ =#

# ╔═╡ Cell order:
# ╟─b2afe8b0-d096-11f0-af04-7574eb00a750
# ╟─ca59f52a-0dfc-4708-8418-5fb46252a9e8
# ╟─1d79cd2f-44d1-4db0-82c4-32e252d87b88
# ╟─23e41e56-a07a-47c4-bd8d-7cbc30f45c96
# ╟─e788f3ac-8e7c-4f44-aee4-e06751b40c52
# ╟─cbfcc143-f63b-4f89-9a09-fe06cea630ab
# ╟─a997018d-634a-4c5e-8db5-b495692f44f5
# ╟─d54a0804-006d-4a27-a275-be5cb004ef33
# ╠═6909eef8-8930-40d5-a112-8517ed91fce8
# ╠═07f2b3e8-11f0-4aef-946a-9aaead57befb
# ╟─39753a24-2b3c-4205-b752-fb4b69291301
# ╟─379897c5-35d6-44b3-b861-b2995efad223
# ╟─e4ac0d48-6f8e-414b-af94-bdbba09e41f8
# ╠═5a340bcc-74bf-4761-a792-794b2f993c9f
# ╠═703b5256-ae37-4e51-b9ea-e62530d89f8e
# ╠═566dba61-de02-42b2-9da5-50b9376d87d5
# ╟─d5dbd3b5-2135-49e9-bc4c-9d785b2d94b1
# ╟─a5c65994-bc7f-4eca-b725-7f8f9ee21ffd
# ╟─dbc78b24-e597-47b0-95ef-c8aa5cdb7a81
# ╟─be304f17-40e9-447b-a9dc-592a05a3fd47
# ╟─c3383805-8465-4650-92fa-c84095b7f1a4
# ╟─3efc6fc2-dec8-4727-82e1-bf2f65143933
# ╟─f42b2d58-fdcf-4e32-88bf-a4782069ddf8
# ╠═406fd9ae-e2cd-4af4-a687-e8ad3e9dcfba
# ╠═27225595-6533-4691-8949-61add7a05904
# ╠═9e4a46ea-a99b-4eee-bb03-f77e3332c2b1
# ╟─87d623cd-1faa-4fa7-9861-615d06d47f23
# ╟─37820190-bf34-4493-a275-a30fe835c9c6
# ╟─9735528a-5b75-4fb6-809c-7134c8bf3f06
# ╟─d40f0ae4-d0c1-402b-9790-fe897f11779b
# ╟─83c68da1-9867-4f52-8ed6-b77684dafcf7
# ╠═cfdab272-c3b0-411d-b85a-8f03ac6f4939
# ╟─24a979f9-7932-4f7d-8459-6ba43f8591a7
# ╠═a5c6a53d-079b-4233-88e0-7c1334356ea6
# ╠═2a408a96-5684-4cc6-8d0c-ea585ede7748
# ╠═6e59cd33-3343-4897-9a5b-bad08ab0859d
# ╠═f1442b85-e9e6-4289-b730-86faa34e92ce
# ╠═a41c320e-fc5b-4893-be41-5ab879d960ca
# ╠═0190530c-dd77-43f6-bbdd-b824020079ec
# ╟─9de0bc16-ad1f-42ea-a013-a419e116ba24
# ╟─b4b71505-7987-4f7f-aab5-7559a34bb2fa
# ╠═c988186c-8932-416d-8ead-c64a5ea65c88
# ╠═e67aff11-db63-4e43-9bec-29b6fd883ac1
# ╠═5c5e0657-347a-4eef-ad42-24d228db53fc
# ╟─33244633-2341-47b0-b094-a30d4fa62c67
# ╠═f69a98c9-433e-4349-8a1b-f46571a71c43
# ╠═881f49f3-7b2f-423b-a0cc-4fd148cb00eb
# ╠═872d7135-8f1e-46a1-b5c1-158c422a8a4b
# ╟─861c0a5a-c0e4-4c54-b4a7-903cf23fb60a
# ╟─2a992d29-5f8d-43e3-ac08-8870ed1fbe1b
# ╟─88279a24-e19b-4163-98c0-0e363b0409ba
# ╟─301e8d6f-3ef1-49a4-9aab-cb9c3d6a93f3
# ╠═f350490b-f639-4b41-9c70-2fb91efabbb1
# ╠═738d5e91-e491-4cd4-a540-2e14ea72d08f
# ╠═eae68a35-c100-4071-bcd0-a07865a6b3a9
# ╠═59ba8a65-1971-46bf-8c30-177a089c24a8
# ╟─16d236e7-6580-4308-a81a-c219908890e9
# ╟─89091c1e-3ee2-44af-ba36-6cd68ed6812f
# ╟─8ddcb6bf-cd79-454e-89fd-7fd242fd603a
# ╟─dddcca4a-07d9-4c14-8285-7a28a8fd1cbb
# ╠═ff19118c-8cc6-410d-b4e1-c25a60f6879a
# ╠═c546b490-f38c-4ee4-bd0c-9f196bb718d0
# ╠═129ffe98-1444-43c2-b115-9335fed08816
# ╟─03818506-af7e-4151-96e8-4b6b38248d19
# ╟─65563337-6448-4360-819a-1e227b5eb630
# ╟─f2637223-55ef-412c-bdeb-026e0d7c8c3e
# ╠═e20e4f87-a763-47d6-b252-7e073b1e717e
# ╠═20df341b-33e0-4460-8607-e40d606fbef4
# ╠═29356dd2-61d4-4d99-a69f-1e7466398143
# ╟─413fb4e9-13de-4554-9d81-0fd9e6de3f4d
# ╟─0a8f49c3-b44e-4822-ab89-987c4fcb0f3b
# ╟─ec7818b4-8b15-4d1f-a0e8-8be51ad67be2
# ╟─89970cdb-2fb1-445c-b075-6f78d9f57b21
# ╟─4a671fc1-c2e6-4c24-b8d0-612cdb1acdf2
# ╟─ad1c351a-81df-46de-9fa7-f17802977c0f
# ╟─f0fc5885-dae8-492d-b12d-3358cbd1b41b
# ╟─658233d5-c8e9-4ff1-ab8a-83f4ae89c8cb
# ╟─92b88309-8f6f-443d-a314-bb91807ad0db
# ╟─532c3f84-7bc5-4f1d-b7ff-6436102a6794
# ╟─0528db34-6696-4f45-95c8-ce699168741b
# ╟─f2533010-84d9-476f-af78-8113d363ec53
# ╟─d5613d7e-0eae-481c-8939-139d864715bf
# ╟─6026bd7e-dc5f-4e2c-b30a-63c6133de986
# ╟─6638f5a6-b243-42c7-b0d6-fe30b1a2f1f1
# ╟─f0355b00-7874-4b51-80ce-92a43f104ec4
# ╠═5b77b855-89ff-46b3-a435-0a8eb279ec40
# ╠═a449e644-8188-450c-9d4a-fb81cd2e1d82
# ╠═d90b32c1-a7eb-4732-b8e3-d357a00984a6
# ╠═60530e30-e409-4b64-b41a-28527390d864
