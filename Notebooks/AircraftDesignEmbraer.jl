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

# ╔═╡ 4580f93b-25b0-4f41-bdfa-a0cd2f503278
# ╠═╡ show_logs = false
begin
	using Pkg
	using Plots
    using PlutoUI
	using LaTeXStrings;
    import PlutoUI: Slider, NumberField, TextField, CheckBox
	Pkg.add("Revise")
	Pkg.develop(path="C:\\Users\\sabin\\OneDrive\\Desktop\\FYP\\HybridElectric")
	using HybridElectric
	using AeroFuse
	TableOfContents()
end

# ╔═╡ 5f1441ea-2158-4b08-98db-7c85b92307d4
md"""

# Embraer E175LR

This demonstration explores the design space of Embraer E175LR.

**Define Packages**
"""

# ╔═╡ a7898977-e7d2-45e4-932e-2305f1c575a6
gr(
	size = (900, 700),  # INCREASE THE SIZE FOR THE PLOTS HERE.
	palette = :tab20    # Color scheme for the lines and markers in plots
)

# ╔═╡ 82ade567-2d6a-4468-a50d-1703eaa88880
md"""
# Aircraft Definition
The aircraft explored in this demonstration will be **Embraer E175LR**, modified to use hybrid electric propulsion.

![Three-perspective of Embraer E175LR](https://forum.worldofairports.com/uploads/default/original/3X/c/f/cfa97c4744b8a291901ede3f410b472317ebf11a.jpeg)
"""

# ╔═╡ 3b868160-f433-4444-b387-8ff444347352
W_payload    =    9900.0 #kg

# ╔═╡ 410d0ccc-953b-4d84-914d-c1d0d9678cb7
# ╠═╡ disabled = true
#=╠═╡
md"""
## Propulsion 
### Propulsion Parameters
| Variable         				  | Value    						| Units |
| ----             				  | ---      						|  ---  |
|η_motor           				  |$η_motor                    		|  -  |
|η_controller      				  |$η_controller           		    |  -  |
|η_battery     					  |$η_battery           		    |  -  |
|specificenergy 				  |$specificenergy            		| Wh/kg   |
|SOC_min                          |$SOC_min               		    |  -  |
|power_to_weight_motor            |$power_to_weight_motor 		    | W/kg   |
|power_to_weight_controller 	  |$power_to_weight_controller	    | W/kg   |
|W_engine 		                  |$W_engine		   		        |  kg  |
|P_max_engine 	                  |$P_max_engine		   		    | W   |
|No_Engines                       |$No_Engines             		    |  -  |
|energy_density_fuel              |$energy_density_fuel   	        | Wh/kg |
|η_gas_turbine_efficiency         |$η_gas_turbine_efficiency		|  -  |
|η_gearbox_efficiency 		      |$η_gearbox_efficiency            |  -  |
|η_propulsive_efficiency          |$η_p                      	    |  -  |
|η_electric_generator_efficiency  |$η_electric_generator_efficiency |  -  |
"""
  ╠═╡ =#

# ╔═╡ 5db55fae-5c62-48d8-a660-bbc6533dad2b
begin
	η_motor                    		= 0.97 #95-97% efficiency   
	η_controller               		= 0.96
	η_battery                 		= 0.95
	SOC_min                    		= 0.2
	W_engine 				   		= 760*2
	P_max_engine 			   		= 64000*2 #N
	#specificenergy             		= batt.packspecificenergy
	power_to_weight_motor      	    = 5200
	power_to_weight_controller 		= 3702.70
	#Note turbofans are thrust rated not power rated so this uses thrust rating of 14,500lbs and takeoff/climb velocity 102.9 m/s 
	No_Engines                 		= 2
	energy_density_fuel       	    = 11900.0
	η_gas_turbine_efficiency 		= 0.35  
	η_gearbox_efficiency 			= 0.95
	η_propulsive_efficiency 		= 0.8
	η_electric_generator_efficiency = 0.98
	η_p=1
end;

# ╔═╡ 06267e89-35b6-432c-8a1b-c1122c9261f6
#=╠═╡
md"""
### Battery Selection

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

# ╔═╡ 2595200d-b5e8-4529-a87a-175b94f74784
@bind batteryselection Select(["PB345V124E-L"])

# ╔═╡ 2f91a7e1-5b5a-4436-89d5-8ea7c559d443
# ╠═╡ disabled = true
#=╠═╡
batt=battery(batteryselection)
  ╠═╡ =#

# ╔═╡ 1f86389e-2a15-4dc8-a8b5-2b187854d8f5
md"""

## Initial Sizing


Compute the following parameters
* Empty Weight Fraction $W_e/W_0$ 
* Fuel Weight Fraction $W_f/W_0$ 
* Initial $W_0$ guess
* Specific Fuel Consumption
* L/D Estimation

For propeller driven aircraft

$Range=\frac{η_p}{c_p} \frac{L}{D} ln\left( \frac{W_0}{W_1}\right)$

### L/D max
An estimate for maximum $L/D$ is given by Raymer.

$A_{wetted}=\frac{b^2}{S_{wett}}=\frac{AR}{ S_{wett}/S_{ref}}$

$L/D_{max} = K_{LD} \sqrt{ \frac{AR}{ S_{wett}/S_{ref}  } }$

The following approximation for wetted area is calculated from the fuselage and empennage surfaces. It does not account for the intersection of surfaces and the fuselage nor the engine nacelles.

For an initial assumption can assume $S_{wett}/S_{ref}=6$ and assume $K_{LD}=15.5$. Note: Can compte actual $S_{wett}/S_{ref}$ later.
"""

# ╔═╡ 31cd5adf-d4df-4846-b5c1-a49c130281b9
md"""

Additionally, for a jet aircraft, $L/D_{max}$ varies for cruise and loiter. Cruise $L/D_{max}= 0.866L/D_{max}$ and Loiter $L/D_{max}=L/D_{max}$

### Specific Fuel Consumption
Embraer E175LR is equipped with 2 General Electric CF34-8E high-bypass turbofan engines. These are rated with a thrust specific fuel consumption of 0.68 lb/(lbf⋅hr).
"""

# ╔═╡ a4f8b5c0-f7d7-4710-87f0-5db6beee4759
begin 
	unitconversion = 0.45359237 / (4.4482216152605 * 3600) #lb_lbf_hr_to_kg_N_s 
	cT_cruise = 0.68*unitconversion #lb/lb/h Raymer
	cT_loiter =  0.45*unitconversion  #lb/lb/h Raymer
	cT_climb = cT_cruise
	cT_descent = 0.2 * cT_cruise
end;

# ╔═╡ dce3767d-acb3-4f35-b54c-2ec84950ad1a
sfccruise=cT_cruise*3.6e6/247.22

# ╔═╡ f764aff5-df7d-4de8-8b39-4c72048779d9
begin
	Range_cruise = 3000000 #4074000  #3,982-4,074km long range  
	# Flying segments: convert from jet TSFC to equivalent kg/(kW·h)
	
    name1            = "Taxi"
    h1               = 0.0
    V1               = 10.0
    duration1        = 180.0
    ROC1             = 0.0
    load1            = 1.0
    dVdt1            = 0.0
    T1, P1, ρ1  = atmosphere(h1)
    ρ1 = round(ρ1, digits=3)
	sfc1             = 0.259 #same as cruise

    name2            = "Takeoff"
	h2               = 457.2
	V2               = 69.45
	duration2        = 45
    ROC2             = 0.0
    load2            = 1.0
    dVdt2            = (V2-0.0)/duration2
	dVdt2 = round(dVdt2, digits=3)
    T2, P2, ρ2  = atmosphere(h2)
    ρ2 = round(ρ2, digits=3)
    μ = 0.02
	sfc2 =0.4987 #same as climb

    name3            = "Climb"
	h3               = 5852.16
	T3, P3, ρ3  = atmosphere(h3)
    ρ3 = round(ρ3, digits=3)
	V3 = 102.9 * sqrt(1.225 / ρ3)
	V3 = round(V3, digits=3)
	duration3        = 18.0 * 60.0 #18 minutes
	ROC3             = 11.43
    load3            = 1.0
    dVdt3            = (V3-V2)/duration3
	sfc3 = cT_climb  * 3.6e6 / V3
    
    name4            = "Cruise"
	V4               = 247.22 #m/s
	h4               = 10668 #m
	duration4        = Range_cruise/V4
    ROC4             = 0.0
    load4            = 1.0
    dVdt4            = 0.0
    T4, P4, ρ4  = atmosphere(h4)
    ρ4 = round(ρ4, digits=3)
	sfc4 = cT_cruise*3.6e6/V4

    name8            = "Land"
	h8               = 457.2
	T8, P8, ρ8  = atmosphere(h8)
	V8 = 83.34 * sqrt(1.225 / ρ8)
	V8 = round(V8, digits=3)
	duration8        = 3*60 			#s 3–5 minutes
	ROC8             = -7.5        # 7.5-12.5m/s  descending
    load8            = 1.0
    dVdt8            = (0.0-V8)/duration8
	dVdt8 = round(dVdt8, digits=3)
    ρ8 = round(ρ8, digits=3)
	sfc8 =cT_descent*3.6e6/V8


	# --- Loiter (30 min reserve) ---
    name5            = "Loiter"
    h5               = 457.178       # low altitude loiter
    V5               = V8        # slow loiter speed (same as land approach)
    duration5        = 1800.0        # 30 mins in seconds
    ROC5             = 0.0
    load5            = 1.0
    dVdt5            = 0.0
    T5, P5, ρ5  = atmosphere(h5)
    ρ5 = round(ρ5, digits=3)
	sfc5 =cT_loiter * 3.6e6 / V5

    # --- Diversion (200 km to alternate airport) ---
    name6            = "Cruise"
    h6               = h4     # same cruise altitude
    V6               = V4      # same cruise speed
    duration6        = 200000.0 / V6   # distance/speed = time in seconds
	duration6 = round(duration6, digits=3)
    ROC6             = 0.0
    load6            = 1.0
    dVdt6            = 0.0
    T6, P6, ρ6  = atmosphere(h6)
    ρ6 = round(ρ6, digits=3)
	sfc6 =  0.259

    # --- Loiter2 (30 min hold at alternate) ---
    name7            = "Loiter2"
    h7               = 457.178
    V7               = V8 
    duration7        = 1800.0        # 30 mins in seconds
    ROC7             = 0.0
    load7            = 1.0
    dVdt7            = 0.0
    T7, P7, ρ7  = atmosphere(h7)
    ρ7 = round(ρ7, digits=3)
	sfc7 =cT_loiter * 3.6e6 / V7

end;

# ╔═╡ 157fcc13-a298-49ce-af0d-3b3b0b10e654
md"""
## Mission Requirements

**Range: $(Range_cruise/1000)km**

|Segment       | TAXI | TAKEOFF| CLIMB | CRUISE | LOITER | DIVERSION | LOITER | LAND |
|--- |---|---| ----- | ------ | ---- |----- | ------ | ---- |
|name  | $name1| $name2| $name3| $name4| $name5| $name6| $name7| $name8|
|Velocity (m/s)| $V1 | $V2 | $V3 | $V4 | $V5 |$V6 | $V7 | $V8 | 
|Duration (s)  | $duration1 | $duration2 | $duration3 | $duration4 | $duration5 |$duration6 | $duration7 | $duration8 |
|ROC (m/s)     | $ROC1 | $ROC2 | $ROC3 | $ROC4 | $ROC5 |$ROC6 | $ROC7 | $ROC8 |
|Load          | $load1 | $load2 | $load3 | $load4 | $load5 |$load6 | $load7 | $load8 |
|dV/dt         | $dVdt1 | $dVdt2 | $dVdt3 | $dVdt4 | $dVdt5 | $dVdt6 | $dVdt7 | $dVdt8 |
|Density       | $ρ1| $ρ2 | $ρ3 | $ρ4 | $ρ5 | $ρ6 | $ρ7 | $ρ8 |
Note: In order for the code to work the name of the cruise segment must be Cruise, the name of the climb segment must be Climb, the name of take-off must be Takeoff and the name of taxi must be Taxi. 

"""

# ╔═╡ 23e24607-ab4c-4ba2-906c-594a3c75edb1
begin
	TAXI_0      = MissionSegment(name1, h1, V1, duration1, ROC1, 0, load1, dVdt1, ρ1, sfc1)
	TAKEOFF_0   = MissionSegment(name2, h2, V2, duration2, ROC2, 0, load2, dVdt2, ρ2, sfc2)
	CLIMB_0     = MissionSegment(name3, h3, V3, duration3, ROC3, 0, load3, dVdt3, ρ3, sfc3)
	CRUISE_0    = MissionSegment(name4, h4, V4, duration4, ROC4, 0, load4, dVdt4, ρ4, sfc4)
	LOITER_0    = MissionSegment(name5, h5, V5, duration5, ROC5, 0, load5, dVdt5, ρ5, sfc5)
	DIVERSION_0 = MissionSegment(name6, h6, V6, duration6, ROC6, 0, load6, dVdt6, ρ6, sfc6)
	LOITER2_0   = MissionSegment(name7, h7, V7, duration7, ROC7, 0, load7, dVdt7, ρ7, sfc7)
	LAND_0      = MissionSegment(name8, h8, V8, duration8, ROC8, 0, load8, dVdt8, ρ8, sfc8)
	FULLMISSION_0=[TAXI_0, TAKEOFF_0, CLIMB_0, CRUISE_0, LOITER_0, DIVERSION_0, LOITER2_0, LAND_0] #this is just for regular no hybridization
end

# ╔═╡ e92478ba-d042-4ef6-9337-309a6b22b1bc
md"""
### Fuel Weight Fraction
As fuel is consumed during flight, it's maximum varies with the mission requirements, so these must be defined beforehand. The mission segment weight fractions are given as:
1) Taxi $W_1/W_{i-1}=0.99$ (Roskam)
2) Takeoff $W_i/W_{i-1}=0.99$ (Roskam)
3) Climb $W_i/W_{i-1}=0.995$ (Roskam)
4) Cruise $W_i/W_{i-1} = e^{-\frac{RC}{V L/D}}$
5) Loiter $W_i/W_{i-1} = e^{-\frac{EC}{L/D}}$
6) Cruise 
7) Loiter 
8) Landing $W_i/W_{i-1}=0.992$ (Roskam)
The aircraft has 1-2% trapped fuel so $W_f/W_0=1.01(1-W_x/W_0)$
"""

# ╔═╡ 21857ef9-8b97-4f36-93e1-ebc0102ccee2
# ╠═╡ disabled = true
#=╠═╡
begin 
	W1_W0 = 0.99
	W2_W1 = 0.99
	
#Climb 
	# L/D during climb - derived from forces in climbing flight
	# In a climb: L = W·cos(γ), D = W·sin(γ) + T... but simplified:
	#γ_climb = asin(CLIMB.ROC / CLIMB.V)           # climb angle (radians)
	#L_D_climb = cos(γ_climb) / (sin(γ_climb) + 1/LD_max)  # approximation
	#Range_climb = CLIMB.V * CLIMB.duration   # m, along flight path
	#W3_W2 = exp(-Range_climb * CLIMB.SFC * g / (  3.6e6*L_D_climb))
	
#Cruise Definition
	V_cruise      = CRUISE_0.V #m/s 663.94357
	L_D_cruise    = LD_max *0.866 
	W4_W3  = exp(-Range_cruise*CRUISE_0.SFC*g/(3.6e6*L_D_cruise))

#Loiter Definition
	Endurance_loiter = 1800 #s 30 mins
	L_D_loiter    = LD_max    
	W5_W4         = exp(-Endurance_loiter*LOITER_0.SFC*g/(3.6e6*L_D_loiter))	
	
#Cruise  Definition diversion 200km to alternate airport
	Range_diversion = 200000.0  # m
    W6_W5 = exp(-Range_diversion * DIVERSION_0.SFC * g / ( 3.6e6*L_D_cruise))

#Loiter Definition
	Endurance_loiter2 = 1800 #s 30 mins
	W7_W6  = exp(-Endurance_loiter2*LOITER2_0.SFC*g/(3.6e6*L_D_loiter))	
	W8_W7 = 0.992


end;
  ╠═╡ =#

# ╔═╡ ba1e355a-b8f8-4c92-933b-c6beefd30f19
# ╠═╡ disabled = true
#=╠═╡
begin
	W7_W0=W1_W0*W2_W1*W4_W3*W5_W4*W6_W5*W7_W6*W8_W7
	Wf_W0=1.02*(1-W7_W0) 
end
  ╠═╡ =#

# ╔═╡ ffab5d4b-27ce-4824-ac52-3bcec9915aa3
md"""
### $W_0$ Convergence
The convergence of $W_0$ is based on an initial guess and regression data. It combines both equations $W_0 = \frac{W_{crew}+W_{payload}}{1- \left(\frac{W_f}{W_0} \right)- \left(\frac{W_e}{W_0} \right)  }$ and $W_e=AW^C_0$. 

Embraer E175LR is characterised as jet transport aircraft. Thus A=1.02 and C=-0.06.
"""

# ╔═╡ e1f3fbbc-eb25-4007-b26a-ead32a6d2bd0
# ╠═╡ disabled = true
#=╠═╡
begin 
	W0_guess = 10000 
	A=1.02                
	C=-0.06
	W_payload    =    9900.0 #kg
end;
  ╠═╡ =#

# ╔═╡ 05c6512c-e85c-4cf2-9e17-e6128d61182f
# ╠═╡ disabled = true
# ╠═╡ skip_as_script = true
#=╠═╡
W0, weights, iterations=weight_iteration(A, C, W_payload, Wf_W0, W0_guess)
  ╠═╡ =#

# ╔═╡ a206f8b9-d8db-4551-94ba-be0f54e020ec
# ╠═╡ disabled = true
#=╠═╡
plot(iterations, weights,
	     xlabel = "Iteration",
	     ylabel = "W₀ (kg)",
	     marker = :circle,
		 title = "W₀ Convergence",
	     legend = false)
  ╠═╡ =#

# ╔═╡ ce7c8d19-fcdd-4d4c-981b-39b55012daca
# ╠═╡ disabled = true
#=╠═╡
W0 #check MTOW= 38800 kg
  ╠═╡ =#

# ╔═╡ 47878d15-3650-432b-83ff-830912523cc2
# ╠═╡ disabled = true
#=╠═╡
begin
	#empty weight remains fixed
		We_W0=A*(W0)^(C) #lbs
	    We = We_W0 * W0 
end;
  ╠═╡ =#

# ╔═╡ a4627a97-111c-486d-8313-1fe8600ab659
# ╠═╡ disabled = true
#=╠═╡
We #W_empty =  21700 kg kg  check
  ╠═╡ =#

# ╔═╡ 4487ac73-a7f2-4462-8e34-c64f3c3776f6
# ╠═╡ disabled = true
#=╠═╡
Wf_W0*W0
  ╠═╡ =#

# ╔═╡ 26b5f967-35c6-4ec0-8cd2-a1eeb2091feb
# ╠═╡ disabled = true
#=╠═╡
begin
CruiseMax=7709e3
	lambda=[0.2]#[0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1]
	ϕ=0.02#, 0.04]
	n=length(lambda)
		Embraer02range = fill(NaN, n)
		Embraer02packs = fill(NaN, n)
		Embraer02fuel =fill(NaN, n)



for (i,λ) in enumerate(lambda)

	CruiseRange=1651
	while CruiseRange<=CruiseMax
	

	duration4_new = CruiseRange / V4

	TAXI      = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ, load1, dVdt1, ρ1, sfc1)
	TAKEOFF   = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ, load2, dVdt2, ρ2, sfc2)
	CLIMB     = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ, load3, dVdt3, ρ3, sfc3)
	CRUISE    = MissionSegment(name4, h4, V4, duration4_new, ROC4, ϕ, load4, dVdt4, ρ4, sfc4)
	LAND      = MissionSegment(name8, h8, V8, duration8, ROC8, ϕ, load8, dVdt8, ρ8, sfc8)
	LOITER    = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ, load5, dVdt5, ρ5, sfc5)
	DIVERSION = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ, load6, dVdt6, ρ6, sfc6)
	LOITER2   = MissionSegment(name7, h7, V7, duration7, ROC7, ϕ, load7, dVdt7, ρ7, sfc7)  

	
		batt=battery(batteryselection)
		

		W_payload2=W_payload*(1-λ)
		maxbatteryvolume = PayloadVolume*λ #m^3
		Embraer2 = Aircraft(MTOW, W_payload2, W_empty, Sref, AR, e, Cd0, maxfuelweight)
	
				
				
		specificenergy = batt.packspecificenergy
		propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_p, η_electric_generator_efficiency)
			
	
		FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, LOITER, DIVERSION, LOITER2, LAND]
		
		η=1
		Max_iterations=10000
			
		W_motor = component_weight(propulsion.P_max_engine * ϕ, propulsion.power_to_weight_motor)
		W_controller = component_weight(propulsion.P_max_engine *ϕ / propulsion.η_motor,propulsion.power_to_weight_controller)
		W_PGD= W_motor + W_controller
	
		
		feasible, num_battery_packs, FuelWeight = batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, Embraer2, W_PGD, batt, maxbatteryvolume, g, η, μ, LD_max; turbofan=true)
		
		if feasible
			Embraer02range[i] = CruiseRange
			Embraer02packs[i] = num_battery_packs
			Embraer02fuel[i]  = FuelWeight
			CruiseRange+=1000
		else
			break
		end
	end
	end
end


  ╠═╡ =#

# ╔═╡ 4b72da8b-fe1b-4989-8c9f-e3ca5ea9a426
# ╠═╡ disabled = true
#=╠═╡
Embraer02range
  ╠═╡ =#

# ╔═╡ 0d7f8682-2070-41e3-83bd-b7baafb11bfd
# ╠═╡ show_logs = false
#=╠═╡
begin



	duration4_new = CruiseRange / V4

	TAXI      = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ, load1, dVdt1, ρ1, sfc1)
	TAKEOFF   = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ, load2, dVdt2, ρ2, sfc2)
	CLIMB     = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ, load3, dVdt3, ρ3, sfc3)
	CRUISE    = MissionSegment(name4, h4, V4, duration4_new, ROC4, ϕ, load4, dVdt4, ρ4, sfc4)
	LAND      = MissionSegment(name8, h8, V8, duration8, ROC8, ϕ, load8, dVdt8, ρ8, sfc8)
	LOITER    = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ, load5, dVdt5, ρ5, sfc5)
	DIVERSION = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ, load6, dVdt6, ρ6, sfc6)
	LOITER2   = MissionSegment(name7, h7, V7, duration7, ROC7, ϕ, load7, dVdt7, ρ7, sfc7)  

	
		batt=battery(batteryselection)
		

		W_payload2=W_payload*(1-λ)
		maxbatteryvolume = PayloadVolume*λ #m^3
		Embraer2 = Aircraft(MTOW, W_payload2, W_empty, Sref, AR, e, Cd0, maxfuelweight)
	

		specificenergy=batt.packspecificenergy
		propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_p, η_electric_generator_efficiency)
			
	
		FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, LOITER, DIVERSION, LOITER2, LAND]
		
		η=1
		Max_iterations=10000
			
		W_motor = component_weight(propulsion.P_max_engine * maximum(ϕ), propulsion.power_to_weight_motor)
		W_controller = component_weight(propulsion.P_max_engine * maximum(ϕ) / propulsion.η_motor,propulsion.power_to_weight_controller)
		W_PGD= W_motor + W_controller
	
		
		feasible, num_battery_packs, FuelWeight = batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, Embraer2, W_PGD, batt, maxbatteryvolume, g, η, μ, LD_max; turbofan=true)

end

  ╠═╡ =#

# ╔═╡ 0a41ad33-202c-493c-b444-34036e27d1a4
# ╠═╡ disabled = true
#=╠═╡
begin
	payload_fraction = [0.9, 0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1,0]

	fuel_constraint = maxfuelweight # kg
	
	unmodified_range_model = [0.0, 3129, 4607.9, 5499]
	unmodified_payload_model = [1, 1, 0.7843, 0]
	
Embraer01range= [0,2570, 3099, 3585, 4125, 4621, 4775, 4891, 5006, 5121, 5236]
Embraer01packs= [0,  26,   29,   33,   36,   39,   40,   40,   40,   40,   40]
Embraer01fuel = [0,6316, 7090, 7792, 8566, 9254, 9334, 9334, 9334, 9334, 9334]

Embraer02range= [0,1651, 2260, 2685, 3070, 3493, 3901, 4313, 4733, 4848, 4956]
Embraer02packs= [0,  37,   46,   52,   58,   63,   69,   74,   80,   80,   80]
Embraer02fuel = [0,4830, 5796, 6424, 6982, 7586, 8170, 8742, 9336, 9336, 9336]

Embraer04range= [0,  416, 1337, 1620, 1905, 2191, 2479, 2769, 3061, 3354, 3649]
Embraer04packs= [0,   37,   67,   75,   83,   91,   99,  107,  115,  123,  131]
Embraer04fuel = [0, 2768, 4352, 4766, 5180, 5594, 6008, 6422, 6836, 7250, 7664]
	


end
  ╠═╡ =#

# ╔═╡ b241444a-4617-463e-a074-5df02da50716
# ╠═╡ disabled = true
#=╠═╡
begin
	xt = collect(0:1000:5000)
    yt = collect(0:0.25:1)

p = plot(
    xlabel = L"\mathrm{Range}\;(\mathrm{km})",
    ylabel = L"\mathrm{Payload}\;(1-\lambda)",
    legend = :outerbottom,
    legendcolumns = 4,

    linewidth = 5,
    marker = :circle,
    markersize = 3,
    grid = true,

    tickfontsize = 27,
    guidefontsize = 27,
    legendfontsize = 20,

    xticks = (xt, latexstring.(string.(xt))),
    yticks = (yt, latexstring.(string.(yt))),

    #size = (900, 650),
	left_margin = 2 * Plots.PlotMeasures.mm
)

plot!(p,unmodified_range_model, unmodified_payload_model, label = L"{\phi = 0.00}",	lw = 3,marker = :diamond, color=:blue)
plot!(p,Embraer01range,payload_fraction,label = L"{\phi = 0.01}",lw=3, marker=:circle)
plot!(p,Embraer02range,payload_fraction,label = L"{\phi = 0.02}",lw=3, marker=:circle)
plot!(p,Embraer04range,payload_fraction,label = L"{\phi = 0.04}",lw=3, marker=:circle)
	


	p

savefig(p, "Embraer Edited Payload Range.svg")
end

  ╠═╡ =#

# ╔═╡ cdc9f49d-fe85-4600-aefc-045dd0d4cee4
# ╠═╡ disabled = true
#=╠═╡
begin


	xt = collect(0:1000:5000)
    yt = collect(0:2000:8000)
	p = plot(
		xlabel = L"\mathrm{Range}\;\mathrm{(km)}",
		ylabel = L"\mathrm{Fuel}\;\mathrm{(kg)}",
		legend = :bottomright,
		linewidth = 5,
		#legendcolumns=2,
		#ylims=[0,4000],
		#xlims=[0, 3500],
		marker = :circle,
		grid = true,
		tickfontsize = 27,
        guidefontsize = 27,
		xticks = (xt, latexstring.(string.(xt))),
    	yticks = (yt, latexstring.(string.(yt))),
        legendfontsize = 20,
	)

plot!(p,Embraer01range,Embraer01fuel,label = L"{\phi = 0.01}",lw=3, marker=:circle)
plot!(p,Embraer02range,Embraer02fuel, label = L"{\phi = 0.02}",lw=3, marker=:circle)
plot!(p,Embraer04range,Embraer04fuel, label = L"{\phi = 0.04}",lw=3, marker=:circle)


	hline!(p,[fuel_constraint],	label = L"\mathrm{Fuel\ capacity\ limit}",
		linestyle = :dash,
		lw = 2
	)


	#savefig(p, "Embraer Payload Range Fuel.svg")
end

  ╠═╡ =#

# ╔═╡ dcbee5b2-8690-4304-a72c-ddfa1d307637
# ╠═╡ disabled = true
#=╠═╡
begin

	xt = collect(0:1000:5000)
    yt = collect(0:20:130)
	p = plot(
		xlabel = L"\mathrm{Range}\;\mathrm{(km)}",
		ylabel = L"\mathrm{Number\ of\ battery\ packs}",
		legend = :topleft,
		linewidth = 5,
		
		#ylims=[0,4000],
		#xlims=[0, 3500],
		marker = :circle,
		grid = true,
		tickfontsize = 27,
        guidefontsize = 27,
		xticks = (xt, latexstring.(string.(xt))),
    	yticks = (yt, latexstring.(string.(yt))),
        legendfontsize = 20,
	)

plot!(p,Embraer01range,Embraer01packs,label = L"{\phi = 0.01}",lw=3, marker=:circle)
plot!(p,Embraer02range,Embraer02packs, label = L"{\phi = 0.02}",lw=3, marker=:circle)
plot!(p,Embraer04range,Embraer04packs, label = L"{\phi = 0.04}",lw=3, marker=:circle)

	
savefig(p, "Embraer Payload Range Batteries.svg")
end

  ╠═╡ =#

# ╔═╡ e8316533-6102-4ea6-8753-04dc5a95ac23
md"""
# Battery Sizing Methodology

## Hybridization Ratio
The Hybridization ratio is defined as 

$ϕ=\frac{P_{EM}}{P_{EM}+P_{FB}}$

so when ϕ=1 it is a fully electric aircraft and when ϕ=0 it is a conventional aircraft.

"""

# ╔═╡ 8905bd96-68d4-4bb8-8a63-c7fa608da3f4
# ╠═╡ disabled = true
#=╠═╡
begin
	
	ϕ1 				= ϕ[1]
	ϕ2 				= ϕ[2]
	ϕ3 				= ϕ[3]
	ϕ4 				= ϕ[4]
	ϕ5 				= ϕ[5]
	ϕ6 				= ϕ[6]
	ϕ7 				= ϕ[7]
	ϕ8 				= ϕ[8]
end
  ╠═╡ =#

# ╔═╡ 6121f5f8-c2eb-49e9-9cf2-cccfe8d9b96b
md"""
## Battery Geometry Constraints

Since we are retrofitting an existing aircraft, the geometry is constrained. Need to define how much space will be available for the battery and how much payload we need to sacrifice.
"""

# ╔═╡ fad3fa47-f041-4d28-819e-2e7063076180
# ╠═╡ disabled = true
#=╠═╡
maxbatteryvolume = PayloadVolume*λ #m^3
  ╠═╡ =#

# ╔═╡ 0726a457-7f34-43bd-b489-c7748c186b4a
md"## Battery Sizing"

# ╔═╡ d148f775-dc7f-4622-aff5-5607fa8e33b9
# ╠═╡ disabled = true
#=╠═╡
begin 
	#redefine with less payload
	ϕ=0.01
	W_payload2=W_payload*(1-0.4)
	maxbatteryvolume=PayloadVolume*(0.4)
	Embraer2 = Aircraft(MTOW, W_payload2, W_empty, Sref, AR, e, Cd0, maxfuelweight)
	TAXI      = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ, load1, dVdt1, ρ1, sfc1)
	TAKEOFF   = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ, load2, dVdt2, ρ2, sfc2)
	CLIMB     = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ, load3, dVdt3, ρ3, sfc3)
	CRUISE    = MissionSegment(name4, h4, V4, duration4, ROC4, ϕ, load4, dVdt4, ρ4, sfc4)
	LOITER    = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ, load5, dVdt5, ρ5, sfc5)
	DIVERSION = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ, load6, dVdt6, ρ6, sfc6)
	LOITER2   = MissionSegment(name7, h7, V7, duration7, ROC7, ϕ, load7, dVdt7, ρ7, sfc7)  
	LAND      = MissionSegment(name8, h8, V8, duration8, ROC8, ϕ, load8, dVdt8, ρ8, sfc8)
	FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, LOITER, DIVERSION, LOITER2, LAND]
	η=1
	Max_iterations=50000
	batt=battery(batteryselection)
	specificenergy = batt.packspecificenergy
	propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_p, η_electric_generator_efficiency)
	W_motor = component_weight(propulsion.P_max_engine * maximum(ϕ), propulsion.power_to_weight_motor)
    W_controller = component_weight(propulsion.P_max_engine * maximum(ϕ) / propulsion.η_motor,propulsion.power_to_weight_controller)
    W_PGD= W_motor + W_controller
	
	feasible, num_battery_packs, W_f = batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, Embraer2, W_PGD, batt, maxbatteryvolume, g, η, μ, LD_max;turbofan=true)
end
  ╠═╡ =#

# ╔═╡ c574a8bd-77d9-4f2c-b750-4407d472543d
# ╠═╡ disabled = true
#=╠═╡
begin
	W_batt=batt.weight*num_battery_packs
	TotalWeight= W_f + Embraer.W_empty + Embraer2.W_payload + W_PGD + W_batt 
	println("Total aircraft weight: ", TotalWeight, "kg")
	
	
	#println("battery weight: ", W_batt, "kg")
	println("no. batteries:", num_battery_packs)
	println("fuel weight: ", W_f, "kg")
	
	Valid, SOCstate, batterydepleted, leftoverfuel = runmission(FULLMISSION, propulsion, Embraer2, W_PGD, batt, num_battery_packs, W_f, g, η, μ, LD_max; turbofan=true)
end
  ╠═╡ =#

# ╔═╡ c4b26590-6b14-4b0e-9da9-55a0f6bed709
# ╠═╡ disabled = true
#=╠═╡
begin 
	#ϕ = [0.0, 0.0, 0.0, 0.0, 0.0,0.0, 0.0, 0.0]
	a=0.0
	ϕ = [a, a, a, a, a, a, a, a] 					#no. 1
	#ϕ = [a, a, a, 0.0, 0.0, 0.0, 0.0, a] 			#no. 2
	#ϕ = [0.0, 0.0, 0.0, 0.0, a,a, a, 0.0]    		#no. 3
	#ϕ = [a, a, 0.0, 0.0, 0.0,0.0, 0.0, a]           #no. 4
	#ϕ = [0.0, 0.0, 0.0, a, 0.0,0.0, 0.0, 0.0]      #no. 5
end;
  ╠═╡ =#

# ╔═╡ c45f595d-6803-4452-9602-28099e37f733
# ╠═╡ disabled = true
#=╠═╡
λ=1 #% decrease in payload! amount allocated for battery!
  ╠═╡ =#

# ╔═╡ 54973b29-8dc0-4e97-b7ea-b641f19d90b5
# ╠═╡ disabled = true
#=╠═╡
begin
	#weight=72
	#packspecificenergy = 600
	batt=battery(batteryselection)
	#batt = (
	#packspecificenergy = packspecificenergy,  #Wh/kg
	#weight = weight,
	#energystoragecapacity=weight*packspecificenergy,
    #maxcontinuouspower=40000,
	#volume = 0.05426,
	#nominalvoltage = 345
	#)

end
  ╠═╡ =#

# ╔═╡ f84f3b6a-2218-48fb-bb13-66bf3c3ef84a
# ╠═╡ disabled = true
#=╠═╡
Modified.ranges
  ╠═╡ =#

# ╔═╡ a04bbcbc-fdc2-4a88-9e4f-c02f734614d5
# ╠═╡ disabled = true
#=╠═╡
Modified.payloads
  ╠═╡ =#

# ╔═╡ 3086f9ce-2a31-43cb-828c-9ac7729700dd
# ╠═╡ disabled = true
#=╠═╡
begin
	UnModified= PayloadRange(Embraer, propulsion, g, L_D_cruise; sfc_cruise=CRUISE.SFC)
	
	ModifiedAircraft=Aircraft(MTOW, Embraer2.W_payload , W_empty, Sref, AR, e, Cd0, maxfuelweight) #battery weight: 576.0kg, fuel weight: 7402.0kg, Total aircraft weight: 32245.239952601103kg
	Modified= PayloadRange(ModifiedAircraft, propulsion, g, L_D_cruise;W_batt=W_batt, sfc_cruise=CRUISE.SFC, W_PGD=W_PGD)
	
end
  ╠═╡ =#

# ╔═╡ 04d523cc-29a6-4d9a-99a9-e36dd451b06c
# ╠═╡ disabled = true
#=╠═╡
begin
	plot(UnModified.ranges, UnModified.payloads, 
	     xlabel="Range (km)", ylabel="Payload (kg)",
	     title="Payload-Range Diagram (Breguet Range Equation)",
	     marker=:circle, 
		label ="Unmodified Embraer E175LR")
			
	plot!(Modified.ranges, Modified.payloads, marker=:circle, label ="Modified Embraer E175LR")


end
  ╠═╡ =#

# ╔═╡ 1a4f5679-5540-460c-8992-94a943317f29
md"""
## Sensitivity Study 
(Battery Specific Energy vs Fuel Savings)
"""

# ╔═╡ 1ceed2b5-ce59-451b-822b-b73c5dbeb186
# ╠═╡ disabled = true
#=╠═╡
NumberofBatteries
  ╠═╡ =#

# ╔═╡ 61dcd57e-d519-4ab5-9313-a97d539fd852
# ╠═╡ disabled = true
#=╠═╡
begin
	Hybridization=[0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.1]
	BatterySpecificEnergy = [100, 200, 300, 400, 500, 600,700, 800, 900, 1000]

	NumberofBatteries = [
	    42   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
	    21    42   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
	    14    28    42    58   NaN   NaN   NaN   NaN   NaN   NaN
	    11    21    31    42    54   NaN   NaN   NaN   NaN   NaN
	     8    17    25    34    42    51    61   NaN   NaN   NaN
	     7    14    21    28    35    42    50    57    65   NaN
	     6    12    18    24    30    36    42    49    55    62
	     5    11    16    21    26    31    37    42    48    53
	     5     9    14    18    23    28    33    37    42    47
	     4     8    13    17    21    25    29    33    38    42
	]

FuelSavings = [
    -5.7535959974984365    NaN                    NaN                    NaN                    NaN                    NaN                    NaN                    NaN                    NaN                    NaN
    -2.282676672920575    -4.596622889305816      NaN                    NaN                    NaN                    NaN                    NaN                    NaN                    NaN                    NaN
    -1.1569731081926204   -2.313946216385241     -3.4709193245778613    -5.003126954346467      NaN                    NaN                    NaN                    NaN                    NaN                    NaN
    -0.6566604127579738   -1.1569731081926204    -1.657285803627267     -2.345215759849906     -3.158223889931207      NaN                    NaN                    NaN                    NaN                    NaN
    -0.18761726078799248  -0.5315822388993121    -0.7191994996873046    -1.0318949343339587    -1.188242651657286     -1.5009380863039399    -2.0012507817385865     NaN                    NaN                    NaN
    -0.031269543464665414 -0.06253908692933083   -0.06253908692933083   -0.06253908692933083   -0.06253908692933083   -0.06253908692933083   -0.2188868042526579    -0.18761726078799248   -0.31269543464665417    NaN
     0.12507817385866166   0.2501563477173233     0.40650406504065045    0.5628517823639775     0.7191994996873046     0.8755472170106317     1.0631644777986242     1.0944340212632897     1.3133208255159476     1.344590368980613
     0.28142589118198874   0.40650406504065045    0.7191994996873046     1.0318949343339587     1.344590368980613      1.657285803627267      1.8449030644152593     2.1888680425265794     2.407754846779237      2.7517198248905568
     0.28142589118198874   0.7191994996873046     1.0318949343339587     1.5009380863039399     1.813633520950594      2.1263289555972484     2.470293933708568      2.9706066291432145     3.314571607254534      3.6898061288305186
     0.4377736085053158    0.8755472170106317     1.188242651657286      1.657285803627267      2.1263289555972484     2.5953721075672296     3.095684803001876      3.595997498436523      3.9399624765478425     4.471544715447155
]


end
  ╠═╡ =#

# ╔═╡ d26d62f8-349e-4a35-86a2-f5170d42281a
# ╠═╡ disabled = true
#=╠═╡
begin
   # Y = FuelSavings[:, 1, :]   # all battery energies, first lambda, all hybridization values
	#cols = 2:2:size(FuelSavings, 2)
	#Y = FuelSavings[:, cols]
	#Y = NumberofBatteries[:, cols]
    #Hybridization_plot = Hybridization[cols]

    labels = reshape([latexstring("\\phi = ", ϕ) for ϕ in Hybridization],1, : )
	xt = BatterySpecificEnergy
    yt = collect(-5:1:5)   # change this range depending on your values

    
xt = collect(200:100:1000)
yt = collect(-2:1:4)   # adjust depending on your fuel savings range


    p = plot(
        BatterySpecificEnergy,
        FuelSavings,
        xlabel = L"\mathrm{Battery\ specific\ energy}\;(\mathrm{Wh\,kg^{-1}})",
        ylabel =  L"\mathrm{Fuel\ saving}\;(\%)",
        label = labels,
		xlims=[200,1050],
		ylims=[-2.7,5],
        marker = :circle,
        markersize = 4,
        linewidth = 2,
        grid = true,
		#legendcolumns=2,
        legend = :topleft,
        tickfontsize = 15,
        guidefontsize = 15,
		xticks = (xt, latexstring.(string.(xt))),
    	yticks = (yt, latexstring.(string.(yt))),
        legendfontsize = 15,

    )

    hline!(p,[0],linestyle = :dash, linewidth = 2,label = L"\mathrm{Break\ even}")

    p

	#savefig(p, "HybridizationandBatteryFuel.svg")
	#savefig(p, "HybridizationandBatteryFuelNoBatteries.svg")
	#savefig(p, "HybridizationandBatteryFuelAppendix.svg")
end
  ╠═╡ =#

# ╔═╡ 48c1ae8c-5ee9-4473-98ab-4d2c1014a1ec


# ╔═╡ 4d2501b7-45be-4013-9ef5-6abb420d9fdd
md"## Adjustment of Payload Weight and Hybridization"

# ╔═╡ e15e06ee-409d-4d99-b498-289102d74752
# ╠═╡ disabled = true
#=╠═╡
begin
	Lambda = 0.0:0.01:1.0
	Hybridization=[0.01,0.02, 0.03, 0.04]
	Hybr=length(Hybridization)
	BatterySpecificEnergy = [152.78]#, 300, 500, 700] # Wh/kg

	
	nE = length(BatterySpecificEnergy)
 
	MaxPayloadFactor = fill(NaN, Hybr, nE)
	#FuelWeightResult = fill(NaN, Hybr, nE)
	NumberofBatteries = fill(NaN, Hybr, nE)
	η=1
	Max_iterations=10000
	
for (i, ϕ) in enumerate(Hybridization)

TAXI      = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ, load1, dVdt1, ρ1, sfc1)
	TAKEOFF   = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ, load2, dVdt2, ρ2, sfc2)
	CLIMB     = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ, load3, dVdt3, ρ3, sfc3)
	CRUISE    = MissionSegment(name4, h4, V4, duration4, ROC4, ϕ, load4, dVdt4, ρ4, sfc4)
	LAND      = MissionSegment(name8, h8, V8, duration8, ROC8, ϕ, load8, dVdt8, ρ8, sfc8)
	LOITER    = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ, load5, dVdt5, ρ5, sfc5)
	DIVERSION = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ, load6, dVdt6, ρ6, sfc6)
	LOITER2   = MissionSegment(name7, h7, V7, duration7, ROC7, ϕ, load7, dVdt7, ρ7, sfc7) 


FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, LOITER, DIVERSION, LOITER2, LAND]

		
	
	for (j, packspecificenergy) in enumerate(BatterySpecificEnergy)
		found=false
		weight=72
			batt = (
			packspecificenergy = packspecificenergy,  #Wh/kg
			weight = weight,
			energystoragecapacity=weight*packspecificenergy,
			maxcontinuouspower=40000,
			volume = 0.05426,
			nominalvoltage = 345
		)

	specificenergy = batt.packspecificenergy
		propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_p, η_electric_generator_efficiency)
	
		W_motor = component_weight(propulsion.P_max_engine * ϕ, propulsion.power_to_weight_motor)
		W_controller = component_weight(propulsion.P_max_engine * ϕ / propulsion.η_motor,propulsion.power_to_weight_controller)
		W_PGD= W_motor + W_controller
		
		
		for λ in Lambda
		
		W_payload2=W_payload*(1-λ)
		maxbatteryvolume = PayloadVolume*λ #m^3
		Embraer2 = Aircraft(MTOW, W_payload2, W_empty, Sref, AR, e, Cd0, maxfuelweight)
	
			
	
		#EDITED AIRCRAFT
		feasible, num_battery_packs, FuelWeight = batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, Embraer2, W_PGD, batt, maxbatteryvolume, g, η, μ, LD_max;turbofan=true)
				
		
		if feasible
			MaxPayloadFactor[i,j]=λ
			NumberofBatteries[i,j]=num_battery_packs
			#FuelWeightResult[i,j]=FuelWeight
			found=true
			break
		end
		end
		if !found
			println("No feasible lambda found for phi = $ϕ and e_batt = $packspecificenergy")
		end
	
	end		
	end
		
end 

  ╠═╡ =#

# ╔═╡ 6405b872-9cc8-4e8a-950d-9a647cefef9e
# ╠═╡ disabled = true
#=╠═╡
begin
	Hybridization=[0.01,0.02, 0.03, 0.04]
	Hybr=length(Hybridization)
	BatterySpecificEnergy = [152.78]#, 300, 500, 700] # Wh/kg

	
	nE = length(BatterySpecificEnergy)
 
	MaxPayloadFactor = fill(NaN, Hybr, nE)
	NumberofBatteries = fill(NaN, Hybr, nE)
	η=1
	Max_iterations=10000
	
	

     #   for (j, λ) in enumerate(Lambda)
for (i, ϕ) in enumerate(Hybridization)
	TAXI      = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ, load1, dVdt1, ρ1, sfc1)
	TAKEOFF   = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ, load2, dVdt2, ρ2, sfc2)
	CLIMB     = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ, load3, dVdt3, ρ3, sfc3)
	CRUISE    = MissionSegment(name4, h4, V4, duration4, ROC4, ϕ, load4, dVdt4, ρ4, sfc4)
	LAND      = MissionSegment(name8, h8, V8, duration8, ROC8, ϕ, load8, dVdt8, ρ8, sfc8)
	LOITER    = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ, load5, dVdt5, ρ5, sfc5)
	DIVERSION = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ, load6, dVdt6, ρ6, sfc6)
	LOITER2   = MissionSegment(name7, h7, V7, duration7, ROC7, ϕ, load7, dVdt7, ρ7, sfc7)
	FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, LOITER, DIVERSION, LOITER2, LAND]
	
	for (j, packspecificenergy) in enumerate(BatterySpecificEnergy)
		
	λ=0.0
	feasible=false
	
	num_battery_packs = 0
	FuelWeight = NaN
	W_PGD = NaN
	BatteryWeight = NaN
	TotalWeight = NaN
	weight=72
	
		batt = (
			packspecificenergy = packspecificenergy,  #Wh/kg
			weight = weight,
			energystoragecapacity=weight*packspecificenergy,
			maxcontinuouspower=40000,
			volume = 0.05426,
			nominalvoltage = 345
		)
	
	while !feasible && λ <= 1.0
			
		
		W_payload2=W_payload*(1-λ)
		maxbatteryvolume = PayloadVolume*λ #m^3
		Embraer2 = Aircraft(MTOW, W_payload2, W_empty, Sref, AR, e, Cd0, maxfuelweight)
	
			
		specificenergy = batt.packspecificenergy
		propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_p, η_electric_generator_efficiency)
			
		W_motor = component_weight(propulsion.P_max_engine *ϕ, propulsion.power_to_weight_motor)
		W_controller = component_weight(propulsion.P_max_engine *ϕ / propulsion.η_motor,propulsion.power_to_weight_controller)
		W_PGD= W_motor + W_controller
		
			
		feasible, num_battery_packs, FuelWeight = batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, Embraer2, W_PGD, batt, maxbatteryvolume, g, η, μ, LD_max;turbofan=true)
				
		
		if feasible
			MaxPayloadFactor[i,j]=λ
			NumberofBatteries[i,j]=num_battery_packs

		else
			λ+=0.01
		end
	
			
	end
		
end
end
end
  ╠═╡ =#

# ╔═╡ f1eca10b-46fa-4cd0-8119-b0b25083acc9
# ╠═╡ show_logs = false
# ╠═╡ disabled = true
#=╠═╡
begin
	η=1
	Max_iterations=10000
	
	

     #   for (j, λ) in enumerate(Lambda)

	TAXI      = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ, load1, dVdt1, ρ1, sfc1)
	TAKEOFF   = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ, load2, dVdt2, ρ2, sfc2)
	CLIMB     = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ, load3, dVdt3, ρ3, sfc3)
	CRUISE    = MissionSegment(name4, h4, V4, duration4, ROC4, ϕ, load4, dVdt4, ρ4, sfc4)
	LAND      = MissionSegment(name8, h8, V8, duration8, ROC8, ϕ, load8, dVdt8, ρ8, sfc8)
	LOITER    = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ, load5, dVdt5, ρ5, sfc5)
	DIVERSION = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ, load6, dVdt6, ρ6, sfc6)
	LOITER2   = MissionSegment(name7, h7, V7, duration7, ROC7, ϕ, load7, dVdt7, ρ7, sfc7)
	FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, LOITER, DIVERSION, LOITER2, LAND]
	


	weight=72
	
		batt = (
			packspecificenergy = packspecificenergy,  #Wh/kg
			weight = weight,
			energystoragecapacity=weight*packspecificenergy,
			maxcontinuouspower=40000,
			volume = 0.05426,
			nominalvoltage = 345
		)
	
			
		
		W_payload2=W_payload*(1-λ)
		maxbatteryvolume = PayloadVolume*λ #m^3
		Embraer2 = Aircraft(MTOW, W_payload2, W_empty, Sref, AR, e, Cd0, maxfuelweight)
	
			
		specificenergy = batt.packspecificenergy
		propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_p, η_electric_generator_efficiency)
			
		W_motor = component_weight(propulsion.P_max_engine *ϕ, propulsion.power_to_weight_motor)
		W_controller = component_weight(propulsion.P_max_engine *ϕ / propulsion.η_motor,propulsion.power_to_weight_controller)
		W_PGD= W_motor + W_controller
		
			
		feasible, num_battery_packs, FuelWeight = batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, Embraer2, W_PGD, batt, maxbatteryvolume, g, η, μ, LD_max;turbofan=true)
	end
  ╠═╡ =#

# ╔═╡ d43a7cca-fccc-49a1-8050-93b8b3a63906
# ╠═╡ disabled = true
#=╠═╡
begin
	ϕ=0.1#,0.02, 0.03, 0.04]
	λ=1
	
	packspecificenergy=300#152.78#, 300, 500, 700
end
  ╠═╡ =#

# ╔═╡ 15b4d989-db0f-4b73-b435-30313c922375
#=╠═╡
begin
	println(feasible)
	println(num_battery_packs)
end
  ╠═╡ =#

# ╔═╡ 4014e1fc-26af-4240-aa81-4911bb6f5c23
# ╠═╡ disabled = true
#=╠═╡
W_PGD
  ╠═╡ =#

# ╔═╡ c8a07f45-7973-4972-ad3a-cb6a809181d6
# ╠═╡ disabled = true
#=╠═╡
begin
	Hybridization = 0.01:0.01:0.26
	BatterySpecificEnergy = [152.78, 300, 500, 700] # Wh/kg

	
 #rows hybridization
	#columns battery spec
	MaxPayloadFactor = [
			# 152.78   300    500    700   
			0.19   0.09   0.04  0.03;    # ϕ = 0.01
			0.39   0.18   0.10  0.07;    # ϕ = 0.02
			0.59   0.28   0.16  0.10;    # ϕ = 0.03
			0.78   0.38   0.21  0.14;    # ϕ = 0.04
			0.98   0.45   0.27  0.18;    # ϕ = 0.05
			NaN	   0.58   0.32  0.22;    # ϕ = 0.06
			NaN	   0.67	  0.38	0.26;    # ϕ = 0.07
			NaN	   0.77	  0.44	0.3	;	 # ϕ = 0.08
			NaN	   0.87	  0.49	0.33;	 # ϕ = 0.09
			NaN		1.0	  0.55	0.37;	 # ϕ = 0.1
		    NaN     NaN   0.61  0.41     # ϕ = 0.11
			NaN		NaN	  0.66	0.45;	 # ϕ = 0.12
			NaN		NaN	  0.72	0.49;	 # ϕ = 0.13
			NaN		NaN	  0.78	0.53;	 # ϕ = 0.14
			NaN		NaN	  0.84	0.56;	 # ϕ = 0.15
			NaN		NaN	  0.89	0.61;	 # ϕ = 0.16
			NaN		NaN   1.0	0.65;    # ϕ = 0.17
			NaN		NaN	  NaN	0.68;    # ϕ = 0.18
			NaN		NaN	  NaN	0.72;	 # ϕ = 0.19
			NaN		NaN	  NaN	0.76;	 # ϕ = 0.20
			NaN		NaN	  NaN	0.8	;    # ϕ = 0.21
			NaN		NaN	  NaN	0.84;	 # ϕ = 0.22
			NaN		NaN	  NaN	0.88;	 # ϕ = 0.23
			NaN		NaN	  NaN	0.92;	 # ϕ = 0.24
			NaN		NaN	  NaN	1.0	;	 # ϕ = 0.25
			NaN		NaN	  NaN	1.0	     # ϕ = 0.26
]



		
	#NumberofBatteries = [
        # 152.78   300   500   700
    #      29       15     9     7;    # ϕ = 0.01
   #       57       29    18    13;    # ϕ = 0.02
  #        85       43    26    19;    # ϕ = 0.03
 #         113      58    35    25;    # ϕ = 0.04
#		 141                       ;    # ϕ = 0.05
#			NaN		                    ; # ϕ = 0.06
#			NaN							 ;# ϕ = 0.07
#			NaN						 ;	 # ϕ = 0.08
#			NaN						 ;	 # ϕ = 0.09
			#NaN	   143				 ;	 # ϕ = 0.1
		##	NaN    NaN				;	 # ϕ = 0.12
		#	NaN		NaN				;	 # ϕ = 0.13
		#	NaN		NaN				;	 # ϕ = 0.14
		#	NaN		NaN				;	 # ϕ = 0.15
		#	NaN		NaN				;	 # ϕ = 0.16
		#	NaN		NaN	 146			 ;    # ϕ = 0.17
		#	NaN		NaN	NaN		      ;   # ϕ = 0.18
		#	NaN		NaN	NaN	118		;	 # ϕ = 0.19
		#	NaN		NaN	NaN	125		;	 # ϕ = 0.20
		#	NaN		NaN	NaN	131		 ;    # ϕ = 0.21
		#	NaN		NaN	NaN	137		;	 # ϕ = 0.22
		#	NaN		NaN	NaN	143		;	 # ϕ = 0.23
		#	NaN		NaN	NaN	150		;	 # ϕ = 0.24
	##		NaN		NaN	NaN	153		;	 # ϕ = 0.25
	#		NaN		NaN	NaN	162	 # ϕ = 0.26
 #   ]
	

end
  ╠═╡ =#

# ╔═╡ f252ad63-a04a-4db0-a760-0a371b0624ef
# ╠═╡ disabled = true
#=╠═╡
begin
	Hybridization = 0.01:0.01:0.04
	BatterySpecificEnergy = [152.78, 300, 500, 700] # Wh/kg

	
 #rows hybridization
	#columns battery spec
	MaxPayloadFactor = [
			# 152.78   300    500    700   
			0.19   0.09   0.04  0.03;    # ϕ = 0.01
			0.39   0.18   0.10  0.07;    # ϕ = 0.02
			0.59   0.28   0.16  0.10;    # ϕ = 0.03
			0.78   0.38   0.21  0.14]    # ϕ = 0.04
end
  ╠═╡ =#

# ╔═╡ 72bb6a8e-6ea1-41b4-9bf3-a141fa481025
# ╠═╡ disabled = true
# ╠═╡ skip_as_script = true
#=╠═╡
begin
 xt = collect(0:0.01:0.04)
    yt = collect(0.1:0.1:1.1)


labels = reshape(
    [latexstring("e_{\\mathrm{batt}} = ", E, "\\ \\mathrm{Wh\\,kg^{-1}}") for E in BatterySpecificEnergy],
    1, :
)

p = plot(
    Hybridization,
    MaxPayloadFactor,
    xlabel = L"\mathrm{Hybridization\ ratio}\ \phi",
    ylabel = L"\mathrm{Payload\ factor}\ \lambda",
    grid = true,
	#ylims=[0.65,1.005],
    marker = :circle,
    markersize = 4,
    linewidth = 2,
    label = labels,
    legend = :topleft,
    tickfontsize = 26,
    guidefontsize = 26,
    legendfontsize = 21,
	xticks = (xt, latexstring.(string.(xt))),
    yticks = (yt, latexstring.(string.(yt)))

)

p
	#savefig(p, "Embraer Hybr vs Pay.svg")

	
end

  ╠═╡ =#

# ╔═╡ dc14f24f-95c0-4a21-b0b1-cc0381cedecb
# ╠═╡ disabled = true
#=╠═╡
begin
 xt = collect(0.0:0.01:0.05)
    yt = collect(10:10:150)


labels = reshape(
    [latexstring("e_{\\mathrm{batt}} = ", E, "\\ \\mathrm{Wh\\,kg^{-1}}") for E in BatterySpecificEnergy],
    1, :
)

p = plot(
    Hybridization,
    NumberofBatteries,
    xlabel = L"\mathrm{Hybridization\ factor}\ \phi",
    ylabel = L"\mathrm{Number\ of\ batteries}",
    grid = true,
	#ylims=[5,65],
    marker = :circle,
    markersize = 4,
    linewidth = 2,
    label = labels,
    legend = :best,
    tickfontsize = 13,
    guidefontsize = 13,
    legendfontsize = 13,
	xticks = (xt, latexstring.(string.(xt))),
    yticks = (yt, latexstring.(string.(yt)))

)

p
	savefig(p, "Embraer Hybr vs No Batt.svg")

	
end

  ╠═╡ =#

# ╔═╡ 0fc3b259-62a1-43d1-9e73-db2a1ab9aab2
# ╠═╡ disabled = true
#=╠═╡
NumberofBatteries
  ╠═╡ =#

# ╔═╡ a2438726-4c23-4882-9c5e-e20948dc125b
# ╠═╡ disabled = true
#=╠═╡
begin

    p = plot(
        xlabel = L"\mathrm{Number\ of\ battery\ packs}",
        ylabel = L"\mathrm{Payload\ factor}\ \lambda_{\max}",
        grid = true,
        marker = :circle,
        markersize = 5,
        linewidth = 2,
        tickfontsize = 15,
        guidefontsize = 15,
        legendfontsize = 15,
        framestyle = :box,
        fontfamily = "Computer Modern",
        legend = :best
    )

    for (j, E) in enumerate(BatterySpecificEnergy)

        plot!(
            p,
            NumberofBatteries[:, j],
            MaxPayloadFactor[:, j],
            marker = :circle,
            markersize = 5,
            linewidth = 2,
            label = latexstring("e_{\\mathrm{batt}} = ", E, "\\ \\mathrm{Wh\\,kg^{-1}}")
        )

        # annotate points with phi values
        for i in eachindex(Hybridization)
            if !isnan(NumberofBatteries[i, j]) && !isnan(MaxPayloadFactor[i, j])
                annotate!(
                    p,
                    NumberofBatteries[i, j],
                    MaxPayloadFactor[i, j],
                    text(latexstring("\\phi = ", Hybridization[i]), 10)
                )
            end
        end
    end

    p
	savefig(p, "Embraer No Batt vs Pay APPENDIX.svg")
end
  ╠═╡ =#

# ╔═╡ e41ab01d-6682-4e1e-8def-00298dcdd74c
# ╠═╡ disabled = true
#=╠═╡
begin
  

    labels = reshape(
        [latexstring("e_{\\mathrm{batt}} = ", E, "\\ \\mathrm{Wh\\,kg^{-1}}") 
        for E in BatterySpecificEnergy],
        1, :
    )

    p = plot(
        Hybridization,
        NumberofBatteries,
        xlabel = L"\mathrm{Hybridisation\ factor}\ \phi",
        ylabel = L"\mathrm{Number\ of\ battery\ packs}",
        label = labels,
        marker = :circle,
        markersize = 5,
        linewidth = 2,
        grid = true,
        legend = :topleft,
        tickfontsize = 13,
        guidefontsize = 13,
        legendfontsize = 10,
        framestyle = :box,
        fontfamily = "Computer Modern"
    )

    p
	#savefig(p, "AdjustmentofPayloadWeightandHybridizationNoBatteries.svg")
end
  ╠═╡ =#

# ╔═╡ ffcbac72-e0dd-47ce-860a-24a7e9711ec2


# ╔═╡ c48e2863-b21f-469e-b275-d78e824adece
md"## Payload Range Diagrams"

# ╔═╡ ea426bf2-bfc9-49f8-a3ca-2897bec6d588
# ╠═╡ disabled = true
#=╠═╡
begin

		# Plot meshes

xt = collect(0:1000:10000)
yt = collect(0:1000:10000)



plot_Payload_Range = plot(
    xlabel = L"\mathrm{Range}\;(\mathrm{km})",
    ylabel = L"\mathrm{Payload\ Weight}\;(\mathrm{kg})",
    grid = true,
	xlims=[0, 8050],
	ylims=[0, 10500],
	xticks = (xt, latexstring.(string.(xt))),
    yticks = (yt, latexstring.(string.(yt))),
    marker = :circle,
    markersize = 2,
    linewidth = 1.5,
    tickfontsize = 11,
    guidefontsize = 11,
    legendfontsize = 11,
    legend = :left,
	
)
		



	
	batt=battery(batteryselection)

	propulsion2 = Propulsion(η_motor, η_controller, η_battery, batt.packspecificenergy, SOC_min, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_p, η_electric_generator_efficiency)
	
	UnModifiedRanges, UnModifiedWPloads = PayloadRange(Embraer, propulsion2, g, L_D_cruise; sfc_cruise=sfccruise)
	plot!(plot_Payload_Range, UnModifiedRanges, UnModifiedWPloads, linewidth=2,
    marker = :circle, markersize = 4, label = L"\mathrm{Unmodified\ Embraer\ E175 LR}"
)


	Hybridization= [0.01]
	Hybr=length(Hybridization)
	
	BatterySpecificEnergy = [152.78] # Wh/kg
    Lambda =[0.4]# [0.6, 0.7, 0.8, 0.9, 1]#0.5 0.6 ] # 40% payload reduction
	
	nE = length(BatterySpecificEnergy)
    nL = length(Lambda)
	

	for (i, ϕ) in enumerate(Hybridization)
		for (j, λ) in enumerate(Lambda)
			for (k, packspecificenergy) in enumerate(BatterySpecificEnergy)
				BatteryWeight = NaN
				TotalWeight = NaN
				FuelWeight = NaN
			
			num_battery_packs = 0	
			
			
			TAXI      = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ, load1, dVdt1, ρ1, sfc1)
			TAKEOFF   = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ, load2, dVdt2, ρ2, sfc2)
			CLIMB     = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ, load3, dVdt3, ρ3, sfc3)
			CRUISE    = MissionSegment(name4, h4, V4, duration4, ROC4, ϕ, load4, dVdt4, ρ4, sfc4)
			LOITER    = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ, load5, dVdt5, ρ5, sfc5)
			DIVERSION = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ, load6, dVdt6, ρ6, sfc6)
			LOITER2   = MissionSegment(name7, h7, V7, duration7, ROC7, ϕ, load7, dVdt7, ρ7, sfc7)  
			LAND      = MissionSegment(name8, h8, V8, duration8, ROC8, ϕ, load8, dVdt8, ρ8, sfc8)
			
			weight=72
			#batt=battery(batteryselection)
			batt = (
				packspecificenergy = packspecificenergy,  #Wh/kg
				weight = weight,
				energystoragecapacity=weight*packspecificenergy,
				maxcontinuouspower=40000,
				volume = 0.05426,
				nominalvoltage = 345
			)
		
				

			W_payload2=W_payload*(1-λ)
			maxbatteryvolume = PayloadVolume*λ #m^3
			Embraer2 = Aircraft(MTOW, W_payload2, W_empty, Sref, AR, e, Cd0, maxfuelweight)
		
		
			
				
					
			specificenergy = batt.packspecificenergy
			propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_p, η_electric_generator_efficiency)
				
		
			FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, LOITER, DIVERSION, LOITER2, LAND]
			
			η=1
			Max_iterations=10000
				
			W_motor = component_weight(propulsion.P_max_engine * maximum(ϕ), propulsion.power_to_weight_motor)
			W_controller = component_weight(propulsion.P_max_engine * maximum(ϕ) / propulsion.η_motor,propulsion.power_to_weight_controller)
			W_PGD= W_motor + W_controller
			
				
		
			#EDITED AIRCRAFT
			feasible, num_battery_packs, W_f= batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, Embraer2, W_PGD, batt, maxbatteryvolume, g, η, μ, LD_max;turbofan=true)
			
					
			if feasible
				

				BatteryWeight= batt.weight*num_battery_packs
				FuelWeight=W_f
				
				TotalWeight= Embraer.W_empty + Embraer2.W_payload + W_PGD + BatteryWeight+ FuelWeight

				
				ModifiedAircraft=Aircraft(MTOW, Embraer2.W_payload, W_empty, Sref, AR, e, Cd0, maxfuelweight)
				Ranges, WPloads = PayloadRange(ModifiedAircraft, propulsion, g, L_D_cruise;W_batt=BatteryWeight, sfc_cruise=sfccruise, W_PGD=W_PGD)
				
				plot!(plot_Payload_Range, Ranges, WPloads,linewidth = 2, marker =:circle, markersize = 4,label = latexstring("\\lambda = ",λ))
				println(Ranges)	 
				println(WPloads)
#label = latexstring("\\lambda = ",λ))
#label = latexstring("e_{\\mathrm{batt}} = ",specificenergy,"\\ \\mathrm{Wh\\,kg^{-1}}"))
# label = latexstring("\\phi = ", ϕ))

			end
	end 		
				
		end
			
	end
end


  ╠═╡ =#

# ╔═╡ 29220cba-685b-4e5a-93ec-570d25f0d493
# ╠═╡ disabled = true
#=╠═╡
begin
	plot_Payload_Range
	#savefig(plot_Payload_Range, "PayloadRangeEmbraerE.svg")
end
  ╠═╡ =#

# ╔═╡ fb6e7493-6dc7-4049-a2a5-6b17132b0fcd
# ╠═╡ disabled = true
#=╠═╡
begin

	Hybr=length(Hybridization)

	
	nE = length(BatterySpecificEnergy)
    nL = length(Lambda)
	

	for (i, ϕ) in enumerate(Hybridization)
		for (j, λ) in enumerate(Lambda)
			for (k, packspecificenergy) in enumerate(BatterySpecificEnergy)
				BatteryWeight = NaN
				TotalWeight = NaN
				FuelWeight = NaN
			
			num_battery_packs = 0	
			
			
			TAXI      = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ, load1, dVdt1, ρ1, sfc1)
			TAKEOFF   = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ, load2, dVdt2, ρ2, sfc2)
			CLIMB     = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ, load3, dVdt3, ρ3, sfc3)
			CRUISE    = MissionSegment(name4, h4, V4, duration4, ROC4, ϕ, load4, dVdt4, ρ4, sfc4)
			LOITER    = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ, load5, dVdt5, ρ5, sfc5)
			DIVERSION = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ, load6, dVdt6, ρ6, sfc6)
			LOITER2   = MissionSegment(name7, h7, V7, duration7, ROC7, ϕ, load7, dVdt7, ρ7, sfc7)  
			LAND      = MissionSegment(name8, h8, V8, duration8, ROC8, ϕ, load8, dVdt8, ρ8, sfc8)
			
			weight=72
			#batt=battery(batteryselection)
			batt = (
				packspecificenergy = packspecificenergy,  #Wh/kg
				weight = weight,
				energystoragecapacity=weight*packspecificenergy,
				maxcontinuouspower=40000,
				volume = 0.05426,
				nominalvoltage = 345
			)
		
				

			W_payload2=W_payload*(1-λ)
			maxbatteryvolume = PayloadVolume*λ #m^3
			Embraer2 = Aircraft(MTOW, W_payload2, W_empty, Sref, AR, e, Cd0, maxfuelweight)
		
		
			
				
					
			specificenergy = batt.packspecificenergy
			propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_p, η_electric_generator_efficiency)
				
		
			FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, LOITER, DIVERSION, LOITER2, LAND]
			
			η=1
			Max_iterations=5000
				
			W_motor = component_weight(propulsion.P_max_engine * maximum(ϕ), propulsion.power_to_weight_motor)
			W_controller = component_weight(propulsion.P_max_engine * maximum(ϕ) / propulsion.η_motor,propulsion.power_to_weight_controller)
			W_PGD= W_motor + W_controller
			
				
		
			#EDITED AIRCRAFT
			feasible, num_battery_packs, W_f= batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, Embraer2, W_PGD, batt, maxbatteryvolume, g, η, μ, LD_max;turbofan=true)
			println(feasible)
			
			end	
		end
	end
end
  ╠═╡ =#

# ╔═╡ 81581d9a-2a03-444d-98bb-21c3e5e25e7e
# ╠═╡ disabled = true
#=╠═╡
begin
	Hybridization= [0.01]
	
	BatterySpecificEnergy = [152.78] # Wh/kg
    Lambda =[0.19]# [0.6, 0.7, 0.8, 0.9, 1]#0.5 0.6 ] # 40% payload reduction
end
  ╠═╡ =#

# ╔═╡ e69e6b87-643c-4429-baac-49d0b0053639


# ╔═╡ 5e65c2b5-9d2e-4f87-a7bb-16ea74b94cc0


# ╔═╡ ee3f1393-dfe1-4d16-9a3f-70fe5ac771b6
md"""
## Payload Range Diagram
The payload range diagram has 4 features/points
1. Maximum payload, zero range
2. Maximum payload, max range
3. Maximum fuel, some payload remaining
4. Zero payload, maximum fuel
"""

# ╔═╡ 6cede85c-66cb-44d7-ae17-eab1986447fd
md"""
## Range equation
Total input energy=Battery energy storage capacity x number of battery packs /charging efficiency. The charging efficiency is approximately 97%.
"""

# ╔═╡ d027008e-2931-403d-a6c9-5f81c7fb4b15
# ╠═╡ disabled = true
#=╠═╡
E_0total =batt.energystoragecapacity*num_battery_packs*3600/0.99 #multiply by 3600 to convert to Joules
  ╠═╡ =#

# ╔═╡ c5913397-beb3-4be4-bc91-3e01a4b6021d
# ╠═╡ disabled = true
#=╠═╡
rangeparallel=Range_parallel(Embraer2, propulsion, E_0total, CRUISE.ϕ, LD_max, g)/1000
  ╠═╡ =#

# ╔═╡ 47197efd-2bfc-4048-88e9-2487edab78e0
md"""
# Aircraft Geometry
"""

# ╔═╡ d6738bf8-367a-48e3-9d7b-7ab4dbcdc022
md" ## Fuselage"

# ╔═╡ e162d262-4e3c-45d0-a930-f66fd6f35cb2
begin 
	fuselage = HyperEllipseFuselage(
	#known
	radius = 1.39,          # Radius, m 
	length = 31.68,        # Length, m 
	x_a    = 0.1348,          # Start of cabin, ratio of length
	x_b    = 0.727,         # End of cabin, ratio of length 
	#estimates
	c_nose = 1.6,           # Curvature of nose 
	c_rear = 1.2,           # Curvature of rear 
	d_nose = -0.4,          # "Droop" or "rise" of nose, m
	d_rear = 0.8,           # "Droop" or "rise" of rear, m 
	position = [0.,0.,0.]   # Set nose at origin, m
)
	fuselage_end = fuselage.affine.translation + [ fuselage.length, 0., 0. ];
end;

# ╔═╡ 1add5b76-1ac6-4ee4-b0ed-1dfe5a543c2c
md"## Payload"

# ╔═╡ c41e5b42-16e8-4f27-b58f-047e2726ea1f
begin 
	x_start = fuselage.length*fuselage.x_a
	x_end   = fuselage.length*fuselage.x_b
	z_start = -0.7366 #m
	z_end   = -fuselage.radius #m
	radius  = fuselage.radius
	#cyl_edges = plotvolume(x_start, x_end, z_start, z_end; radius=radius, λ=λ)
	
	PayloadVolume, New_x_end = payloadvolume(x_start, x_end, z_start, z_end; radius=radius, λ=0)
	
end

# ╔═╡ 0081c681-7803-4cee-8c96-68b465a531e6
md""" 
## Wing
**Define the airfoil profiles**

For Embraer E175LR the wing's root, midspan and tip airfoils are substituted with similar NASA supercritical airfoils. Note that AeroFuse uses a discretisation method to compute the wing parameters so they vary slightly from the literature. Accuracy is acceptable.
"""

# ╔═╡ f8f9b0e5-2af3-496d-84b5-4ad15e4227da
begin 
	#Representative supercritical airfoils for Embraer E175-style wing
	
	rootairfoil = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=sc20714-il")) 
	meanairfoil = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=sc20712-il")) 
	tipairfoil  = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=sc20710-il"))  
end;

# ╔═╡ dc1e45c9-d894-4c81-9ac7-b1bdb5ad384e
wing = Wing(; 
	chords    = [5, 3, 1.25], 
	foils     = [rootairfoil, meanairfoil, tipairfoil],
	twists 	  = [1, 0.5, -1.5],
	spans     = [4.5, 8.64],  #total wingspan is 28.65m  
	sweeps    = [27, 27], 
	w_sweep   = 0.0, 
	dihedrals = [2.0, 5.0],#fill(2.5, 2),
	symmetry  = true,
	angle       = 0,            #Incidence angle (deg)
	axis = [0, 1, 0],
	position    = [10.5, 0., -0.5]  #approximated last no.
); 

# ╔═╡ 41bcc938-1b5b-4d19-9c51-d48a17f7bf08
begin 
	AR = round(aspect_ratio(wing),digits=2) #AR = 9.5 check
	b_w = 26 #m span(wing)
	c_w = mean_aerodynamic_chord(wing)	
	Sref = round(projected_area(wing), digits=2)
	mac40_wing = mean_aerodynamic_center(wing, 0.40)
end;

# ╔═╡ a1f0e3af-be32-4672-8646-d5ed4d243532
AR #check 9.5

# ╔═╡ 2269c383-28bd-48ff-bd1a-1df0ff12ecbf
Sref #check 72.72

# ╔═╡ c7d1a8bd-5064-44b1-9fd2-2df5bec6c1ce
md""" 
## Empennage
The values are taken from literature. Where assumptions are made, values from similar/typical aircraft data was used. NACA0012 and NACA0009 are typical empennage airfoil codes. 
"""

# ╔═╡ 94c33576-7fe5-432b-8eb6-2c1a7e9eb195
md"### Horizontal Tail"

# ╔═╡ 02fc4aeb-1324-4d9b-a5d5-898557bf8760
md"### Vertical Tail"

# ╔═╡ ba17d9e9-03d8-44b2-b815-4d1b87a0f394
vertical_tail = WingSection(
	area        = 16.20, 	    #Area + dorsal fin (m²). 
	aspect      = 1.37,  			
	taper       = 0.38,  			#					GUESS
	dihedral    = 0.0,
	sweep       = 39, 			    #   				GUESS
	w_sweep     = 0.1,   			#Leading-edge sweep GUESS
	root_foil   = naca4(0,0,1,2), 	#   				GUESS	
	tip_foil    = naca4(0,0,1,2), 	#   				GUESS	
	symmetry    = false,
	angle       = 90.,       		#To make it vertical
	axis        = [1, 0, 0], 
	position    = fuselage_end - [6.5, 0., -fuselage.d_rear]
);

# ╔═╡ efccb09e-a0c6-4866-a0d6-636c6bf86650
horizontal_tail = WingSection( 
	area        = 11.625,  		    # Area (m²). 
	aspect      = 4.3,  		    # Aspect ratio
	taper       = 0.5,  		    # Taper ratio  				GUESS
	dihedral    = 6,   		    	# Dihedral angle (deg)      GUESS
	sweep       = 32,  		    	# Sweep angle (deg)         GUESS
	w_sweep     = 0,   		        # Leading-edge sweep        GUESS
	root_foil   = naca4(0,0,1,2), 	# Root airfoil              GUESS
	tip_foil    = naca4(0,0,1,2), 	# Tip airfoil               GUESS
	symmetry    = true,
	angle       = 0, 
	position    = vertical_tail.affine.translation + [ 2, 0., span(vertical_tail)-5],
); #GUESS

# ╔═╡ c2b37621-c132-431b-8c5e-bfa234a915fa
md" ## Meshing"

# ╔═╡ 02b06434-bb3f-4c93-ae61-74dabd7c1075
begin
	wing_mesh = WingMesh(wing, [8,16], 10, span_spacing = Uniform());
	vertical_tail_mesh = WingMesh(vertical_tail, [8], 6);
	horizontal_tail_mesh = WingMesh(horizontal_tail, [10], 8);
end;
# Spacing: Uniform() or Cosine()


# ╔═╡ dbd82758-56ae-429e-b770-ad913076f1f6
begin 
	K_LD   	   = 15.5 #civil jet
	S_wet = (wetted_area(wing_mesh) + wetted_area(fuselage, 0:0.1:1) + wetted_area(horizontal_tail_mesh) + wetted_area(vertical_tail_mesh))
	#S   = 72.72 check
	Swett_Sref= S_wet/Sref          #about 6  
	A_wett     = AR/Swett_Sref 
	LD_max     = K_LD * sqrt(A_wett)
	g=9.81
	println("L/Dmax: ", round(LD_max, digits=2))
end

# ╔═╡ 3b36afa0-32c8-4534-9b39-022bb04194af
begin
	MTOW             = 38800#round(W0,digits=2) #38800
	W_empty          = 21700#We #21700
	e                = 0.85
	Cd0              = round(π*AR*e/(2*LD_max)^2, digits=4) # check 0.0220
	maxfuelweight    = 9335 #kg
	Embraer = Aircraft(MTOW, W_payload, W_empty, Sref, AR, e, Cd0, maxfuelweight)
	
end

# ╔═╡ d8161686-3e11-48a8-8dae-a2f3c0ad3530
md"""
### Embraer E175LR 
| Variable         | Value    | Units |
| ----             | ---      |  ---  |
| MTOW             | $MTOW    | kg    |
| W_payload        | $W_payload         | kg    |
| W_empty          | $W_empty        | kg    |
| AR               | $AR      | -     |         
| e                | $e       | -     | 
| Cd0              | $Cd0     | -     |
| maxfuelweight    | $maxfuelweight        | kg    |
| S                | $Sref    | m^2   |

$C_{D_0}=\frac{π AR e}{2 \left( L/D\right)^2_{max}}$
"""

# ╔═╡ e3e79186-7dd2-40da-b03a-556944ce15be
W_fuel_max = Embraer.maxfuelweight

# ╔═╡ 7246cf0a-652a-41a9-8bc0-e35214eb70d7
L_D_cruise    = LD_max *0.866

# ╔═╡ 8bf081ba-b4da-4d26-a8c6-44d73e870c43
md"## Plotting Parameters"

# ╔═╡ 6b8b0f6f-4322-4141-8943-b660755a8998
begin
	φ_s 			= @bind φ Slider(-180:1e-2:180, default = 0)
	ψ_s 			= @bind ψ Slider(-180:1e-2:180, default = 90)
end;


# ╔═╡ 04238b63-52f6-4da9-b705-331515c0e27c
begin
	# Plot meshes
	plot_aircraft = plot(
	    # aspect_ratio = 1,
	    xaxis = "x", yaxis = "y", zaxis = "z",
	    zlim = (-15,20),#(-0.5, 0.5) .* span(wing_mesh),
		xlim = (0,35),
		ylim = (-17.5,17.5),
	    camera = (φ, ψ),
		grid = false
	)
	
end;

# ╔═╡ b384c1f1-c683-4d16-9aab-f8a8c886f43f
toggles = md"""
φ: $(φ_s)
ψ: $(ψ_s)
"""


# ╔═╡ ab67beb3-78d1-4a24-a45c-77fe75495ea2
# ╠═╡ disabled = true
#=╠═╡
begin
	plot!(plot_aircraft, horizontal_tail_mesh, label = false, mac = false)
	plot!(plot_aircraft, vertical_tail_mesh, label = false, mac = false)
	plot!(plot_aircraft, fuselage, label = false)
	plot!(wing_mesh, label = false, mac = false)

	#Cuboid
	#edges2 = plotvolume(7, 10, z_start, z_end; width=radius*1.5, λ=FACTOR)
	#for (ex, ey, ez) in edges2
	 #   plot!(p2, ex, ey, ez, color=:purple, label=false, lw=2)
	#end

	# Cylinder
	for (ex, ey, ez) in cyl_edges
	    plot!(plot_aircraft,ex, ey, ez, color=:pink, label=false, lw=2)
	end
	plot_aircraft
end
  ╠═╡ =#

# ╔═╡ Cell order:
# ╟─5f1441ea-2158-4b08-98db-7c85b92307d4
# ╟─4580f93b-25b0-4f41-bdfa-a0cd2f503278
# ╟─a7898977-e7d2-45e4-932e-2305f1c575a6
# ╟─82ade567-2d6a-4468-a50d-1703eaa88880
# ╟─d8161686-3e11-48a8-8dae-a2f3c0ad3530
# ╠═3b868160-f433-4444-b387-8ff444347352
# ╠═3b36afa0-32c8-4534-9b39-022bb04194af
# ╠═410d0ccc-953b-4d84-914d-c1d0d9678cb7
# ╟─5db55fae-5c62-48d8-a660-bbc6533dad2b
# ╠═06267e89-35b6-432c-8a1b-c1122c9261f6
# ╠═2595200d-b5e8-4529-a87a-175b94f74784
# ╠═2f91a7e1-5b5a-4436-89d5-8ea7c559d443
# ╟─157fcc13-a298-49ce-af0d-3b3b0b10e654
# ╠═dce3767d-acb3-4f35-b54c-2ec84950ad1a
# ╟─f764aff5-df7d-4de8-8b39-4c72048779d9
# ╟─23e24607-ab4c-4ba2-906c-594a3c75edb1
# ╟─1f86389e-2a15-4dc8-a8b5-2b187854d8f5
# ╠═dbd82758-56ae-429e-b770-ad913076f1f6
# ╟─31cd5adf-d4df-4846-b5c1-a49c130281b9
# ╠═a4f8b5c0-f7d7-4710-87f0-5db6beee4759
# ╟─e92478ba-d042-4ef6-9337-309a6b22b1bc
# ╠═7246cf0a-652a-41a9-8bc0-e35214eb70d7
# ╠═21857ef9-8b97-4f36-93e1-ebc0102ccee2
# ╠═ba1e355a-b8f8-4c92-933b-c6beefd30f19
# ╟─ffab5d4b-27ce-4824-ac52-3bcec9915aa3
# ╠═e1f3fbbc-eb25-4007-b26a-ead32a6d2bd0
# ╠═05c6512c-e85c-4cf2-9e17-e6128d61182f
# ╠═a206f8b9-d8db-4551-94ba-be0f54e020ec
# ╠═ce7c8d19-fcdd-4d4c-981b-39b55012daca
# ╠═47878d15-3650-432b-83ff-830912523cc2
# ╠═a4627a97-111c-486d-8313-1fe8600ab659
# ╠═e3e79186-7dd2-40da-b03a-556944ce15be
# ╠═4487ac73-a7f2-4462-8e34-c64f3c3776f6
# ╠═26b5f967-35c6-4ec0-8cd2-a1eeb2091feb
# ╠═4b72da8b-fe1b-4989-8c9f-e3ca5ea9a426
# ╠═0d7f8682-2070-41e3-83bd-b7baafb11bfd
# ╠═0a41ad33-202c-493c-b444-34036e27d1a4
# ╠═b241444a-4617-463e-a074-5df02da50716
# ╠═cdc9f49d-fe85-4600-aefc-045dd0d4cee4
# ╠═dcbee5b2-8690-4304-a72c-ddfa1d307637
# ╟─e8316533-6102-4ea6-8753-04dc5a95ac23
# ╠═8905bd96-68d4-4bb8-8a63-c7fa608da3f4
# ╟─6121f5f8-c2eb-49e9-9cf2-cccfe8d9b96b
# ╠═fad3fa47-f041-4d28-819e-2e7063076180
# ╟─0726a457-7f34-43bd-b489-c7748c186b4a
# ╠═d148f775-dc7f-4622-aff5-5607fa8e33b9
# ╠═c574a8bd-77d9-4f2c-b750-4407d472543d
# ╠═c4b26590-6b14-4b0e-9da9-55a0f6bed709
# ╠═c45f595d-6803-4452-9602-28099e37f733
# ╠═54973b29-8dc0-4e97-b7ea-b641f19d90b5
# ╠═f84f3b6a-2218-48fb-bb13-66bf3c3ef84a
# ╠═a04bbcbc-fdc2-4a88-9e4f-c02f734614d5
# ╠═3086f9ce-2a31-43cb-828c-9ac7729700dd
# ╠═04d523cc-29a6-4d9a-99a9-e36dd451b06c
# ╟─1a4f5679-5540-460c-8992-94a943317f29
# ╠═1ceed2b5-ce59-451b-822b-b73c5dbeb186
# ╠═61dcd57e-d519-4ab5-9313-a97d539fd852
# ╠═d26d62f8-349e-4a35-86a2-f5170d42281a
# ╟─48c1ae8c-5ee9-4473-98ab-4d2c1014a1ec
# ╟─4d2501b7-45be-4013-9ef5-6abb420d9fdd
# ╠═e15e06ee-409d-4d99-b498-289102d74752
# ╠═6405b872-9cc8-4e8a-950d-9a647cefef9e
# ╠═f1eca10b-46fa-4cd0-8119-b0b25083acc9
# ╠═d43a7cca-fccc-49a1-8050-93b8b3a63906
# ╠═15b4d989-db0f-4b73-b435-30313c922375
# ╠═4014e1fc-26af-4240-aa81-4911bb6f5c23
# ╠═c8a07f45-7973-4972-ad3a-cb6a809181d6
# ╠═f252ad63-a04a-4db0-a760-0a371b0624ef
# ╠═72bb6a8e-6ea1-41b4-9bf3-a141fa481025
# ╠═dc14f24f-95c0-4a21-b0b1-cc0381cedecb
# ╠═0fc3b259-62a1-43d1-9e73-db2a1ab9aab2
# ╠═a2438726-4c23-4882-9c5e-e20948dc125b
# ╠═e41ab01d-6682-4e1e-8def-00298dcdd74c
# ╟─ffcbac72-e0dd-47ce-860a-24a7e9711ec2
# ╟─c48e2863-b21f-469e-b275-d78e824adece
# ╠═ea426bf2-bfc9-49f8-a3ca-2897bec6d588
# ╠═29220cba-685b-4e5a-93ec-570d25f0d493
# ╠═fb6e7493-6dc7-4049-a2a5-6b17132b0fcd
# ╠═81581d9a-2a03-444d-98bb-21c3e5e25e7e
# ╠═e69e6b87-643c-4429-baac-49d0b0053639
# ╟─5e65c2b5-9d2e-4f87-a7bb-16ea74b94cc0
# ╟─ee3f1393-dfe1-4d16-9a3f-70fe5ac771b6
# ╟─6cede85c-66cb-44d7-ae17-eab1986447fd
# ╠═d027008e-2931-403d-a6c9-5f81c7fb4b15
# ╠═c5913397-beb3-4be4-bc91-3e01a4b6021d
# ╟─47197efd-2bfc-4048-88e9-2487edab78e0
# ╟─d6738bf8-367a-48e3-9d7b-7ab4dbcdc022
# ╠═e162d262-4e3c-45d0-a930-f66fd6f35cb2
# ╟─1add5b76-1ac6-4ee4-b0ed-1dfe5a543c2c
# ╠═c41e5b42-16e8-4f27-b58f-047e2726ea1f
# ╟─0081c681-7803-4cee-8c96-68b465a531e6
# ╠═f8f9b0e5-2af3-496d-84b5-4ad15e4227da
# ╠═dc1e45c9-d894-4c81-9ac7-b1bdb5ad384e
# ╠═41bcc938-1b5b-4d19-9c51-d48a17f7bf08
# ╠═a1f0e3af-be32-4672-8646-d5ed4d243532
# ╠═2269c383-28bd-48ff-bd1a-1df0ff12ecbf
# ╟─c7d1a8bd-5064-44b1-9fd2-2df5bec6c1ce
# ╟─94c33576-7fe5-432b-8eb6-2c1a7e9eb195
# ╠═efccb09e-a0c6-4866-a0d6-636c6bf86650
# ╟─02fc4aeb-1324-4d9b-a5d5-898557bf8760
# ╠═ba17d9e9-03d8-44b2-b815-4d1b87a0f394
# ╟─c2b37621-c132-431b-8c5e-bfa234a915fa
# ╠═02b06434-bb3f-4c93-ae61-74dabd7c1075
# ╟─8bf081ba-b4da-4d26-a8c6-44d73e870c43
# ╠═04238b63-52f6-4da9-b705-331515c0e27c
# ╠═6b8b0f6f-4322-4141-8943-b660755a8998
# ╟─b384c1f1-c683-4d16-9aab-f8a8c886f43f
# ╟─ab67beb3-78d1-4a24-a45c-77fe75495ea2
