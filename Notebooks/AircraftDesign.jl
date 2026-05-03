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

# ╔═╡ 5152dc35-4705-485f-80ed-e6d5bd4410b6
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

# ╔═╡ 16b90e52-0e5d-11f1-ba99-a3a1d03a74d8
md" # Aircraft Design Process"

# ╔═╡ df01c5d2-22c3-4fbe-9a52-570e76acee91
md"""
This notebook goes through the aicraft design process. 
"""

# ╔═╡ 1f4caf8f-e1b4-4e59-b794-a038ef8d4110
md"**Define Packages**"

# ╔═╡ 22ad3350-9613-44ef-af64-1d97f20dd609
gr(
	size = (900, 700),  # INCREASE THE SIZE FOR THE PLOTS HERE.
	palette = :tab20    # Color scheme for the lines and markers in plots
)

# ╔═╡ f3fad18a-8f4f-4f8b-833a-40b7adec623c
md"""
# Aircraft Definition
The aircraft explored in this demonstration will be **Dornier 328**, modified to use hybrid electric propulsion.

![Three-perspective of Dornier 328](https://www.the-blueprints.com/blueprints-depot-restricted/modernplanes/dornier-modern/dornier_328-73581.jpg)
"""

# ╔═╡ 9c8da2a2-3ba3-4f4e-9f24-aaf59e29ab11
md"""
## Geometry
### Fuselage
"""

# ╔═╡ 9b97c743-9bfe-4fb0-bf6a-01d64b88b217
begin
		fuselage = HyperEllipseFuselage(
		#known
	    radius = 1.09,          # Radius, m 
	    length = 20.915,        # Length, m 
	    x_a    = 0.15,          # Start of cabin, ratio of length
	    x_b    = 0.7,         # End of cabin, ratio of length 
		#estimates
	    c_nose = 1.6,           # Curvature of nose 
	    c_rear = 1.2,           # Curvature of rear 
	    d_nose = -0.4,          # "Droop" or "rise" of nose, m
	    d_rear = 0.8,         # "Droop" or "rise" of rear, m 
	    position = [0.,0.,0.]   # Set nose at origin, m
	)
	fuselage_end = fuselage.affine.translation + [ fuselage.length, 0., 0. ];
end;

# ╔═╡ 2325f6f4-5bda-4313-848b-664baade9b62
md"""
### Wing
**Define the airfoil profiles**

For Dornier 328 the wing's root, midspan and tip airfoils are  DO A-5. Note that AeroFuse uses a discretisation method to compute the wing parameters so they vary slightly from the literature. Accuracy is acceptable.
"""

# ╔═╡ 5fb1772d-3502-4013-9f7a-fc87436d0319
begin
	wingairfoil = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=doa5-il"))
end;

# ╔═╡ 87000157-8db7-4c13-9dc2-07dc3c10aeb1
wing = Wing(;
    chords    = [2.22, 2.22, 1.33], 
    foils     = [wingairfoil,wingairfoil, wingairfoil],
	twists 	  = [1.5, 1.5, -0.5],
	spans     = [3.15, 7.338],   
	sweeps    = [0.0, 7.1], 
	w_sweep   = 0.25, 
    dihedrals = fill(2.5, 2),
    symmetry  = true,
    angle       = 2.5,            #Incidence angle (deg)
	axis = [0, 1, 0],
    position    = [7.878, 0., 0.9]  #approximated last no.
); 

# ╔═╡ 5d580497-0090-4b9b-93b3-d9894e39b5d7
begin
	AR = round(aspect_ratio(wing),digits=2)
	b_w = span(wing)
	c_w = mean_aerodynamic_chord(wing)	
	Sref = round(projected_area(wing), digits=2)
	mac40_wing = mean_aerodynamic_center(wing, 0.40)
end;

# ╔═╡ 6458400c-5d27-4620-a489-2cb66cb83924
md"""
### Empennage
The values are taken from literature. Where assumptions are made, values from similar/typical aircraft data was used. NACA0012 and NACA0009 are typical empennage airfoil codes. In practice, these values should be altered during the design process, as well as the wing's position to ensure the aircraft meets the stability requirements.
"""

# ╔═╡ 06d6d58d-59c3-4bd4-9ab7-e5fa1170b8c5
md"#### Vertical Tail"

# ╔═╡ e12042e7-0c31-4ab4-80dc-9a1954fec320
vertical_tail = WingSection(
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


# ╔═╡ 11f864fc-cfd8-49eb-bb3c-d781f0676687
md"#### Horizontal Tail"

# ╔═╡ e0395b84-7a0f-42cc-947d-909ac9a85a21
horizontal_tail = WingSection(
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


# ╔═╡ 1af18536-819d-45a0-b158-2f1de3cfb698
@bind batteryselection Select(["PB345V124E-L"])

# ╔═╡ 92a4637a-8798-4c2d-bffb-14ac490bb202
batt=battery(batteryselection)

# ╔═╡ 2e21622b-dec2-439e-bd20-8616ef6c2c03
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

# ╔═╡ 68ed9469-3059-4027-ba8e-7879b5cab5ff
md"## Initial Sizing"

# ╔═╡ 266333df-bd57-4b46-a637-d3d50d62b0d4
md"""
Compute the following parameters
* Empty Weight Fraction $W_e/W_0$ 
* Fuel Weight Fraction $W_f/W_0$ 
* Initial $W_0$ guess
* Specific Fuel Consumption
* L/D Estimation

For propeller driven aircraft

$Range=\frac{η_p}{c_p} \frac{L}{D} ln\left( \frac{W_0}{W_1}\right)$
"""

# ╔═╡ f3eda30f-f6ee-411b-80ac-4d1c62cb1d0e
md"""
### L/D max
An estimate for maximum $L/D$ is given by Raymer.

$A_{wetted}=\frac{b^2}{S_{wett}}=\frac{AR}{ S_{wett}/S_{ref}}$

$L/D_{max} = K_{LD} \sqrt{ \frac{AR}{ S_{wett}/S_{ref}  } }$

The following approximation for wetted area is calculated from the fuselage and empennage surfaces. It does not account for the intersection of surfaces and the fuselage nor the engine nacelles.

For an initial assumption can assume $S_{wett}/S_{ref}=4$ or $5$ and assume $K_{LD}=15.5$. Note: Can compte actual $S_{wett}/S_{ref}$ later.
"""

# ╔═╡ 578fae6d-1231-4ecf-ab61-37e622b7fafb
md""" 
Additionally, for a propeller driven aircraft, $L/D_{max}$ varies for cruise and loiter. Cruise $L/D_{max}=L/D_{max}$ and Loiter $L/D_{max}=0.866L/D_{max}$

"""

# ╔═╡ 5752e7ce-6f6a-4f8e-b2db-b997eed15a7b
md"""
### Specific Fuel Consumption
Dornier 328-100 (Turboprop) is equipped with 2 Pratt & Whitney Canada PW119B/C engines. These are rated with a specific fuel consumption of 0.332 kg/(kW h).

For a propeller driven aircraft, SFC is dependent on the flight conditions. SFC can be approximated using the equation $C=C_{bhp}\frac{V}{550 η_p}$. These equations assume V is in ft/s and $C_{bhp}$ is in lb/(hp·hr).

Typical values for $C_{bhp}$ range from 0.5-0.8 at cruise and 0.6-0.8 for loiter. 

"""

# ╔═╡ 093b57dd-82e8-4308-9a6e-cdc882d546d1
SFC=0.332 

# ╔═╡ 0072aa17-ef77-48ec-84cb-356b84dff6b0
begin
	η_p=0.85 #typical value
	C_bhp_cruise=0.5 #given as lb/(hp·hr)
	C_bhp_loiter=0.6 #given as lb/(hp·hr)
end;

# ╔═╡ 9fad7afa-24f2-4307-8212-98c366c1461d
begin
	η_motor                    		= 0.97 #95-97% efficiency   
	η_controller               		= 0.96
	η_battery                 		= 0.95
	specificenergy             		= batt.packspecificenergy
	SOC_min                    		= 0.2
	power_to_weight_motor      		= 5200
	power_to_weight_controller 		= 3702.70
	W_engine 				   		= 411.4*2
	P_max_engine 			   		= 3251252
	No_Engines                 		= 2
	energy_density_fuel       	    = 11900.0
	η_gas_turbine_efficiency 		= 0.35  
	η_gearbox_efficiency 			= 0.95
	η_electric_generator_efficiency = 0.98
	
	propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, SFC, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_p, η_electric_generator_efficiency)
end

# ╔═╡ 76887937-77d8-493e-8d20-9368018a0da0
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

# ╔═╡ 2096a77b-f6df-4b35-bf80-27951ad525c6
md"""
### Fuel Weight Fraction
As fuel is consumed during flight, it's maximum varies with the mission requirements, so these must be defined beforehand. The mission segment weight fractions are given as:
1) Taxi and Takeoff $W_1/W_0=0.97$ (Raymer)
2) Climb $W_i/W_{i-1}=0.985$ (Raymer)
3) Cruise $W_i/W_{i-1} = e^{-\frac{RC}{V L/D}}$
4) Loiter $W_i/W_{i-1} = e^{-\frac{EC}{L/D}}$
5) Cruise 
6) Loiter 
7) Landing $W_i/W_{i-1}=0.995$ (Raymer)
The aircraft has 1-2% trapped fuel so $W_f/W_0=1.01(1-W_x/W_0)$
"""

# ╔═╡ df072a6c-b035-4099-9ace-75d631621598
md"""
### $W_0$ Convergence
The convergence of $W_0$ is based on an initial guess and regression data. It combines both equations $W_0 = \frac{W_{crew}+W_{payload}}{1- \left(\frac{W_f}{W_0} \right)- \left(\frac{W_e}{W_0} \right)  }$ and $W_e=AW^C_0$. 

Dornier 328 is characterised as a twin turboprop aircraft. Thus A=0.96 and C=-0.05.
"""

# ╔═╡ c58f47e8-3471-488b-bc66-e0476dd7964c
begin
	W0_guess = 10000 #13989.999782 kg  #Dornier 328 MTOW
	A=0.96                
	C=-0.05
	W_payload    =    3540
end;

# ╔═╡ aa61fd67-2f96-48ea-b2e2-96c80fa9cdad
md"""
## Payload Range Diagram
The payload range diagram has 4 features/points
1. Maximum payload, zero range
2. Maximum payload, max range
3. Maximum fuel, some payload remaining
4. Zero payload, maximum fuel
"""

# ╔═╡ 6f2ea22d-164d-4059-a575-6f45d24b6dbb
md"""
# Constraint Diagram
## Aircraft Constraints
Dornier 328 comes under FAR-25 regulations

* Climb (OEI)
* cruise
* takeoff
* ceiling
* max speed
* landing
* stall speed
* min W0/S
* FAR-25 OEI take-off, landing gear extended
* FAR-25 OEI take-off, landing gear retracted
* FAR-25 OEI final take-off
* FAR-25 OEI final approach
* Take-off: 50ft obstacle
* Take-off: BFL
* Max Turn
* Climb (clean)
* Climb (t/o)
"""

# ╔═╡ 5d05a1a7-b352-4a8f-83dd-84a3b41bd129
begin
	CL_max_clean   =  1.4 #guess 1.2 to 1.8
	CL_max_land    =  2   #guess 1.8-2.8
	CL_max_takeoff = (CL_max_land-CL_max_clean)*0.7 +CL_max_clean

	FieldLength= 1010
end;

# ╔═╡ 98cf803c-d5fb-448e-b0ef-5998d85dbc3a
md"""
## Point Performance
Specific Excess power is defined as:

$\frac{dh}{dt} + \frac{V_∞}{g}\frac{dV_∞}{dt}=\frac{P}{W}-\frac{V_∞ D}{W}$

assuming a parabolic drag curve at load factor n:

$\frac{1}{L/D} =\frac{D}{W}=\frac{ \frac{1}{2}ρV_∞^2 C_{D_0}  }{W/S_{ref}}+\frac{n^2 W/S_{ref}}{\frac{1}{2}ρV_∞^2π AR e}$

where $C_{D_0}=f\left(S_{wet}/S_{ref}\right)$

$\left( \frac{L}{D} \right)_{max}=\frac{1}{2} \sqrt{ \frac{π AR e}{C_{D_0}}}$

and dependent on configuration:
* undercarriage $ΔC_{D_0}≈0.02$ and $Δe≈-0.05$ (note: only relevant if mounted on the wings)
* t/o flaps  $ΔC_{D_0}≈0.02$ and $Δe≈-0.05$
* landing flaps  $ΔC_{D_0}≈0.07$ and $Δe≈-0.1$

For Propeller driven aircraft
## Specific Excess Power

$$\bigg( \frac{P}{W} \bigg)_0 = \frac{V_\infty \alpha}{\eta_{prop} \beta} \bigg[ \frac{1}{V_\infty} \frac{dh}{dt} + \frac{1}{g} \frac{dV_\infty}{dt} + \frac{\frac{1}{2}\rho V_\infty^2 C_{D_0}}{\alpha W_0/S_{ref}} + \frac{\alpha n^2 W_0/S_{ref}}{\frac{1}{2}\rho V_\infty^2 \pi AR e} \bigg]$$


For climb:

$$\bigg( \frac{P}{W} \bigg)_0 = \frac{V_\infty \alpha}{\eta_{prop} \beta} \bigg[ G + \frac{C_{D_0}}{\alpha C_L} + \frac{\alpha C_L}{\pi AR e} \bigg]$$



For cruise:

$$\bigg( \frac{P}{W} \bigg)_0 = \frac{V_\infty \alpha}{\eta_{prop} \beta} \bigg[ 
\frac{\frac{1}{2}\rho V_\infty^2 C_{D_0}}{\alpha W_0/S_{ref}} + \frac{\alpha n^2 W_0/S_{ref}}{\frac{1}{2}\rho V_\infty^2 \pi AR e}
\bigg]$$

where $α=\frac{W}{W_0}$ and $β=\frac{P}{P_0}$ which are scaled to sea-level, static and take off conditions as a function of altitude and Mach number.
"""

# ╔═╡ e9b5ca0d-e954-4e95-b545-7c7dc0223a58
W_S = range(500, 8000, length=1000)

# ╔═╡ 6bda136d-e082-4e15-ab68-58e5fb8ca645
md"""
## Field Performance

**Based on the physical runway**
* Take-off distance available (TODA)
* Landing distance available (LDA)

**Performance Specifications**
* Take-off distance required - 15% safety factor above actual take-off distance
* Landing distance required - 66% safety factor above actual landing distance

**Real conditions**
* Actual take-off distance - what is required all engines operating (AEO)
* Balanced field length (BFL)
* Actual landing distance - ideally require

Note: for design purposes we always assume dry, flat runway with no crosswind.

## Takeoff distance
Parameters which affect take-off distance:
* Stall speed ($ρ$, $W/S$, $C_{L_{max_{t/o}}}$)
* Ground acceleration ($P/W$, $W$, $C_{D_0}$, $μ$)
* Excess power ($P/W$, $C_{D_0}$, $W/S$)
* Obstacle height

$BFL: TODA >= (0.0101)TOP$
$TOP=\frac{W/S}{P/W σ C_{L_{LOF}}}$
$AEO  (50ft): TODA>=0.00914TOP$
where $σ=\frac{ρ}{ρ_0}$, $V_{LOF}=1.1V_{stall}$ and $N_E$ is the number of engines. The TOP has units in $N/m^2$
Note: the coefficient terms are based on empirical data.
"""

# ╔═╡ 1381e1a6-bbca-43de-aa33-65ce363a2272
md"""
## Landing Distance
Parameters which affect landing distance:
* Approach speed ($V_{stall}$, $ρ$, $W/S$, $C_{L_{maxL}}$)
* Deceleration ($P/W$, $μ$, Thrust reversal)
* Glide slope ($γ_{approach}$, $P/W$, $C_{D_0}$, $W/S$)
* Obstacle height

$ALD = 0.51 \frac{W/S}{\sigma C_{L_{maxL}}}K_R +S_a$
where $S_a=305$m for Dornier 328. With thrust reveral, $K_R=0.66$. 
Note: there is no mention of variations in drag. 

Landing distance constraint
$W_0/S_{max}=0.5 ρV_{sL}^2C_{L_{max,land}}$
"""

# ╔═╡ 893a1cd5-6fec-4ed5-af44-bf2ecb77a172
begin 
	RunwayLength=2500
	ActualLandingDistance=FieldLength*0.6
	SL= ActualLandingDistance*3.28  #ft
	Va=(FieldLength*3.28/0.3)^0.5 #kts
	V_sl=Va/(1.3*1.944) #converted to m/s
	W_S_land = 1.225*V_sl^2*CL_max_land
end;

# ╔═╡ c10629a3-ed21-42e2-99a2-44a6942bda16
begin
	#assume σ=1
	TODA_min=RunwayLength/1.15
	PW_50ft_takeoff=11.7 .* W_S ./ (TODA_min * CL_max_takeoff*0.88);
end;

# ╔═╡ 1b7762fa-112d-487f-a9ed-3c9da9e5b819
begin
	WS_stall=(1/0.80645)*1.225*V_sl^2*CL_max_land;
end;

# ╔═╡ 8c24afaa-c13a-49f5-9309-d21bc7ff8254
md"""
# Battery Sizing Methodology

"""

# ╔═╡ 4a894509-afa5-4279-8b83-029f6afb122e
md"""
## Hybridization Ratio
The Hybridization ratio is defined as 

$ϕ=\frac{P_{EM}}{P_{EM}+P_{FB}}$

so when ϕ=1 it is a fully electric aircraft and when ϕ=0 it is a conventional aircraft.
"""

# ╔═╡ 9e21a206-1389-4abb-83a7-6be01765398e
begin
	ϕ = [0.2, 0.2, 0.2, 0.0, 0.0]
	ϕ1 				= ϕ[1]
	ϕ2 				= ϕ[2]
	ϕ3 				= ϕ[3]
	ϕ4 				= ϕ[4]
	ϕ5 				= ϕ[5]
end;

# ╔═╡ 76aad264-db25-4d84-bca0-29bd40934bca
begin
	name1            = "Taxi"
	h1   			= 0.0
	V1 				= 10.0
	duration1 		= 180.0
	ROC1 			= 0.0
	load1 			= 1.0
	dVdt1 			= 0.0
	T1, P1, ρ1  = atmosphere(h1);
	ρ1 = round(ρ1,digits=3)
	
	name2            = "Takeoff"
	h2   			= 457.178
	V2 				= 70.0
	duration2 		= 60 #60 or 30
	ROC2 			= 0.0
	load2 			= 1.0
	dVdt2 			= 0.0
	T2, P2, ρ2  = atmosphere(h2);
	ρ2 = round(ρ2,digits=3)
	μ=0.02

	name3            = "Climb"
	h3   			= 9448.339
	duration3 		= 5.0*60.0 
	ROC3 			= 0.508
	load3 			= 1.0
	dVdt3 			= 0.0
	T3, P3, ρ3  = atmosphere(h3);
	ρ3 = round(ρ3,digits=3)
	V3 = 92.6 * sqrt(1.225 / ρ3); # m/s
	
	
	name4            = "Cruise"
	h4   			= 9448.34
	V4 				= 150.8333
	duration4 		= 10741.935 #10741.93548  #5000
	ROC4 			= 0.0
	load4 			= 1.0
	dVdt4 			= 0.0
	T4, P4, ρ4  = atmosphere(h4);
	ρ4 = round(ρ4,digits=3)

	name5            = "Land"
	h5   			= 457.178
	V5 				= 56.667
	duration5 		= 180.0
	ROC5 			= 0.0
	load5 			= 1.0
	dVdt5 			= 0.0
	T5, P5, ρ5  = atmosphere(h5);
	ρ5 = round(ρ5,digits=3)

	TAXI = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ1, load1, dVdt1, ρ1)
	TAKEOFF = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ2, load2, dVdt2, ρ2)
	CLIMB = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ3, load3, dVdt3, ρ3)
	CRUISE = MissionSegment(name4, h4, V4, duration4, ROC4, ϕ4, load4, dVdt4, ρ4)
	LAND = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ5, load5, dVdt5, ρ5)
end;

# ╔═╡ 0520fd1c-f0ba-429e-9ce6-b907bee5ac64
md"""
## Mission Requirements

|Segment        | TAXI | TAKEOFF| CLIMB | CRUISE | LAND |
|---            | -----| ------ | ----- | ------ | ---- |
|name           | $name1| $name2| $name3| $name4| $name5|
|Velocity (m/s) | $V1 | $V2 | $V3 | $V4 | $V5 | 
|Duration (s)   | $duration1 | $duration2 | $duration3 | $duration4 | $duration5 |
|ROC (m/s)      | $ROC1 | $ROC2 | $ROC3 | $ROC4 | $ROC5 |
|Load           | $load1 | $load2 | $load3 | $load4 | $load5 |
|dV/dt          | $dVdt1 | $dVdt2 | $dVdt3 | $dVdt4 | $dVdt5 |
|Density        | $ρ1| $ρ2 | $ρ3 | $ρ4 | $ρ5 |
Note: In order for the code to work the name of the cruise segment must be Cruise and the name of the climb segment must be Climb. 
"""

# ╔═╡ 4a2e634a-f9e5-42d6-8c26-5eebbc97d11c
md"## Battery Geometry Constraints"

# ╔═╡ aa910e6a-d8a5-431f-8c3b-7395fa3925c9
md"""
Since we are retrofitting an existing aircraft, the geometry is constrained. Need to define how much space will be available for the battery and how much payload we need to sacrifice.

"""

# ╔═╡ 71eff9ab-acab-4ed0-9512-60785a3a37f7
begin
	φ_s1 			= @bind φ1 Slider(-180:1e-2:180, default = 45)
	ψ_s1 			= @bind ψ1 Slider(-180:1e-2:180, default = -45)
end;

# ╔═╡ 44d4c914-3215-43c1-948a-f6f11cb468f7
p = plot(
    # aspect_ratio = 1,
	    xaxis = "x", yaxis = "y", zaxis = "z",
	    zlim = (-10,15),#(-0.5, 0.5) .* span(wing_mesh),
		xlim = (-1,24),
		ylim = (-12.5,12.5),
	    camera = (φ1, ψ1),
		grid = false
);

# ╔═╡ 6c0c0edb-3bc1-4ae0-96ae-791f4ab8f605
plot!(p, fuselage, label = "Fuselage");

# ╔═╡ 430c9098-db78-48ca-b76f-a61c7e7b85cb
toggles1 = md"""
φ: $(φ_s1)
ψ: $(ψ_s1)
"""

# ╔═╡ 46b0a69b-1442-4d90-be85-d79ae0190573
md"""
PRINT: payload sacrifice?
PRINT: Volume capacity of batteries?
PRINT: estimated no. batteries (max?)
"""

# ╔═╡ 28d93b23-0ebe-4102-a562-cc81bdbd5d9a
md"## Battery Sizing"

# ╔═╡ 130dc8ea-cc20-4023-a33a-3e8df3c88009
md"## Payload Range Diagram"

# ╔═╡ 0e3c3a9e-fb7b-4deb-b1c9-27c23fdfdafc
md"## Adjustment of Payload Weight"

# ╔═╡ c46bae33-6e12-4df2-83ad-77d73546e4fc
md"""
## Range equation
Total input energy=Battery energy storage capacity x number of battery packs /charging efficiency. The charging efficiency is approximately 97%.
"""

# ╔═╡ b062c846-a885-4a56-b54f-d72718d47bf3
md"# Plots"

# ╔═╡ 4e85b6e5-78d6-4201-a914-3bedb996acea
md"## Meshing"

# ╔═╡ 4e74f82f-7963-4447-a7d8-6654d6a40bed
begin
	wing_mesh = WingMesh(wing, [8,16], 10, span_spacing = Uniform());
	vertical_tail_mesh = WingMesh(vertical_tail, [8], 6);
	horizontal_tail_mesh = WingMesh(horizontal_tail, [10], 8);
end;
# Spacing: Uniform() or Cosine()

# ╔═╡ 334de92f-d89b-47e8-aed7-f390fb25adaf
begin
	K_LD   	   = 11 # retractable propeller aircraft
	S_wet = (wetted_area(wing_mesh) + wetted_area(fuselage, 0:0.1:1) + wetted_area(horizontal_tail_mesh) + wetted_area(vertical_tail_mesh))
	Swett_Sref=S_wet/Sref
	A_wett     = AR/Swett_Sref
	LD_max     = K_LD * sqrt(A_wett)
	g=9.81
	println("L/Dmax: ", round(LD_max, digits=2))
end

# ╔═╡ 738917d2-f2f9-4755-970a-52fdd1e10722
begin
	W1_W0 = 0.97
	W2_W1 = 0.985
	
#Cruise (2) Definition
	Range_cruise = 1850000.059#m 6069554 #ft
	V_cruise      = CRUISE.V #m/s 663.94357
	cp_cruise   = C_bhp_cruise* (0.4536 / (745.7 * 3600))  # kg/(W·s) 
	L_D_cruise    = LD_max
	W3_W2  = exp(-Range_cruise*cp_cruise*g/(η_p *L_D_cruise))

#Loiter (4) Definition
	Endurance_loiter = 1800 #s 30 mins
	cp_loiter      = C_bhp_loiter* (0.4536 / (745.7 * 3600))  # kg/(W·s)
	L_D_loiter    = LD_max *0.866   
	W4_W3         = exp(-Endurance_loiter*cp_loiter*g/(η_p*L_D_loiter))	
	
#Cruise (5) Definition diversion 200km to alternate airport
	Range_diversion = 200000.0  # m
    W5_W4 = exp(-Range_diversion * cp_cruise * g / (η_p * L_D_cruise))

#Loiter (6) Definition
	Endurance_loiter2 = 1800 #s 30 mins
	W6_W5  = exp(-Endurance_loiter2*cp_loiter*g/(η_p*L_D_loiter))	
	W7_W6 = 0.995

end;

# ╔═╡ 57a066a3-c787-493f-afd4-7d16a64fbc81
begin
	W7_W0=W1_W0*W2_W1*W3_W2*W4_W3*W5_W4*W6_W5*W7_W6
	Wf_W0=1.02*(1-W7_W0) 
end;

# ╔═╡ f2652873-9d4e-4e2d-990f-8ee9f8830dcd
W0, weights, iterations=weight_iteration(A, C, W_payload, Wf_W0, W0_guess)

# ╔═╡ 144256ba-7bb1-4d0d-8e65-ca161ecd5ae7
plot(iterations, weights,
	     xlabel = "Iteration",
	     ylabel = "W₀ (kg)",
	     marker = :circle,
		 title = "W₀ Convergence",
	     legend = false)

# ╔═╡ a2eafcf8-b4f3-4631-bbb5-d27bea346c8d
begin
	#empty weight remains fixed
		We_W0=A*(W0 * 2.205)^(C) #lbs
	    We = We_W0 * W0 
end;

# ╔═╡ 11cc591b-2a65-4b04-b216-427c2753083e
begin
	MTOW             = round(W0,digits=2)
	W_empty          = We
	e                = 0.8
	Cd0              = round(π*AR*e/(2*LD_max)^2, digits=4)
	maxfuelweight    = 3427.80
	maxbatteryvolume = 100
	Dornier328 = Aircraft(MTOW, W_payload, W_empty, Sref, AR, e, Cd0, maxfuelweight, maxbatteryvolume)
end

# ╔═╡ b4afeffc-df5f-4273-b26a-069895ec2969
md"""
### Dornier 328
| Variable         | Value    | Units |
| ----             | ---      |  ---  |
| MTOW             | $MTOW    | kg    |
| W_payload        | $W_payload         | kg    |
| W_empty          | $W_empty        | kg    |
| AR               | $AR      | -     |         
| e                | $e       | -     | 
| Cd0              | $Cd0     | -     |
| maxfuelweight    | $maxfuelweight        | kg    |
| maxbatteryvolume | $maxbatteryvolume        | m^3   |
| S                | $Sref    | m^2   |

$C_{D_0}=\frac{π AR e}{2 \left( L/D\right)^2_{max}}$
"""

# ╔═╡ 4bd41ff1-58bf-4ae9-b76a-9954c6007fa7
W_fuel_max = Dornier328.maxfuelweight

# ╔═╡ 01ddc548-6ca2-46a7-a450-5c4f2a91b295
begin
	α_cruise=W3_W2*W2_W1*W1_W0
	α_climb=W2_W1*W1_W0
	β_cruise=(CRUISE.ρ/1.225)^0.7
	β_climb=(CLIMB.ρ/1.225)^0.7
	PW_cruise=P_W(W_S, α_cruise, β_cruise, CRUISE, propulsion, Dornier328)
	PW_climb=P_W(W_S, α_climb, β_climb, CLIMB, propulsion, Dornier328)
	PW_ceiling=P_W(W_S, α_cruise, β_cruise, CRUISE, propulsion, Dornier328, constraint="ceiling", altitude=9492)
end;

# ╔═╡ 09cb2e0e-2a12-48f8-b6ba-9db79fce1474
begin
	plot(W_S,PW_cruise,
	 #ylims=(0,1),
	 xlabel="Wing Loading (W₀/S) N/m²",
	 ylabel="Power/Weight (P₀/W₀) W/N",
	 title="Constraint Diagram",
	 label="Cruise"
	)
	plot!(W_S,PW_climb, label="Climb")
	vline!([W_S_land], label="Landing constraint")
	hline!([PW_ceiling], label="Ceiling")
	vline!([WS_stall], label="Stall speed constraint")
	plot!(W_S,PW_50ft_takeoff, label="50ft obstacle")
end

# ╔═╡ d38bb742-f4a9-442b-ae06-8ca85e71ef25
ranges_pts1, payloads_pts1= PayloadRange(Dornier328, propulsion,g,cp_cruise, L_D_cruise )

# ╔═╡ 47b35b82-1587-4416-8453-29e2a0f03576
begin
	FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, LAND]
	η=1
	Max_iterations=1000
		
	W_motor = component_weight(propulsion.P_max_engine * maximum(ϕ), propulsion.power_to_weight_motor)
    W_controller = component_weight(propulsion.P_max_engine * maximum(ϕ) / propulsion.η_motor,propulsion.power_to_weight_controller)
    W_PGD= W_motor + W_controller

	feasible, num_battery_packs, W_f = batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, Dornier328_2, W_PGD, batt, g, η, μ, LD_max)

	
end;


# ╔═╡ ab708373-6257-4d2c-9ac1-bfe7a8557d57
E_0total =batt.energystoragecapacity*num_battery_packs*3600/0.99 #multiply by 3600 to convert to Joules

# ╔═╡ 54795191-d781-4356-9481-7a0eec463735
begin 
	W_batt=batt.weight*num_battery_packs
	println("battery weight: ", W_batt, "kg")
	println("fuel weight: ", W_f, "kg")
	TotalWeight= W_f + Dornier328.W_empty + Dornier328_2.W_payload + W_PGD + W_batt ;
	println("Total aircraft weight: ", TotalWeight, "kg")
	
	Valid, SOCstate, batterydepleted, leftoverfuel = runmission(FULLMISSION, propulsion, Dornier328_2, W_PGD, batt, num_battery_packs, W_f, g, η, μ, LD_max)
end;

# ╔═╡ 704396e7-6392-49fc-ba42-1d622db000ee
begin
	ranges_pts2, payloads_pts2= PayloadRange(Dornier328_2, propulsion,g,cp_cruise, L_D_cruise; Wf=W_f, W_batt)
end

# ╔═╡ 803146ae-fe59-4f03-a53d-9c93180405e6
begin
	plot(ranges_pts1, payloads_pts1, 
	     xlabel="Range (km)", ylabel="Payload (kg)",
	     title="Payload-Range Diagram (Breguet Range Equation)",
	     marker=:circle, 
		label ="Unmodified Dornier-328")
	plot!(ranges_pts2, payloads_pts2, 
	    marker=:circle, 
	label ="Modified Dornier-328")
	#plot!(ranges,weights1)
end

# ╔═╡ 71756627-d512-4f7f-9794-37dd7d2de3f7
payloads_pts2

# ╔═╡ 1fec0699-c0c0-468a-871a-6b7a598d6b1c
# ╠═╡ disabled = true
#=╠═╡
plot(W_payload2, batteryw,
	ylabel="Battery Weight (kg)",
	xlabel="Payload Weight (kg)")

  ╠═╡ =#

# ╔═╡ d2cb60f0-98aa-452e-ac55-adf32f4614b1
# ╠═╡ disabled = true
#=╠═╡
plot(W_payload2, totw,
	ylabel="Total Weight (kg)",
	xlabel="Payload Weight (kg)")
  ╠═╡ =#

# ╔═╡ 11813f6f-6323-4022-ae19-71b3714ee0f8
rangeparallel=Range_parallel(Dornier328_2, propulsion, E_0total, CRUISE.ϕ, LD_max, g)/1000

# ╔═╡ 25d5cd62-72a3-443f-95bf-9cda755e9742
md"## Plotting Parameters"

# ╔═╡ e63ed07e-364e-4477-9773-6444aae161f5
begin
	φ_s 			= @bind φ Slider(-180:1e-2:180, default = 45)
	ψ_s 			= @bind ψ Slider(-180:1e-2:180, default = -45)
end;

# ╔═╡ 291f2c97-ebca-4d59-9d4f-a14ae0109df1
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

# ╔═╡ bf4fec26-32c6-457d-a470-8104bb9f5b35
begin
	plot!(plot_aircraft, horizontal_tail_mesh, label = "Horizontal Tail", mac = false)
	plot!(plot_aircraft, vertical_tail_mesh, label = "Vertical Tail", mac = false)
	plot!(plot_aircraft, fuselage, label = "Fuselage")
	plot!(wing_mesh, label = "Wing", mac = false)
	#	plot!(horizontal_tail_mesh, label = "Horizontal Tail", mac = false)
	#	plot!(vertical_tail_mesh, label = "Vertical Tail", mac = false)
end

# ╔═╡ 77d10527-b376-4672-b623-98d7e8ab2428
toggles = md"""
φ: $(φ_s)
ψ: $(ψ_s)
"""

# ╔═╡ 302b6862-a5c6-4d8e-afca-5afcdebb6f23
#=╠═╡
begin
	#redefine Dornier 328 with less payload
	W_payload2=W_payload/1.4
	Dornier328_2 = Aircraft(MTOW, W_payload2, W_empty, Sref, AR, e, Cd0, maxfuelweight, maxbatteryvolume)
end
  ╠═╡ =#

# ╔═╡ 7aefeaee-0db2-45d6-8f7d-7d1b5627afdc
# ╠═╡ disabled = true
#=╠═╡
begin
	#redefine Dornier 328 with less payload
	W_payload2=range(W_payload/2, 0, length=100)
	#W_payload2=W_payload/2
	batteryw=[]
	totw=[]
	for w in W_payload2
		Dornier328_2 = Aircraft(MTOW, w, W_empty, Sref, AR, e, Cd0, maxfuelweight, maxbatteryvolume)
	
		FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, LAND]
	
		η=1
		Max_iterations=1000
			
	
		W_motor = component_weight(propulsion.P_max_engine * maximum(ϕ), propulsion.power_to_weight_motor)
	    W_controller = component_weight(propulsion.P_max_engine * maximum(ϕ) / propulsion.η_motor,propulsion.power_to_weight_controller)
	    W_PGD= W_motor + W_controller
	
		feasible, num_battery_packs, W_f = batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, Dornier328_2, W_PGD, batt, g, η, μ, LD_max)
	
	
	
	
		W_batt=batt.weight*num_battery_packs
		TotalWeight= W_f + Dornier328.W_empty + Dornier328_2.W_payload + W_PGD + W_batt ;
		push!(batteryw, W_batt)
		push!(totw, TotalWeight)
		
	end
end
  ╠═╡ =#

# ╔═╡ Cell order:
# ╟─16b90e52-0e5d-11f1-ba99-a3a1d03a74d8
# ╟─df01c5d2-22c3-4fbe-9a52-570e76acee91
# ╟─1f4caf8f-e1b4-4e59-b794-a038ef8d4110
# ╟─5152dc35-4705-485f-80ed-e6d5bd4410b6
# ╟─22ad3350-9613-44ef-af64-1d97f20dd609
# ╟─f3fad18a-8f4f-4f8b-833a-40b7adec623c
# ╟─9c8da2a2-3ba3-4f4e-9f24-aaf59e29ab11
# ╠═9b97c743-9bfe-4fb0-bf6a-01d64b88b217
# ╟─2325f6f4-5bda-4313-848b-664baade9b62
# ╠═5fb1772d-3502-4013-9f7a-fc87436d0319
# ╠═87000157-8db7-4c13-9dc2-07dc3c10aeb1
# ╠═5d580497-0090-4b9b-93b3-d9894e39b5d7
# ╟─6458400c-5d27-4620-a489-2cb66cb83924
# ╟─06d6d58d-59c3-4bd4-9ab7-e5fa1170b8c5
# ╠═e12042e7-0c31-4ab4-80dc-9a1954fec320
# ╟─11f864fc-cfd8-49eb-bb3c-d781f0676687
# ╠═e0395b84-7a0f-42cc-947d-909ac9a85a21
# ╟─b4afeffc-df5f-4273-b26a-069895ec2969
# ╠═11cc591b-2a65-4b04-b216-427c2753083e
# ╟─76887937-77d8-493e-8d20-9368018a0da0
# ╟─9fad7afa-24f2-4307-8212-98c366c1461d
# ╟─2e21622b-dec2-439e-bd20-8616ef6c2c03
# ╠═1af18536-819d-45a0-b158-2f1de3cfb698
# ╠═92a4637a-8798-4c2d-bffb-14ac490bb202
# ╟─0520fd1c-f0ba-429e-9ce6-b907bee5ac64
# ╟─76aad264-db25-4d84-bca0-29bd40934bca
# ╟─68ed9469-3059-4027-ba8e-7879b5cab5ff
# ╟─266333df-bd57-4b46-a637-d3d50d62b0d4
# ╟─f3eda30f-f6ee-411b-80ac-4d1c62cb1d0e
# ╠═334de92f-d89b-47e8-aed7-f390fb25adaf
# ╟─578fae6d-1231-4ecf-ab61-37e622b7fafb
# ╟─5752e7ce-6f6a-4f8e-b2db-b997eed15a7b
# ╠═093b57dd-82e8-4308-9a6e-cdc882d546d1
# ╠═0072aa17-ef77-48ec-84cb-356b84dff6b0
# ╟─2096a77b-f6df-4b35-bf80-27951ad525c6
# ╠═738917d2-f2f9-4755-970a-52fdd1e10722
# ╠═57a066a3-c787-493f-afd4-7d16a64fbc81
# ╟─df072a6c-b035-4099-9ace-75d631621598
# ╠═c58f47e8-3471-488b-bc66-e0476dd7964c
# ╠═f2652873-9d4e-4e2d-990f-8ee9f8830dcd
# ╠═144256ba-7bb1-4d0d-8e65-ca161ecd5ae7
# ╟─aa61fd67-2f96-48ea-b2e2-96c80fa9cdad
# ╠═4bd41ff1-58bf-4ae9-b76a-9954c6007fa7
# ╠═a2eafcf8-b4f3-4631-bbb5-d27bea346c8d
# ╠═d38bb742-f4a9-442b-ae06-8ca85e71ef25
# ╠═803146ae-fe59-4f03-a53d-9c93180405e6
# ╠═71756627-d512-4f7f-9794-37dd7d2de3f7
# ╟─6f2ea22d-164d-4059-a575-6f45d24b6dbb
# ╠═5d05a1a7-b352-4a8f-83dd-84a3b41bd129
# ╟─98cf803c-d5fb-448e-b0ef-5998d85dbc3a
# ╠═e9b5ca0d-e954-4e95-b545-7c7dc0223a58
# ╟─6bda136d-e082-4e15-ab68-58e5fb8ca645
# ╠═c10629a3-ed21-42e2-99a2-44a6942bda16
# ╟─1381e1a6-bbca-43de-aa33-65ce363a2272
# ╠═893a1cd5-6fec-4ed5-af44-bf2ecb77a172
# ╠═1b7762fa-112d-487f-a9ed-3c9da9e5b819
# ╠═01ddc548-6ca2-46a7-a450-5c4f2a91b295
# ╟─09cb2e0e-2a12-48f8-b6ba-9db79fce1474
# ╟─8c24afaa-c13a-49f5-9309-d21bc7ff8254
# ╟─4a894509-afa5-4279-8b83-029f6afb122e
# ╠═9e21a206-1389-4abb-83a7-6be01765398e
# ╟─4a2e634a-f9e5-42d6-8c26-5eebbc97d11c
# ╟─aa910e6a-d8a5-431f-8c3b-7395fa3925c9
# ╠═44d4c914-3215-43c1-948a-f6f11cb468f7
# ╠═6c0c0edb-3bc1-4ae0-96ae-791f4ab8f605
# ╟─430c9098-db78-48ca-b76f-a61c7e7b85cb
# ╟─71eff9ab-acab-4ed0-9512-60785a3a37f7
# ╠═46b0a69b-1442-4d90-be85-d79ae0190573
# ╟─28d93b23-0ebe-4102-a562-cc81bdbd5d9a
# ╠═302b6862-a5c6-4d8e-afca-5afcdebb6f23
# ╠═47b35b82-1587-4416-8453-29e2a0f03576
# ╠═54795191-d781-4356-9481-7a0eec463735
# ╟─130dc8ea-cc20-4023-a33a-3e8df3c88009
# ╠═704396e7-6392-49fc-ba42-1d622db000ee
# ╟─0e3c3a9e-fb7b-4deb-b1c9-27c23fdfdafc
# ╠═7aefeaee-0db2-45d6-8f7d-7d1b5627afdc
# ╟─1fec0699-c0c0-468a-871a-6b7a598d6b1c
# ╟─d2cb60f0-98aa-452e-ac55-adf32f4614b1
# ╟─c46bae33-6e12-4df2-83ad-77d73546e4fc
# ╠═ab708373-6257-4d2c-9ac1-bfe7a8557d57
# ╠═11813f6f-6323-4022-ae19-71b3714ee0f8
# ╟─b062c846-a885-4a56-b54f-d72718d47bf3
# ╟─4e85b6e5-78d6-4201-a914-3bedb996acea
# ╠═4e74f82f-7963-4447-a7d8-6654d6a40bed
# ╟─25d5cd62-72a3-443f-95bf-9cda755e9742
# ╠═291f2c97-ebca-4d59-9d4f-a14ae0109df1
# ╠═e63ed07e-364e-4477-9773-6444aae161f5
# ╟─bf4fec26-32c6-457d-a470-8104bb9f5b35
# ╟─77d10527-b376-4672-b623-98d7e8ab2428
