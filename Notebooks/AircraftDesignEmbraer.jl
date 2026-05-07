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

# ╔═╡ 2595200d-b5e8-4529-a87a-175b94f74784
@bind batteryselection Select(["PB345V124E-L"])

# ╔═╡ 2f91a7e1-5b5a-4436-89d5-8ea7c559d443
batt=battery(batteryselection)

# ╔═╡ 5db55fae-5c62-48d8-a660-bbc6533dad2b
begin
	η_motor                    		= 0.97 #95-97% efficiency   
	η_controller               		= 0.96
	η_battery                 		= 0.95
	SOC_min                    		= 0.2
	W_engine 				   		= 760*2
	P_max_engine 			   		= 64000*2 #N
	specificenergy             		= batt.packspecificenergy
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

	propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_p, η_electric_generator_efficiency)
end;

# ╔═╡ 410d0ccc-953b-4d84-914d-c1d0d9678cb7
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

# ╔═╡ 06267e89-35b6-432c-8a1b-c1122c9261f6
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

# ╔═╡ ffab5d4b-27ce-4824-ac52-3bcec9915aa3
md"""
### $W_0$ Convergence
The convergence of $W_0$ is based on an initial guess and regression data. It combines both equations $W_0 = \frac{W_{crew}+W_{payload}}{1- \left(\frac{W_f}{W_0} \right)- \left(\frac{W_e}{W_0} \right)  }$ and $W_e=AW^C_0$. 

Embraer E175LR is characterised as jet transport aircraft. Thus A=1.02 and C=-0.06.
"""

# ╔═╡ e1f3fbbc-eb25-4007-b26a-ead32a6d2bd0
begin 
	W0_guess = 10000 
	A=1.02                
	C=-0.06
	W_payload    =    9900.0 #kg
end;

# ╔═╡ e8316533-6102-4ea6-8753-04dc5a95ac23
md"""
# Battery Sizing Methodology

## Hybridization Ratio
The Hybridization ratio is defined as 

$ϕ=\frac{P_{EM}}{P_{EM}+P_{FB}}$

so when ϕ=1 it is a fully electric aircraft and when ϕ=0 it is a conventional aircraft.

"""

# ╔═╡ c4b26590-6b14-4b0e-9da9-55a0f6bed709
begin 
	ϕ = [0.1, 0.1, 0.1, 0.0, 0.0,0.0, 0.0, 0.0]
	ϕ1 				= ϕ[1]
	ϕ2 				= ϕ[2]
	ϕ3 				= ϕ[3]
	ϕ4 				= ϕ[4]
	ϕ5 				= ϕ[5]
	ϕ6 				= ϕ[6]
	ϕ7 				= ϕ[7]
	ϕ8 				= ϕ[8]
end;

# ╔═╡ f764aff5-df7d-4de8-8b39-4c72048779d9
begin
	Range_cruise = 4074000  #3,982-4,074km long range  
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
	TAXI      = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ1, load1, dVdt1, ρ1, sfc1)

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
	TAKEOFF   = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ2, load2, dVdt2, ρ2, sfc2)

    name3            = "Climb"
	h3               = 5852.16
	T3, P3, ρ3  = atmosphere(h3)
    ρ3 = round(ρ3, digits=3)
	V3 = 102.9 * sqrt(1.225 / ρ3)
	V3 = round(V3, digits=3)
	duration3        = 18.0 * 60.0 #18 minutes
	ROC3             = 11.43
    load3            = 1.0
    dVdt3            = (V3-TAKEOFF.V)/duration3
	sfc3 = cT_climb  * 3.6e6 / V3
	CLIMB     = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ3, load3, dVdt3, ρ3, sfc3)
    
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
	CRUISE    = MissionSegment(name4, h4, V4, duration4, ROC4, ϕ4, load4, dVdt4, ρ4, sfc4)

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
	LAND      = MissionSegment(name8, h8, V8, duration8, ROC8, ϕ8, load8, dVdt8, ρ8, sfc8)



	# --- Loiter (30 min reserve) ---
    name5            = "Loiter"
    h5               = 457.178       # low altitude loiter
    V5               = LAND.V        # slow loiter speed (same as land approach)
    duration5        = 1800.0        # 30 mins in seconds
    ROC5             = 0.0
    load5            = 1.0
    dVdt5            = 0.0
    T5, P5, ρ5  = atmosphere(h5)
    ρ5 = round(ρ5, digits=3)
	sfc5 =cT_loiter * 3.6e6 / V5
	LOITER    = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ5, load5, dVdt5, ρ5, sfc5)

    # --- Diversion (200 km to alternate airport) ---
    name6            = "Cruise"
    h6               = CRUISE.h     # same cruise altitude
    V6               = CRUISE.V      # same cruise speed
    duration6        = 200000.0 / V6   # distance/speed = time in seconds
	duration6 = round(duration6, digits=3)
    ROC6             = 0.0
    load6            = 1.0
    dVdt6            = 0.0
    T6, P6, ρ6  = atmosphere(h6)
    ρ6 = round(ρ6, digits=3)
	sfc6 =  0.259
	DIVERSION = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ6, load6, dVdt6, ρ6, sfc6)

    # --- Loiter2 (30 min hold at alternate) ---
    name7            = "Loiter2"
    h7               = 457.178
    V7               = LAND.V 
    duration7        = 1800.0        # 30 mins in seconds
    ROC7             = 0.0
    load7            = 1.0
    dVdt7            = 0.0
    T7, P7, ρ7  = atmosphere(h7)
    ρ7 = round(ρ7, digits=3)
	sfc7 =cT_loiter * 3.6e6 / V7
	LOITER2   = MissionSegment(name7, h7, V7, duration7, ROC7, ϕ7, load7, dVdt7, ρ7, sfc7)

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

# ╔═╡ 6121f5f8-c2eb-49e9-9cf2-cccfe8d9b96b
md"""
## Battery Geometry Constraints

Since we are retrofitting an existing aircraft, the geometry is constrained. Need to define how much space will be available for the battery and how much payload we need to sacrifice.
"""

# ╔═╡ c45f595d-6803-4452-9602-28099e37f733
λ=0.5 #% decrease in payload! amount allocated for battery!

# ╔═╡ 0726a457-7f34-43bd-b489-c7748c186b4a
md"## Battery Sizing"

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

# ╔═╡ 47197efd-2bfc-4048-88e9-2487edab78e0
md"""
# Aircraft Geometry
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

# ╔═╡ b384c1f1-c683-4d16-9aab-f8a8c886f43f
# ╠═╡ disabled = true
#=╠═╡
toggles = md"""
φ: $(φ_s)
ψ: $(ψ_s)
"""
  ╠═╡ =#

# ╔═╡ d6738bf8-367a-48e3-9d7b-7ab4dbcdc022
md" ## Fuselage"

# ╔═╡ e162d262-4e3c-45d0-a930-f66fd6f35cb2
begin 
	fuselage = HyperEllipseFuselage(
	#known
	radius = 1.37,          # Radius, m 
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
	cyl_edges = plotvolume(x_start, x_end, z_start, z_end; radius=radius, λ=λ)
	
	PayloadVolume, New_x_end = payloadvolume(x_start, x_end, z_start, z_end; radius=radius, λ=0)
	
end

# ╔═╡ fad3fa47-f041-4d28-819e-2e7063076180
maxbatteryvolume = PayloadVolume*λ #m^3

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
# ╠═╡ disabled = true
#=╠═╡
wing = Wing(; #EDIT
chords    = [2.22, 2.22, 1.33], 
    foils     = [rootairfoil, meanairfoil, tipairfoil],
twists 	  = [1.5, 1.5, -0.5],
spans     = [3, 11.351],  #total wingspan is 28.65m  
sweeps    = [25, 25], 
w_sweep   = 0.25, 
dihedrals = fill(2.5, 2),
    symmetry  = true,
angle       = 2.5,            #Incidence angle (deg)
	axis = [0, 1, 0],
position    = [7.878, 0., 0.9]  #approximated last no.
); 
  ╠═╡ =#

# ╔═╡ b793ce10-7f1b-4f1e-8456-3514b3d87d2c
begin
	AR= 9.5
	Sref=72.72
end

# ╔═╡ dbd82758-56ae-429e-b770-ad913076f1f6
begin 
	K_LD   	   = 15.5 #civil jet
	#S_wet = (wetted_area(wing_mesh) + wetted_area(fuselage, 0:0.1:1) + wetted_area(horizontal_tail_mesh) + wetted_area(vertical_tail_mesh))
	#S   = 72.72 check
	Swett_Sref= 6#S_wet/Sref          #about 6  
	A_wett     = AR/Swett_Sref 
	LD_max     = K_LD * sqrt(A_wett)
	g=9.81
	println("L/Dmax: ", round(LD_max, digits=2))
end

# ╔═╡ 21857ef9-8b97-4f36-93e1-ebc0102ccee2
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
	V_cruise      = CRUISE.V #m/s 663.94357
	L_D_cruise    = LD_max *0.866 
	W4_W3  = exp(-Range_cruise*CRUISE.SFC*g/(3.6e6*L_D_cruise))

#Loiter Definition
	Endurance_loiter = 1800 #s 30 mins
	L_D_loiter    = LD_max    
	W5_W4         = exp(-Endurance_loiter*LOITER.SFC*g/(3.6e6*L_D_loiter))	
	
#Cruise  Definition diversion 200km to alternate airport
	Range_diversion = 200000.0  # m
    W6_W5 = exp(-Range_diversion * DIVERSION.SFC * g / ( 3.6e6*L_D_cruise))

#Loiter Definition
	Endurance_loiter2 = 1800 #s 30 mins
	W7_W6  = exp(-Endurance_loiter2*LOITER2.SFC*g/(3.6e6*L_D_loiter))	
	W8_W7 = 0.992


end;

# ╔═╡ ba1e355a-b8f8-4c92-933b-c6beefd30f19
begin
	W7_W0=W1_W0*W2_W1*W4_W3*W5_W4*W6_W5*W7_W6*W8_W7
	Wf_W0=1.02*(1-W7_W0) 
end

# ╔═╡ 05c6512c-e85c-4cf2-9e17-e6128d61182f
W0, weights, iterations=weight_iteration(A, C, W_payload, Wf_W0, W0_guess)

# ╔═╡ a206f8b9-d8db-4551-94ba-be0f54e020ec
plot(iterations, weights,
	     xlabel = "Iteration",
	     ylabel = "W₀ (kg)",
	     marker = :circle,
		 title = "W₀ Convergence",
	     legend = false)

# ╔═╡ ce7c8d19-fcdd-4d4c-981b-39b55012daca
W0 #check MTOW= 38800 kg

# ╔═╡ 47878d15-3650-432b-83ff-830912523cc2
begin
	#empty weight remains fixed
		We_W0=A*(W0)^(C) #lbs
	    We = We_W0 * W0 
end;

# ╔═╡ 3b36afa0-32c8-4534-9b39-022bb04194af
begin
	MTOW             = round(W0,digits=2)
	W_empty          = We
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

# ╔═╡ a4627a97-111c-486d-8313-1fe8600ab659
We #W_empty =  21700 kg kg  check

# ╔═╡ 4487ac73-a7f2-4462-8e34-c64f3c3776f6
Wf_W0*W0

# ╔═╡ d148f775-dc7f-4622-aff5-5607fa8e33b9
begin 
	#redefine with less payload
	W_payload2=W_payload*(1-λ)
	Embraer2 = Aircraft(MTOW, W_payload2, W_empty, Sref, AR, e, Cd0, maxfuelweight)
end

# ╔═╡ 70e174d1-516a-4f1c-b664-dcd265e4ab69
begin 
	FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, LOITER, DIVERSION, LOITER2, LAND]
	
	η=1
	Max_iterations=50000
		
	W_motor = component_weight(propulsion.P_max_engine * maximum(ϕ), propulsion.power_to_weight_motor)
    W_controller = component_weight(propulsion.P_max_engine * maximum(ϕ) / propulsion.η_motor,propulsion.power_to_weight_controller)
    W_PGD= W_motor + W_controller

	feasible, num_battery_packs, W_f = batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, Embraer2, W_PGD, batt, maxbatteryvolume, g, η, μ, LD_max;turbofan=true)

	
end;

# ╔═╡ d027008e-2931-403d-a6c9-5f81c7fb4b15
E_0total =batt.energystoragecapacity*num_battery_packs*3600/0.99 #multiply by 3600 to convert to Joules

# ╔═╡ c574a8bd-77d9-4f2c-b750-4407d472543d
begin
	W_batt=batt.weight*num_battery_packs
	println("battery weight: ", W_batt, "kg")
	println("fuel weight: ", W_f, "kg")
	TotalWeight= W_f + Embraer.W_empty + Embraer2.W_payload + W_PGD + W_batt 
	
	println("Total aircraft weight: ", TotalWeight, "kg")
	
	Valid, SOCstate, batterydepleted, leftoverfuel = runmission(FULLMISSION, propulsion, Embraer2, W_PGD, batt, num_battery_packs, W_f, g, η, μ, LD_max; turbofan=true)
end

# ╔═╡ c5913397-beb3-4be4-bc91-3e01a4b6021d
rangeparallel=Range_parallel(Embraer2, propulsion, E_0total, CRUISE.ϕ, LD_max, g)/1000

# ╔═╡ 3086f9ce-2a31-43cb-828c-9ac7729700dd
begin
	UnModified= PayloadRange(Embraer, propulsion, g, L_D_cruise; sfc_cruise=CRUISE.SFC)
	
	ModifiedAircraft=Aircraft(TotalWeight, Embraer2.W_payload , W_empty, Sref, AR, e, Cd0, maxfuelweight) #battery weight: 576.0kg, fuel weight: 7402.0kg, Total aircraft weight: 32245.239952601103kg
	Modified= PayloadRange(ModifiedAircraft, propulsion, g, L_D_cruise;W_batt=W_batt, sfc_cruise=CRUISE.SFC, W_PGD=W_PGD)
	
end

# ╔═╡ 04d523cc-29a6-4d9a-99a9-e36dd451b06c
begin
	plot(UnModified.ranges, UnModified.payloads, 
	     xlabel="Range (km)", ylabel="Payload (kg)",
	     title="Payload-Range Diagram (Breguet Range Equation)",
	     marker=:circle, 
		label ="Unmodified Embraer E175LR")
			
	plot!(Modified.ranges, Modified.payloads, marker=:circle, label ="Modified Embraer E175LR")


end

# ╔═╡ 41bcc938-1b5b-4d19-9c51-d48a17f7bf08
# ╠═╡ disabled = true
#=╠═╡
begin 
	AR = 9.5 # round(aspect_ratio(wing),digits=2) #AR = 9.5 check
	b_w = 26 #m span(wing)
	c_w = mean_aerodynamic_chord(wing)	
	Sref = round(projected_area(wing), digits=2)
	mac40_wing = mean_aerodynamic_center(wing, 0.40)
end;
  ╠═╡ =#

# ╔═╡ c7d1a8bd-5064-44b1-9fd2-2df5bec6c1ce
# ╠═╡ disabled = true
#=╠═╡
md""" #EDIT
## Empennage
The values are taken from literature. Where assumptions are made, values from similar/typical aircraft data was used. NACA0012 and NACA0009 are typical empennage airfoil codes. In practice, these values should be altered during the design process, as well as the wing's position to ensure the aircraft meets the stability requirements.
"""
  ╠═╡ =#

# ╔═╡ 02fc4aeb-1324-4d9b-a5d5-898557bf8760
md"### Vertical Tail"

# ╔═╡ ba17d9e9-03d8-44b2-b815-4d1b87a0f394
# ╠═╡ disabled = true
#=╠═╡
vertical_tail = WingSection( #EDIT
area        = 11.06, 	    #Area + dorsal fin (m²). 
aspect      = 1.58,  			
taper       = 0.6,  			#					GUESS
sweep       = 37, 			    #   				GUESS
w_sweep     = 0.,   			#Leading-edge sweep GUESS
root_foil   = naca4(0,0,1,2), 	#   				GUESS	
tip_foil    = naca4(0,0,1,2), 	#   				GUESS	
angle       = 90.,       		#To make it vertical
axis        = [1, 0, 0], 
position    = fuselage_end - [3.435+4.323-3, 0., -fuselage.d_rear]
);
  ╠═╡ =#

# ╔═╡ 94c33576-7fe5-432b-8eb6-2c1a7e9eb195
md"### Horizontal Tail"

# ╔═╡ efccb09e-a0c6-4866-a0d6-636c6bf86650
# ╠═╡ disabled = true
#=╠═╡
horizontal_tail = WingSection( #EDIT #span is 10m
area        = 9.03,  		    # Area (m²). 
aspect      = 4.97,  		    # Aspect ratio
taper       = 0.6,  		    # Taper ratio  				GUESS
dihedral    = 6,   		    	# Dihedral angle (deg)      GUESS
sweep       = 10,  		    	# Sweep angle (deg)         GUESS
w_sweep     = 0,   		        # Leading-edge sweep        GUESS
root_foil   = naca4(0,0,1,2), 	# Root airfoil              GUESS
tip_foil    = naca4(0,0,1,2), 	# Tip airfoil               GUESS
    symmetry    = true,
    angle       = 0, 
position    = vertical_tail.affine.translation + [ 2.8, 0., span(vertical_tail)-0.6],
); #GUESS
  ╠═╡ =#

# ╔═╡ c2b37621-c132-431b-8c5e-bfa234a915fa
md" ## Meshing"

# ╔═╡ 0bfcd316-d7cb-4553-a37b-7c4cdc4e5f83
#=╠═╡
begin
	wing_mesh = WingMesh(wing, [8,16], 10, span_spacing = Uniform());
	vertical_tail_mesh = WingMesh(vertical_tail, [8], 6);
	horizontal_tail_mesh = WingMesh(horizontal_tail, [10], 8);
end;
# Spacing: Uniform() or Cosine()
  ╠═╡ =#

# ╔═╡ 8bf081ba-b4da-4d26-a8c6-44d73e870c43
md"## Plotting Parameters"

# ╔═╡ 6b8b0f6f-4322-4141-8943-b660755a8998
begin
	φ_s 			= @bind φ Slider(-180:1e-2:180, default = 45)
	ψ_s 			= @bind ψ Slider(-180:1e-2:180, default = -45)
end;

# ╔═╡ 04238b63-52f6-4da9-b705-331515c0e27c
begin
	# Plot meshes
	plot_aircraft = plot(
	    # aspect_ratio = 1,
	    xaxis = "x", yaxis = "y", zaxis = "z",
	    zlim = (-10,15),#(-0.5, 0.5) .* span(wing_mesh),
		xlim = (-1,24),
		ylim = (-12.5,12.5),
	    camera = (φ, ψ),
		grid = false
	)
	
end;

# ╔═╡ Cell order:
# ╟─5f1441ea-2158-4b08-98db-7c85b92307d4
# ╟─4580f93b-25b0-4f41-bdfa-a0cd2f503278
# ╟─a7898977-e7d2-45e4-932e-2305f1c575a6
# ╟─82ade567-2d6a-4468-a50d-1703eaa88880
# ╟─d8161686-3e11-48a8-8dae-a2f3c0ad3530
# ╠═3b36afa0-32c8-4534-9b39-022bb04194af
# ╟─410d0ccc-953b-4d84-914d-c1d0d9678cb7
# ╟─5db55fae-5c62-48d8-a660-bbc6533dad2b
# ╟─06267e89-35b6-432c-8a1b-c1122c9261f6
# ╠═2595200d-b5e8-4529-a87a-175b94f74784
# ╠═2f91a7e1-5b5a-4436-89d5-8ea7c559d443
# ╟─157fcc13-a298-49ce-af0d-3b3b0b10e654
# ╠═f764aff5-df7d-4de8-8b39-4c72048779d9
# ╟─1f86389e-2a15-4dc8-a8b5-2b187854d8f5
# ╠═dbd82758-56ae-429e-b770-ad913076f1f6
# ╟─31cd5adf-d4df-4846-b5c1-a49c130281b9
# ╠═a4f8b5c0-f7d7-4710-87f0-5db6beee4759
# ╟─e92478ba-d042-4ef6-9337-309a6b22b1bc
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
# ╟─e8316533-6102-4ea6-8753-04dc5a95ac23
# ╠═c4b26590-6b14-4b0e-9da9-55a0f6bed709
# ╟─6121f5f8-c2eb-49e9-9cf2-cccfe8d9b96b
# ╠═c45f595d-6803-4452-9602-28099e37f733
# ╠═fad3fa47-f041-4d28-819e-2e7063076180
# ╟─0726a457-7f34-43bd-b489-c7748c186b4a
# ╠═d148f775-dc7f-4622-aff5-5607fa8e33b9
# ╠═70e174d1-516a-4f1c-b664-dcd265e4ab69
# ╠═c574a8bd-77d9-4f2c-b750-4407d472543d
# ╟─ee3f1393-dfe1-4d16-9a3f-70fe5ac771b6
# ╠═3086f9ce-2a31-43cb-828c-9ac7729700dd
# ╟─04d523cc-29a6-4d9a-99a9-e36dd451b06c
# ╟─6cede85c-66cb-44d7-ae17-eab1986447fd
# ╠═d027008e-2931-403d-a6c9-5f81c7fb4b15
# ╠═c5913397-beb3-4be4-bc91-3e01a4b6021d
# ╟─47197efd-2bfc-4048-88e9-2487edab78e0
# ╟─ab67beb3-78d1-4a24-a45c-77fe75495ea2
# ╟─b384c1f1-c683-4d16-9aab-f8a8c886f43f
# ╟─d6738bf8-367a-48e3-9d7b-7ab4dbcdc022
# ╠═e162d262-4e3c-45d0-a930-f66fd6f35cb2
# ╟─1add5b76-1ac6-4ee4-b0ed-1dfe5a543c2c
# ╠═c41e5b42-16e8-4f27-b58f-047e2726ea1f
# ╟─0081c681-7803-4cee-8c96-68b465a531e6
# ╠═f8f9b0e5-2af3-496d-84b5-4ad15e4227da
# ╠═dc1e45c9-d894-4c81-9ac7-b1bdb5ad384e
# ╠═b793ce10-7f1b-4f1e-8456-3514b3d87d2c
# ╠═41bcc938-1b5b-4d19-9c51-d48a17f7bf08
# ╠═c7d1a8bd-5064-44b1-9fd2-2df5bec6c1ce
# ╟─02fc4aeb-1324-4d9b-a5d5-898557bf8760
# ╠═ba17d9e9-03d8-44b2-b815-4d1b87a0f394
# ╟─94c33576-7fe5-432b-8eb6-2c1a7e9eb195
# ╠═efccb09e-a0c6-4866-a0d6-636c6bf86650
# ╟─c2b37621-c132-431b-8c5e-bfa234a915fa
# ╠═0bfcd316-d7cb-4553-a37b-7c4cdc4e5f83
# ╟─8bf081ba-b4da-4d26-a8c6-44d73e870c43
# ╠═04238b63-52f6-4da9-b705-331515c0e27c
# ╠═6b8b0f6f-4322-4141-8943-b660755a8998
