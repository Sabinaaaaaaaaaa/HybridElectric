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
md"""
# Aircraft Design Process

This notebook goes through the aicraft design process.

**Define Packages**
"""

# ╔═╡ 22ad3350-9613-44ef-af64-1d97f20dd609
gr(
	size = (900, 700),  
	palette = :tab20   
)

# ╔═╡ f3fad18a-8f4f-4f8b-833a-40b7adec623c
md"""
# Aircraft Definition
The aircraft explored in this demonstration will be **Dornier 328**, modified to use hybrid electric propulsion.

![Three-perspective of Dornier 328](https://www.the-blueprints.com/blueprints-depot-restricted/modernplanes/dornier-modern/dornier_328-73581.jpg)
"""

# ╔═╡ 9fad7afa-24f2-4307-8212-98c366c1461d
begin
	
	η_motor                    		= 1#0.97 #95-97% efficiency   
	η_controller               		=1#0.96
	η_battery                 		=1#0.95
	#specificenergy             		= batt.packspecificenergy
	SOC_min                    		= 0.2
	power_to_weight_motor      		= 16000#5200
	power_to_weight_controller 		= 19000#3702.70
	W_engine 				   		= 411.4*2
	P_max_engine 			   		= 3251252
	No_Engines                 		= 2
	energy_density_fuel       	    = 11900.0
	η_gas_turbine_efficiency 		= 0.35  
	η_gearbox_efficiency 			= 1#0.95
	η_electric_generator_efficiency = 1#0.98
end

# ╔═╡ 1af18536-819d-45a0-b158-2f1de3cfb698
@bind batteryselection Select(["PB345V124E-L"])

# ╔═╡ 76aad264-db25-4d84-bca0-29bd40934bca
begin
	Range_cruise = 1850000#m 6069554 #ft
	
	
    name1            = "Taxi"
    h1               = 0.0
    V1               = 10.0
    duration1        = 180.0
    ROC1             = 0.0
    load1            = 1.0
    dVdt1            = 0.0
	sfc1             = 0.365 #kg/(kW·h) guesstimate
    T1, P1, ρ1  = atmosphere(h1)
    ρ1 = round(ρ1, digits=3)
	

    name2            = "Takeoff"
    h2               = 457.178
    V2               = 70.0
    duration2        = 60
    ROC2             = 0.0
    load2            = 1.0
    dVdt2            = (V2-0.0)/duration2
	dVdt2 = round(dVdt2, digits=3)
    T2, P2, ρ2  = atmosphere(h2)
    ρ2 = round(ρ2, digits=3)
    μ = 0.02
	sfc2             = 0.335 #kg/(kW·h) guesstimate
	

    name3            = "Climb"
    h3               = 0.5*(457.178+9448.34)#9448.339*0.5
	T3, P3, ρ3  = atmosphere(h3)
    ρ3 = round(ρ3, digits=3)
    V3 = 92.6 * sqrt(1.225 / ρ3)
	V3 = round(V3, digits=3)
	ROC3             = 10 #m/s
	duration3 = (9448.34 - 457.178) / ROC3
	duration3 = round(duration3, digits=3)
    
    load3            = 1.0
    dVdt3            = round((V3-V2)/duration3, digits=3)
	sfc3             =  0.335 #kg/(kW·h) guesstimate
	
    
    name4            = "Cruise"
    h4               = 9448.34
	T4, P4, ρ4  = atmosphere(h4)
    ρ4 = round(ρ4, digits=3)
	γ_air = 1.4
	R_air = 287.05



	a4 = sqrt(γ_air * R_air * T4)
	V4 = 0.51 * a4
	V4 = round(V4, digits=3)

	
	#V4               = 174.93#172.22#Range_cruise/duration4
	duration4        = Range_cruise/V4#10741.935
   
	V4 = round(V4, digits=3)
    ROC4             = 0.0
    load4            = 1.0
    dVdt4            = 0.0
	sfc4             = 0.332 
	

    name8            = "Land"
    h8               = 457.178
	T8, P8, ρ8  = atmosphere(h8)
	V8 = 56.667 * sqrt(1.225 / ρ8)
	V8 = round(V8, digits=3)
    duration8        = 180.0
    ROC8             = -5       # 5-7.6m/s  descending
    load8            = 1.0
    dVdt8            = (0.0-V8)/duration8
	dVdt8 = round(dVdt8, digits=3)
    ρ8 = round(ρ8, digits=3)
	sfc8             = 0.365 #kg/(kW·h) guesstimate
	



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
	sfc5             = 0.365 #kg/(kW·h) guesstimate
	

    # --- Diversion (200 km to alternate airport) ---
    name6            = "Cruise"
    h6               = 5486.4#h4     
    V6               = V4      # same cruise speed
	Range_diversion  = 49 * 1852.0  # approx m, close to 100 NM
duration6        = Range_diversion / V6
duration6        = round(duration6, digits=3)
ROC6             = 0.0
load6            = 1.0
dVdt6            = 0.0
T6, P6, ρ6       = atmosphere(h6)
ρ6               = round(ρ6, digits=3)
sfc6             = 0.332
    #duration6        = 200000.0 / V6   # distance/speed = time in seconds
	#duration6 = round(duration6, digits=3)
    #ROC6             = 0.0
    #load6            = 1.0
    #dVdt6            = 0.0
    #T6, P6, ρ6  = atmosphere(h6)
    #ρ6 = round(ρ6, digits=3)
	#sfc6             = 0.332 
	

  #   --- Loiter2 (30 min hold at alternate) ---
    name7            = "Loiter2"
    h7               = 5486.4
    V7               = V8 
    duration7        = 1800.0        # 30 mins in seconds
    ROC7             = 0.0
    load7            = 1.0
    dVdt7            = 0.0
    T7, P7, ρ7  = atmosphere(h7)
    ρ7 = round(ρ7, digits=3)
	sfc7             = 0.365 #kg/(kW·h) guesstimate


	name9="descent"
	h9=0.5*(9448.34+457.178)
	T9, P9, ρ9 = atmosphere(h9)
	ρ9 = round(ρ9, digits=3)
	V_land = 56.667 * sqrt(1.225 / ρ8)
	V_land = round(V_land, digits=3)

	V9 = 0.5 * (V4 + V_land)     # average descent speed
	V9 = round(V9, digits=3)
	ROC9=-7.5
	
	duration9=(9448.34-457.178)/abs(ROC9)
	load9=1
	dVdt9=(V_land-V4)/duration9
		sfc9=0.365

end;

# ╔═╡ 0520fd1c-f0ba-429e-9ce6-b907bee5ac64
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

# ╔═╡ 30ce33ea-3ce7-4902-b4d4-e102a58be64a
begin
	TAXI_0      = MissionSegment(name1, h1, V1, duration1, ROC1, 0, load1, dVdt1, ρ1, sfc1)
	TAKEOFF_0   = MissionSegment(name2, h2, V2, duration2, ROC2, 0, load2, dVdt2, ρ2, sfc2)
	CLIMB_0     = MissionSegment(name3, h3, V3, duration3, ROC3, 0, load3, dVdt3, ρ3, sfc3)
	CRUISE_0    = MissionSegment(name4, h4, V4, duration4, ROC4, 0, load4, dVdt4, ρ4, sfc4)
	LOITER_0    = MissionSegment(name5, h5, V5, duration5, ROC5, 0, load5, dVdt5, ρ5, sfc5)
	DIVERSION_0 = MissionSegment(name6, h6, V6, duration6, ROC6, 0, load6, dVdt6, ρ6, sfc6)
	LOITER2_0   = MissionSegment(name7, h7, V7, duration7, ROC7, 0, load7, dVdt7, ρ7, sfc7)
	LAND_0      = MissionSegment(name8, h8, V8, duration8, ROC8, 0, load8, dVdt8, ρ8, sfc8)
	DESCENT_0    = MissionSegment(name9, h9, V9, duration9, ROC9, 0, load9, dVdt9, ρ9, sfc9)
	FULLMISSION_0=[TAXI_0, TAKEOFF_0, CLIMB_0, CRUISE_0, DESCENT_0 ,LOITER_0, DIVERSION_0, LOITER2_0, LAND_0] #this is just for regular no hybridization
end

# ╔═╡ 266333df-bd57-4b46-a637-d3d50d62b0d4
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

For an initial assumption can assume $S_{wett}/S_{ref}=4$ or $5$ and assume $K_{LD}=11$. Note: Can compte actual $S_{wett}/S_{ref}$ later.
"""

# ╔═╡ 5752e7ce-6f6a-4f8e-b2db-b997eed15a7b
md"""
Additionally, for a propeller driven aircraft, $L/D_{max}$ varies for cruise and loiter. Cruise $L/D_{max}=L/D_{max}$ and Loiter $L/D_{max}=0.866L/D_{max}$

### Specific Fuel Consumption
Dornier 328-100 (Turboprop) is equipped with 2 Pratt & Whitney Canada PW119B/C engines. These are rated with a specific fuel consumption of 0.332 kg/(kW h).

For a propeller driven aircraft, SFC is dependent on the flight conditions. SFC can be approximated using the equation $C=C_{bhp}\frac{V}{550 η_p}$. These equations assume V is in ft/s and $C_{bhp}$ is in lb/(hp·hr).

Typical values for $C_{bhp}$ range from 0.5-0.8 at cruise and 0.6-0.8 for loiter. Using for climb.

"""

# ╔═╡ 093b57dd-82e8-4308-9a6e-cdc882d546d1
SFC=0.332 

# ╔═╡ 0072aa17-ef77-48ec-84cb-356b84dff6b0
begin
	η_p=0.85 #typical value
	C_bhp_cruise=0.5 #given as lb/(hp·hr)
	C_bhp_climb  = 0.55  # lb/(hp·hr)
	C_bhp_loiter=0.6 #given as lb/(hp·hr)
end;

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
	W_payload    =    3671#3540
end;

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

# ╔═╡ 5d05a1a7-b352-4a8f-83dd-84a3b41bd129
begin
	CL_max_clean   =  1.8 #guess 1.2 to 1.8
	CL_max_land    =  3   #guess 1.8-2.8
	CL_max_takeoff = (CL_max_land-CL_max_clean)*0.7 +CL_max_clean

	FieldLength= 1088
end;

# ╔═╡ 893a1cd5-6fec-4ed5-af44-bf2ecb77a172
begin #Landing Field Length: ~2,115 to 3,825 feet (645 to 1,166 meters) at
	Fieldlength_land=1166
	RunwayLength=1500 #
	ActualLandingDistance=Fieldlength_land*0.6
	SL= ActualLandingDistance*3.28  #ft
	Va=(Fieldlength_land*3.28/0.3)^0.5 #kts
	V_sl=Va/(1.3*1.944) #converted to m/s
	W_S_land = 1.225*V_sl^2*CL_max_land*0.5
	#ALD = 800        # only if you intentionally use this as actual landing distance
#Sa = 305          # 3 degree glideslope
#KR = 0.66
#σ_land = 1.0
#	W_S_land = (ALD-Sa)*σ_land*CL_max_land/(0.51*KR)
end;

# ╔═╡ 953be914-ee25-481c-8170-3e8a2be56d8e
ActualLandingDistance

# ╔═╡ 1b7762fa-112d-487f-a9ed-3c9da9e5b819
begin
	WS_stall=(1/0.80645)*1.225*V_sl^2*CL_max_land*0.5;
	
	#V_stall_clean = 60.0 # m/s, 
	#WS_stall = 0.5 * 1.225 * V_stall_clean^2 * CL_max_clean
end;

# ╔═╡ e9b5ca0d-e954-4e95-b545-7c7dc0223a58
W_S = range(0, 8000, length=1000)

# ╔═╡ c10629a3-ed21-42e2-99a2-44a6942bda16
begin #Take-off Field Length: ~3,570 to 4,485 feet (1,088 to 1,367 meters) at MTOW.
	#assume σ=1
	#take off field length =1088
	TODA_min=1088#RunwayLength/1.15
	PW_50ft_takeoff=11.7 .* W_S ./ (TODA_min * CL_max_takeoff);
end;

# ╔═╡ 93220d43-ad79-4fba-830a-77961a20005a
P_W_0BFL=PW_50ft_takeoff*(0.297-0.019*2)/0.144

# ╔═╡ b91cdeab-73cb-40bd-8c05-c7336f5099c7
(V1*duration1*2+V2*duration2+V3*duration3+V4*duration4_new+V6*duration6+V8*duration8+V9*duration9)/1000 #2111 280
	#1017,211

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

# ╔═╡ aa910e6a-d8a5-431f-8c3b-7395fa3925c9
md"""
## Battery Geometry Constraints

Since we are retrofitting an existing aircraft, the geometry is constrained. Need to define how much space will be available for the battery and how much payload we need to sacrifice.

"""

# ╔═╡ 28d93b23-0ebe-4102-a562-cc81bdbd5d9a
md"## Battery Sizing"

# ╔═╡ 803146ae-fe59-4f03-a53d-9c93180405e6
# ╠═╡ disabled = true
#=╠═╡
begin
	plot(UnModified.ranges, UnModified.payloads, 
	     xlabel="Range (km)", ylabel="Payload (kg)",
	     title="Payload-Range Diagram (Breguet Range Equation)",
	     marker=:circle, 
		label ="Unmodified Dornier-328")
	plot!(Modified.ranges, Modified.payloads, 
	    marker=:circle, 
	label ="Modified Dornier-328")

end
  ╠═╡ =#

# ╔═╡ 130dc8ea-cc20-4023-a33a-3e8df3c88009
md"""

## Payload Range Diagram
The payload range diagram has 4 features/points
1. Maximum payload, zero range
2. Maximum payload, max range
3. Maximum fuel, some payload remaining
4. Zero payload, maximum fuel

"""

# ╔═╡ 72ba1f93-a9a5-481a-8f57-b0cac158dbfa
# ╠═╡ disabled = true
#=╠═╡
begin

	#POINT A RANGE =0 
	#POINT A PAYLOAD=2124.0

	#POINT B RANGE = 1853625 
	#increased fuel to 3227.593506519317 (added  993.5935065193171)
	#max fuel is 3427.8
	#POINT B PAYLOAD = 2124.0


	#POINT C- increase fuel by 1193.8000000000002
	#decrease payload by 1193.8000000000002
	#POINT C PAYLOAD = 930.1999999999998
	#POINT C RANGE =1943008


	#POINT D RANGE =2024986
	#POINT D PAYLOAD=0
end
  ╠═╡ =#

# ╔═╡ 12f8b1c4-59d3-486e-9973-1394cd904a77
md"""
## Sensitivity Study 
(Battery Specific Energy vs Fuel Savings)
"""

# ╔═╡ 838ac701-3858-4124-98a2-ac03b545b3a4
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

# ╔═╡ 0e3c3a9e-fb7b-4deb-b1c9-27c23fdfdafc
md"## Adjustment of Payload Weight and Hybridization"

# ╔═╡ 20318bb3-9183-4a84-b390-b9d9d3d2982f
md"## Payload Range Diagrams"

# ╔═╡ c46bae33-6e12-4df2-83ad-77d73546e4fc
md"""
## Range equation
Total input energy=Battery energy storage capacity x number of battery packs /charging efficiency. The charging efficiency is approximately 97%.
"""

# ╔═╡ 9c8da2a2-3ba3-4f4e-9f24-aaf59e29ab11
md"""
# Aircraft Geometry
"""

# ╔═╡ a771ce9c-15c4-4e4c-a3d4-60c5a5986a8e
md" ## Fuselage"

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

# ╔═╡ 3dff90be-9103-4608-a3b0-ddcd67963fa2
md"## Payload"

# ╔═╡ cb4b5100-a9aa-4a9d-86b3-232cd941eee6
begin
	x_start = fuselage.length*fuselage.x_a
	x_end   = fuselage.length*fuselage.x_b
	z_start = fuselage.radius - 3/1000 #typical fuselage thickness is about 1.5 to 3mm
	z_end   = 0.33 #m
	radius  = fuselage.radius
	cyl_edges = plotvolume(x_start, x_end, z_start, z_end; radius=radius, λ=0.5)
	
	PayloadVolume, New_x_end = payloadvolume(x_start, x_end, z_start, z_end; radius=radius, λ=0)
	
end

# ╔═╡ 4512d4e7-199b-4482-80fb-0a032007afec
md"""
## Wing
**Define the airfoil profiles**

For Dornier 328 the wing's root, midspan and tip airfoils are  DO A-5. Note that AeroFuse uses a discretisation method to compute the wing parameters so they vary slightly from the literature. Accuracy is acceptable.
"""

# ╔═╡ afcfb78a-aabe-4d65-a51e-6b5557aefd80
begin
	wingairfoil = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=doa5-il"))
end;

# ╔═╡ 2927e38f-b48f-4f8c-892b-12aac93f2a98
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

# ╔═╡ c438b229-008d-43da-913d-3f39d8ca181d
begin
	AR = round(aspect_ratio(wing),digits=2)
	b_w = span(wing)
	c_w = mean_aerodynamic_chord(wing)	
	Sref = round(projected_area(wing), digits=2)
	mac40_wing = mean_aerodynamic_center(wing, 0.40)
end;

# ╔═╡ 95134a81-b549-4393-b1f6-e6a5254f482b
AR  #check 11

# ╔═╡ 753da66a-b0de-49ea-872d-2d62371576bb
Sref #check 40

# ╔═╡ 51c93fd6-401a-4cb2-8fc6-da9d36e1e9ef
md"""
## Empennage
The values are taken from literature. Where assumptions are made, values from similar/typical aircraft data was used. NACA0012 and NACA0009 are typical empennage airfoil codes. In practice, these values should be altered during the design process, as well as the wing's position to ensure the aircraft meets the stability requirements.
"""

# ╔═╡ 26dff2e7-177b-4e2b-8a0a-061148c2b10c
md"### Vertical Tail"

# ╔═╡ c03bd7db-c9cf-4720-a0b4-0fc437a10e16
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

# ╔═╡ 21d5db3a-2b77-448d-9234-0ec5a6b3a5fd
md"### Horizontal Tail"

# ╔═╡ 65f2a3fc-77d1-4183-88a2-5e6091c74fdc
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

# ╔═╡ 11cc591b-2a65-4b04-b216-427c2753083e
begin
	MTOW             = 13990#round(W0,digits=2)
	W_empty          = 8900#We #
	e                = 0.8
	Cd0              = round(π*AR*e/(2*LD_max)^2, digits=4)
	maxfuelweight    = 3416#3427.80
	Dornier328 = Aircraft(MTOW, W_payload, W_empty, Sref, AR, e, Cd0, maxfuelweight)
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
| S                | $Sref    | m^2   |

$C_{D_0}=\frac{π AR e}{2 \left( L/D\right)^2_{max}}$
"""

# ╔═╡ 4bd41ff1-58bf-4ae9-b76a-9954c6007fa7
W_fuel_max = Dornier328.maxfuelweight

# ╔═╡ bfeedffc-011c-4ce3-9fec-54d4cc3b87c4
# ╠═╡ disabled = true
#=╠═╡
begin
	payload_fraction = [0.9, 0.9,0.8,0.7,0.6,0.5,0.4,0.3,0.2,0.1,0]
	# Dornier max payload
	fuel_constraint = maxfuelweight # kg
	
	unmodified_range = [0, 2866.04, 4136.52, 5253.03]
	unmodified_payload = [1, 1, 0.730791, 0]
	
	unmodified_range_model = [0, 1991, 3008, 3310]
	unmodified_payload_model = [1, 1, 0.73, 0]
	
	Dornier01range= [0, 1688, 1986, 2287, 2590, 2896, 3061, 3105, 3149, 3192, 3235]
	Dornier01packs = [0, 9, 10, 11, 12, 13, 14, 14, 14, 14, 14]
	Dornier01fuel  = [0, 2166, 2446, 2728, 3010, 3294, 3426, 3428, 3426, 3426, 3426]

	Dornier02range = [0,  1314, 1536, 1759, 1994, 2262, 2515, 2744, 2974, 3111, 3155]
	Dornier02packs = [0,  14, 16, 18, 19, 21, 23, 25, 27, 27, 27]
	Dornier02fuel  = [0,  1790, 2000, 2210, 2424, 2676, 2912, 3122, 3332, 3426, 3426]

	Dornier04range = [0,  791, 985, 1150, 1318, 1515, 1673, 1854, 2053, 2204, 2397]
	Dornier04packs = [0,  20, 23, 26, 28, 31, 34, 36, 39, 42, 44]
	Dornier04fuel  = [0,  1260, 1446, 1602, 1754, 1942, 2088, 2250, 2436, 2574, 2746]
	
end
  ╠═╡ =#

# ╔═╡ 738917d2-f2f9-4755-970a-52fdd1e10722
begin
	W1_W0 = 0.97
	W2_W1 = 0.985
	
#Climb 
	# L/D during climb - derived from forces in climbing flight
	# In a climb: L = W·cos(γ), D = W·sin(γ) + T... but simplified:
	#γ_climb = asin(CLIMB.ROC / CLIMB.V)           # climb angle (radians)
	#L_D_climb = cos(γ_climb) / (sin(γ_climb) + 1/LD_max)  # approximation
	#cp_climb = C_bhp_climb * (0.4536 / (745.7 * 3600))  # kg/(W·s)
	#Range_climb = CLIMB.V * CLIMB.duration   # m, along flight path
	#W3_W2 = exp(-Range_climb * cp_climb * g / (η_p * L_D_climb))
	
#Cruise Definition
	V_cruise      = CRUISE_0.V #m/s 663.94357
	cp_cruise   = C_bhp_cruise* (0.4536 / (745.7 * 3600))  # kg/(W·s) 
	L_D_cruise    = LD_max
	W4_W3  = exp(-Range_cruise*cp_cruise*g/(η_p *L_D_cruise))

#Loiter Definition
	Endurance_loiter = 1800 #s 30 mins
	cp_loiter      = C_bhp_loiter* (0.4536 / (745.7 * 3600))  # kg/(W·s)
	L_D_loiter    = LD_max *0.866   
	W5_W4         = exp(-Endurance_loiter*cp_loiter*g/(η_p*L_D_loiter))	
	
#Cruise  Definition diversion 200km to alternate airport
	#Range_diversion = 200000.0  # m
    W6_W5 = exp(-Range_diversion * cp_cruise * g / (η_p * L_D_cruise))

#Loiter Definition
	Endurance_loiter2 = 1800 #s 30 mins
	W7_W6  = exp(-Endurance_loiter2*cp_loiter*g/(η_p*L_D_loiter))	
	W8_W7 = 0.995

end;


# ╔═╡ 57a066a3-c787-493f-afd4-7d16a64fbc81
begin
	W7_W0=W1_W0*W2_W1*W4_W3*W5_W4*W6_W5*W7_W6*W8_W7
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

# ╔═╡ ba19ffa5-392a-4322-99c6-444fc68a080f
W0

# ╔═╡ a2eafcf8-b4f3-4631-bbb5-d27bea346c8d
begin
	#empty weight remains fixed
		We_W0=A*(W0 * 2.205)^(C) #lbs
	    We = We_W0 * W0 
end;

# ╔═╡ f19c85b6-39e4-4e84-be4a-7385039d86bc
We

# ╔═╡ e7e4e892-5100-4ce5-aa96-6944ab976a4c
Wf_W0*W0

# ╔═╡ 01ddc548-6ca2-46a7-a450-5c4f2a91b295
#=╠═╡
begin
	CLIMB2=MissionSegment(name3, h3, V3, duration3, 2.5, 0, load3, dVdt3, ρ3, sfc3)
	α_cruise=W2_W1*W1_W0
	α_climb=W2_W1*W1_W0
	β_cruise=(CRUISE.ρ/1.225)^0.7
	β_climb=(CLIMB.ρ/1.225)^0.7
	PW_cruise=P_W(W_S, α_cruise, β_cruise, CRUISE, propulsion, Dornier328)
	PW_climb=P_W(W_S, α_climb, β_climb, CLIMB2, propulsion, Dornier328)
	PW_ceiling=P_W(W_S, α_cruise, β_cruise, CRUISE, propulsion, Dornier328, constraint="Ceiling", altitude=9492)
end;
  ╠═╡ =#

# ╔═╡ 09cb2e0e-2a12-48f8-b6ba-9db79fce1474
#=╠═╡
begin
	plot(W_S,PW_cruise,
	 ylims=(0,100),
		 xlims=(0,8000),
	xlabel = L"\mathrm{Wing\ loading},\ W_0/S\;[\mathrm{N/m^{2}}]",
	ylabel = L"\mathrm{Power\ loading},\ P_0/W_0\;[\mathrm{W/N}]",
	 label=L"\mathrm{Cruise}"
	)
	plot!(W_S,PW_climb, label=L"\mathrm{Climb}")
	plot!(W_S,P_W_0BFL, label=L"\mathrm{BFL\ constraint}")
	vline!([W_S_land], label=L"\mathrm{Landing\ constraint}")
	hline!([PW_ceiling], label=L"\mathrm{Ceiling}")
	vline!([WS_stall], label=L"\mathrm{Stall\ speed\ constraint}")
	plot!(W_S,PW_50ft_takeoff, label=L"\mathrm{50ft\ obstacle}")

	WS_design = MTOW * g / Sref

P_installed = 2 * 2180 * 745.7 # W, Dornier takeoff power
PW_design = P_installed / (MTOW * g)

vline!([WS_design], linestyle=:dash, label=false)
hline!([PW_design], linestyle=:dash, label=false)
scatter!([WS_design], [PW_design],marker = (:star5, 12), label=L"\mathrm{Dornier\ 328\ design\ point}")
end
  ╠═╡ =#

# ╔═╡ 2e21622b-dec2-439e-bd20-8616ef6c2c03
# ╠═╡ disabled = true
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

# ╔═╡ f540c540-8b37-4080-9198-aa20f14585da
# ╠═╡ disabled = true
#=╠═╡
Valid, SOC, batterydepleted, FUEL =runmission(FULLMISSION, propulsion, Dornier328_2, W_PGD, batt, num_battery_packs,FuelWeight, g, η, μ, LD_max)
  ╠═╡ =#

# ╔═╡ ec1c9497-c632-4c3d-b60f-7cc237d46966
# ╠═╡ disabled = true
#=╠═╡
begin
	plot_Payload_Range
	savefig(plot_Payload_Range, "PayloadRangeDornierA.svg")
end
  ╠═╡ =#

# ╔═╡ a7dcf46d-944b-4c66-91ef-923c0530d27e
# ╠═╡ disabled = true
#=╠═╡
begin

	#POINT A RANGE =0 
	#POINT A PAYLOAD=2124.0

	#POINT B RANGE = 1853625 
	#increased fuel to 3227.593506519317 (added  993.5935065193171)
	#max fuel is 3427.8
	#POINT B PAYLOAD = 2124.0


	#POINT C- increase fuel by 1193.8000000000002
	#decrease payload by 1193.8000000000002
	#POINT C PAYLOAD = 930.1999999999998
	#POINT C RANGE =1943008


	#POINT D RANGE =2024986
	#POINT D PAYLOAD=0

	Ranges1=[0, 1853625/1000, 1943008/1000, 2024986/1000]

	WPloads1=[2124.0, 2124.0, 930.1999999999998, 0]
	
	plot!(plot_Payload_Range, Ranges1, WPloads1,linewidth = 2, marker =:circle, markersize = 4,label = latexstring("\\phi = ", ϕ))
end
  ╠═╡ =#

# ╔═╡ 177584ba-ab35-4720-8080-13fae26519ca
# ╠═╡ disabled = true
#=╠═╡
batt.energystoragecapacity
  ╠═╡ =#

# ╔═╡ ab708373-6257-4d2c-9ac1-bfe7a8557d57
# ╠═╡ disabled = true
#=╠═╡
E_0total =batt.energystoragecapacity*num_battery_packs*3600/0.97 #multiply by 3600 to convert to Joules
  ╠═╡ =#

# ╔═╡ 11813f6f-6323-4022-ae19-71b3714ee0f8
# ╠═╡ disabled = true
#=╠═╡
rangeparallel=Range_parallel(Dornier328_2, propulsion, E_0total, CRUISE.ϕ, LD_max, g)/1000
  ╠═╡ =#

# ╔═╡ 25d5cd62-72a3-443f-95bf-9cda755e9742
md"## Plotting Parameters"

# ╔═╡ e63ed07e-364e-4477-9773-6444aae161f5
begin
	φ_s 			= @bind φ Slider(-180:1e-2:180, default = 45)
	ψ_s 			= @bind ψ Slider(-180:1e-2:180, default = -45)
end;

# ╔═╡ 77d10527-b376-4672-b623-98d7e8ab2428
toggles = md"""
φ: $(φ_s)
ψ: $(ψ_s)
"""

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

# ╔═╡ 206f87e5-6fc4-48d2-898e-5ca3460f9643
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

# ╔═╡ 70db71df-82e7-4872-9de5-db8055dc4a7b
# ╠═╡ disabled = true
#=╠═╡
begin
#    taxi  takeoff  climb  cruise   loiter  diversion  loiter    land
	#ϕ = [0.02,  0.02,    0.02,   0.0,  0.0,    0.0,      0.0,   0.02]	
	ϕ=0.01
	#ϕ = [a, a, a, a, a, a, a, a]
	TAXI      = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ, load1, dVdt1, ρ1, sfc1)
	TAKEOFF   = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ, load2, dVdt2, ρ2, sfc2)
	CLIMB     = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ, load3, dVdt3, ρ3, sfc3)
	CRUISE    = MissionSegment(name4, h4, V4, duration4, ROC4, ϕ, load4, dVdt4, ρ4, sfc4)
	LOITER    = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ, load5, dVdt5, ρ5, sfc5)
	DIVERSION = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ, load6, dVdt6, ρ6, sfc6)
	LOITER2   = MissionSegment(name7, h7, V7, duration7, ROC7, ϕ, load7, dVdt7, ρ7, sfc7)  
	LAND      = MissionSegment(name8, h8, V8, duration8, ROC8, ϕ, load8, dVdt8, ρ8, sfc8)
end
  ╠═╡ =#

# ╔═╡ 6b7d87a6-8708-4ee8-82e1-1a10741d0e2c
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
        FuelWeightResult,
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
end
  ╠═╡ =#

# ╔═╡ 64e3e7dc-d0b3-4c1a-a8ba-4f0af4e850df
# ╠═╡ disabled = true
#=╠═╡
begin
   # Y = FuelSavings[:, 1, :]   # all battery energies, first lambda, all hybridization values
	cols = 2:2:size(FuelSavings, 2)
	#Y = FuelSavings[:, cols]
	#Y = NumberofBatteries[:, cols]
	
    Hybridization_plot = Hybridization[cols]

    labels = reshape([latexstring("\\phi = ", ϕ) for ϕ in Hybridization_plot],1, : )
	xt = BatterySpecificEnergy
    yt = collect(-5:1:5)   # change this range depending on your values

    
xt = collect(200:100:1000)
yt = collect(200:200:2000)   # adjust depending on your fuel savings range


    p = plot(
        BatterySpecificEnergy,
        Y,
        xlabel = L"\mathrm{Battery\ specific\ energy}\;(\mathrm{Wh\,kg^{-1}})",
        ylabel = L"\mathrm{Total\ weight}\; (\mathrm{kg})",
        label = labels,
		xlims=[150,1050],
        marker = :circle,
        markersize = 4,
        linewidth = 2,
        grid = true,
		#legendcolumns=4,
        legend = :topleft,
        tickfontsize = 15,
        guidefontsize = 15,
		xticks = (xt, latexstring.(string.(xt))),
    	yticks = (yt, latexstring.(string.(yt))),
        legendfontsize = 15,

    )

   # hline!(p,[0],linestyle = :dash, linewidth = 2,label = L"\mathrm{Break\ even}")

    p

	#savefig(p, "HybridizationandBatteryTotalWeight.svg")

end
  ╠═╡ =#

# ╔═╡ 6908875d-388b-46f7-8a33-d70c6a493819
# ╠═╡ disabled = true
#=╠═╡
begin
 xt = collect(0.0:0.01:0.05)
    yt = collect(0.0:0.1:1.0)


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
    marker = :circle,
    markersize = 4,
    linewidth = 2,
    label = labels,
    legend = :best,
    tickfontsize = 26,
    guidefontsize = 26,
    legendfontsize = 21,
	xticks = (xt, latexstring.(string.(xt))),
    yticks = (yt, latexstring.(string.(yt)))

)

p
	savefig(p, "Dornier Hybr vs Pay.svg")

	
end

  ╠═╡ =#

# ╔═╡ ff85fae9-5a0f-4107-872a-53943a215dcb
# ╠═╡ disabled = true
#=╠═╡
begin
	BatterySpecificEnergy = [152.78, 300, 500, 700] # Wh/kg
	Hybridization=[0.01,0.02, 0.03, 0.04]
	NumberofBatteries=[
		 9.0   5.0   3.0  2.0
		 18.0  10.0   6.0  4.0
		 27.0  14.0   9.0  6.0
		 36.0  19.0  11.0  8.0
	]

	MaxPayloadFactor =[
		 0.15  0.07  0.03  0.01
		 0.33  0.17  0.09  0.04
		 0.51  0.25  0.14  0.08
		 0.69  0.35  0.18  0.12
	]

	FuelWeightResult=[
		 2316.0  2316.0  2314.0  2314.0
		 2294.0  2292.0  2292.0  2296.0
		 2272.0  2270.0  2274.0  2272.0
		 2250.0  2248.0  2250.0  2250.0
	]
end;
  ╠═╡ =#

# ╔═╡ beb24382-6009-43a8-aaf6-deed9c5a31f1
# ╠═╡ disabled = true
#=╠═╡
begin
	
	#BatterySpecificEnergy=collect(300:50:1000)
	#Lambda=collect(0.0:0.01:0.05)
	Hybridization=[0.06, 0.07, 0.08, 0.09, 0.1]
	BatterySpecificEnergy = [100, 200, 300, 400, 500, 600,700, 800, 900, 1000] # Wh/kg
    Lambda = [0.4 ]#0.5 0.6 ] # 40% payload reduction
	
	nE = length(BatterySpecificEnergy)
    nL = length(Lambda)
	nH = length(Hybridization)
	
	FuelWeightUnModified = fill(NaN, nE, nL, nH)
    FuelWeightModified   = fill(NaN, nE, nL, nH)
	#NumberofBatteries        = fill(NaN, nE, nL, nH)
	#BatteryWeight        = fill(NaN, nE, nL, nH)

    FuelSavings = fill(NaN, nE, nL, nH)

	

    for (i, packspecificenergy) in enumerate(BatterySpecificEnergy)
        for (j, λ) in enumerate(Lambda)
			for (m, ϕ) in enumerate(Hybridization)
			#for a in Hybridization
			#ϕ = [a, a, a, a, a, a, a, a]
			#packspecificenergy = 600
			#λ=1#% decrease in payload! amount allocated for battery!
			TAXI      = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ, load1, dVdt1, ρ1, sfc1)
	TAKEOFF   = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ, load2, dVdt2, ρ2, sfc2)
	CLIMB     = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ, load3, dVdt3, ρ3, sfc3)
	CRUISE    = MissionSegment(name4, h4, V4, duration4, ROC4, ϕ, load4, dVdt4, ρ4, sfc4)
	LOITER    = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ, load5, dVdt5, ρ5, sfc5)
	DIVERSION = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ, load6, dVdt6, ρ6, sfc6)
	LOITER2   = MissionSegment(name7, h7, V7, duration7, ROC7, ϕ, load7, dVdt7, ρ7, sfc7)  
	LAND      = MissionSegment(name8, h8, V8, duration8, ROC8, ϕ, load8, dVdt8, ρ8, sfc8)
		
			
			#redefine Dornier 328 with less payload
			W_payload2=W_payload*(1-λ)
			maxbatteryvolume = PayloadVolume*λ #m^3
			Dornier328_2 = Aircraft(MTOW, W_payload2, W_empty, Sref, AR, e, Cd0, maxfuelweight)
		
		
		
			
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
		
			
			specificenergy             		= batt.packspecificenergy
			propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_p, η_electric_generator_efficiency)
		
		
			FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, LOITER, DIVERSION, LOITER2, LAND]
			
			η=1
			Max_iterations=5000
				
			W_motor = component_weight(propulsion.P_max_engine * maximum(ϕ), propulsion.power_to_weight_motor)
		    W_controller = component_weight(propulsion.P_max_engine * maximum(ϕ) / propulsion.η_motor,propulsion.power_to_weight_controller)
		    W_PGD= W_motor + W_controller
	
		
	#ORIGINAL AIRCRAFT
	_, _, UnModifiedFuel = batteryandfuelsizing(Max_iterations, FULLMISSION_0, propulsion, Dornier328_2, 0, batt, maxbatteryvolume, g, η, μ, LD_max)
	
	
	#EDITED AIRCRAFT
	feasible, num_battery_packs, ModifiedFuel = batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, Dornier328_2, W_PGD, batt, maxbatteryvolume, g, η, μ, LD_max)
			
	if feasible
		FuelWeightUnModified[i,j,m]= UnModifiedFuel
		FuelWeightModified[i,j,m]=ModifiedFuel
		#NumberofBatteries[i,j,m] = num_battery_packs
		#BatteryWeight[i,j,m]= batt.weight*num_battery_packs
		
		FuelSavings[i, j,m] = (UnModifiedFuel - ModifiedFuel) / UnModifiedFuel * 100

	end 
	end 
	end
end
	end

  ╠═╡ =#

# ╔═╡ 4e1f33b7-3ea2-4124-9bb0-fc9f191e40bc
# ╠═╡ disabled = true
#=╠═╡
begin
	Hybridization=[0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.08, 0.09, 0.1]
	BatterySpecificEnergy = [100, 200, 300, 400, 500, 600,700, 800, 900, 1000]
	FuelSavings = [
    -3.0                    NaN                    NaN                    NaN                    NaN                    NaN                    NaN                    NaN                    NaN                    NaN
    -1.0                   -2.0                   -3.090909090909091      NaN                    NaN                    NaN                    NaN                    NaN                    NaN                    NaN
    -0.36363636363636365   -0.5454545454545455    -1.0                   -1.4545454545454546     NaN                    NaN                    NaN                    NaN                    NaN                    NaN
    -0.09090909090909091    0.0                    0.18181818181818182    0.0                    0.18181818181818182    0.0                    NaN                    NaN                    NaN                    NaN
     0.18181818181818182    0.36363636363636365    0.7272727272727273     0.9090909090909091     1.090909090909091      1.1818181818181819     1.3636363636363635     NaN                    NaN                    NaN
     0.18181818181818182    0.6363636363636364     1.0                    1.4545454545454546     1.6363636363636365     2.090909090909091      2.5454545454545454     2.727272727272727      3.1818181818181817     NaN
     0.45454545454545453    0.9090909090909091     1.3636363636363635     1.7272727272727273     2.181818181818182      2.6363636363636362     3.090909090909091      3.5454545454545454     4.0                    4.454545454545455
     0.45454545454545453    0.9090909090909091     1.6363636363636365     2.0                    2.4545454545454546     3.1818181818181817     3.6363636363636362     4.090909090909091      4.545454545454546      5.363636363636363
     0.45454545454545453    1.1818181818181819     1.6363636363636365     2.272727272727273      2.727272727272727      3.4545454545454546     3.909090909090909      4.636363636363637      5.181818181818182      5.909090909090909
     0.45454545454545453    1.1818181818181819     1.9090909090909092     2.272727272727273      3.0                    3.727272727272727      4.181818181818182      4.909090909090909      5.454545454545454      6.181818181818182
]	


NumberofBatteries = [
    14    NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN   NaN
     7     14    21   NaN   NaN   NaN   NaN   NaN   NaN   NaN
     5      9    14    19   NaN   NaN   NaN   NaN   NaN   NaN
     4      7    10    14    17    21   NaN   NaN   NaN   NaN
     3      6     8    11    14    17    20   NaN   NaN   NaN
     3      5     7     9    12    14    16    19    21   NaN
     2      4     6     8    10    12    14    16    18    20
     2      4     5     7     9    10    12    14    16    17
     2      3     5     6     8     9    11    12    14    15
     2      3     4     6     7     8    10    11    13    14
]


	
end;
  ╠═╡ =#

# ╔═╡ ef0c3090-cd79-40c6-884b-5ac17ec49627
# ╠═╡ disabled = true
#=╠═╡
begin

    p = plot(
        xlabel = L"\mathrm{Number\ of\ battery\ packs}",
        ylabel = L"\mathrm{Payload\ factor}\ \lambda",
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
	savefig(p, "Dornier No Batt vs Pay APPENDIX.svg")
end
  ╠═╡ =#

# ╔═╡ 07b2e1c6-4b4a-4125-bfb2-827b50c3205f
# ╠═╡ disabled = true
#=╠═╡
begin



	duration4_new = CruiseRange / V4

	TAXI      = MissionSegment(name1, h1, V1, duration1, ROC1, 0, load1, dVdt1, ρ1, sfc1)
	TAKEOFF   = MissionSegment(name2, h2, V2, duration2, ROC2, 0, load2, dVdt2, ρ2, sfc2)
	CLIMB     = MissionSegment(name3, h3, V3, duration3, ROC3, 0, load3, dVdt3, ρ3, sfc3)
	CRUISE    = MissionSegment(name4, h4, V4, duration4_new, ROC4, ϕ, load4, dVdt4, ρ4, sfc4)
	DESCENT    = MissionSegment(name9, h9, V9, duration9, ROC9, 0, load9, dVdt9, ρ9, sfc9)
	LAND      = MissionSegment(name8, h8, V8, duration8, ROC8, 0, load8, dVdt8, ρ8, sfc8)
	LOITER    = MissionSegment(name5, h5, V5, duration5, ROC5, 0, load5, dVdt5, ρ5, sfc5)
	DIVERSION = MissionSegment("Diversion", h6, V6, duration6, ROC6, 0, load6, dVdt6, ρ6, sfc6)
	#LOITER2   = MissionSegment(name7, h7, V7, duration7, ROC7, 0, load7, dVdt7, ρ7, sfc7)  

			packspecificenergy=600
			weight=1#72
			#batt=battery(batteryselection)
			batt = (
				packspecificenergy = packspecificenergy,  #Wh/kg
				weight = weight,
				energystoragecapacity=weight*packspecificenergy,
			    maxcontinuouspower=Inf,#40000,
				volume = 0.0,#0.05426,
				nominalvoltage = 270#345
			)
		
		
		#redefine Dornier 328 with less payload
		#W_payload2=W_payload*(1-λ)#0#930.1999999999998#W_payload*(1-λ)
		maxbatteryvolume = 10#PayloadVolume*λ #m^3
		Dornier328_2 = Aircraft(MTOW, W_payload2, W_empty, Sref, AR, e, Cd0, maxfuelweight)
	
				
				
		specificenergy = batt.packspecificenergy
		propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, 0, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_p, η_electric_generator_efficiency)
			
	
		FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, DESCENT, LOITER, DIVERSION, LAND, TAXI]
		
		η=1
		Max_iterations=10000
			
		W_motor = component_weight(propulsion.P_max_engine * maximum(ϕ), propulsion.power_to_weight_motor)
		W_controller = component_weight(propulsion.P_max_engine * maximum(ϕ) / propulsion.η_motor,propulsion.power_to_weight_controller)
		W_PGD= W_motor + W_controller
	
		
		feasible, num_battery_packs, FuelWeight = batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, Dornier328_2, W_PGD, batt, maxbatteryvolume, g, η, μ, LD_max)

end
			
  ╠═╡ =#

# ╔═╡ a41cb9c5-7baa-4e96-aa4e-896230e6d60b
# ╠═╡ disabled = true
#=╠═╡
maxbatteryvolume = PayloadVolume*λ #m^3
  ╠═╡ =#

# ╔═╡ cac63f44-b3bb-4787-be82-cbe7fb7f7202
# ╠═╡ disabled = true
#=╠═╡
begin

	xt = collect(0:1000:5000)
    yt = collect(0:10:50)
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

plot!(p,Dornier01range,Dornier01packs,label = L"{\phi = 0.01}",lw=3, marker=:circle)
plot!(p,Dornier02range,Dornier02packs, label = L"{\phi = 0.02}",lw=3, marker=:circle)
plot!(p,Dornier04range,Dornier04packs, label = L"{\phi = 0.04}",lw=3, marker=:circle)

	
savefig(p, "Dornier Payload Range Batteries.svg")
end
  ╠═╡ =#

# ╔═╡ 4d81c3e1-e94f-48f5-9f9f-8afeaa7f74de
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

# ╔═╡ 49cb6cfa-c0e5-40e8-aa3f-d42ca04a89ac
# ╠═╡ disabled = true
#=╠═╡
begin
	CruiseRange=958 * 1852.0#674.72e3#307969.08#1850000#m    #1850 000 
	λ=0.0
	ϕ=0.0
	W_payload2=2790#2500#2716#2790#2761
end
  ╠═╡ =#

# ╔═╡ bb611fc8-6555-4524-8f25-2685e5934864
# ╠═╡ disabled = true
#=╠═╡
begin


	xt = collect(0:1000:5000)
    yt = collect(0:1000:4000)
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

plot!(p,Dornier01range,Dornier01fuel,label = L"{\phi = 0.01}",lw=3, marker=:circle)
plot!(p,Dornier02range,Dornier02fuel, label = L"{\phi = 0.02}",lw=3, marker=:circle)
plot!(p,Dornier04range,Dornier04fuel, label = L"{\phi = 0.04}",lw=3, marker=:circle)


	hline!(p,[fuel_constraint],	label = L"\mathrm{Fuel\ capacity\ limit}",
		linestyle = :dash,
		lw = 2
	)


	savefig(p, "Dornier Payload Range Fuel.svg")
end
  ╠═╡ =#

# ╔═╡ 48bdf374-9b66-454e-ac1e-3972492df869
# ╠═╡ disabled = true
#=╠═╡
begin

	xt = collect(0:1000:5000)
    yt = collect(0.0:0.25:1.0)
	p = plot(
		xlabel = L"\mathrm{Range}\;\mathrm{(km)}",
		ylabel = L"\mathrm{Payload}\;\mathrm{(1-λ)}",
		legend = :outerbottom,
		linewidth = 5,
		xlims = (-50, 3600),
		legendcolumns=4,
		marker = :circle,
		grid = true,
		tickfontsize = 27,
        guidefontsize = 27,
		xticks = (xt, latexstring.(string.(xt))),
    	yticks = (yt, latexstring.(string.(yt))),
        legendfontsize = 20,
	)

plot!(p,unmodified_range_model, unmodified_payload_model, label = L"{\phi = 0.00}",	lw = 3,marker = :diamond, color=:blue)
plot!(p,Dornier01range,payload_fraction,label = L"{\phi = 0.01}",lw=3, marker=:circle, color=:cyan)
plot!(p,Dornier02range,payload_fraction,label = L"{\phi = 0.02}",lw=3, marker=:circle, color=:lime)
plot!(p,Dornier04range,payload_fraction,label = L"{\phi = 0.04}",lw=3, marker=:circle, color=:forest)
	
#plot!(p,unmodified_range, unmodified_payload, label = L"\mathrm{Unmodified\ Dornier\ 328 (Breguet-Range)}",	lw = 3,marker = :diamond, color=:blue)


	p



	#savefig(p, "Dornier Edited Payload Range.svg")
end
  ╠═╡ =#

# ╔═╡ 1f7a5102-d622-424d-a29a-c11b650498f8
# ╠═╡ show_logs = false
# ╠═╡ disabled = true
#=╠═╡
begin
	#BatterySpecificEnergy=collect(300:50:1000)
	#Lambda=collect(0.0:0.01:0.05)
	#Hybridization=collect(0.0:0.00:0.05)
	Hybridization=[0.01,0.02, 0.03, 0.04]
	Hybr=length(Hybridization)
	MaxPayloadFactor = fill(NaN, Hybr)
	BatterySpecificEnergy = [152.78, 300, 500, 700] # Wh/kg

	
	nE = length(BatterySpecificEnergy)
    #nL = length(Lambda)
	
    #BatteryWeight        = fill(NaN, nE, nL)
    #TotalWeightModified   = fill(NaN, nE, nL)#

	MaxPayloadFactor = fill(NaN, Hybr, nE)
	FuelWeightResult = fill(NaN, Hybr, nE)
	NumberofBatteries        = fill(NaN, Hybr, nE)
	
	

     #   for (j, λ) in enumerate(Lambda)
for (i, ϕ) in enumerate(Hybridization)
	for (j, packspecificenergy) in enumerate(BatterySpecificEnergy)
	λ=0.0
	feasible=false
	
	num_battery_packs = 0
	FuelWeight = NaN
	W_PGD = NaN
	BatteryWeight = NaN
	TotalWeight = NaN

	
	
	#ϕ = [a, a, a, a, a, a, a, a]
	TAXI      = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ, load1, dVdt1, ρ1, sfc1)
	TAKEOFF   = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ, load2, dVdt2, ρ2, sfc2)
	CLIMB     = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ, load3, dVdt3, ρ3, sfc3)
	CRUISE    = MissionSegment(name4, h4, V4, duration4, ROC4, ϕ, load4, dVdt4, ρ4, sfc4)
	LAND      = MissionSegment(name8, h8, V8, duration8, ROC8, ϕ, load8, dVdt8, ρ8, sfc8)
	LOITER    = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ, load5, dVdt5, ρ5, sfc5)
	DIVERSION = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ, load6, dVdt6, ρ6, sfc6)
	LOITER2   = MissionSegment(name7, h7, V7, duration7, ROC7, ϕ, load7, dVdt7, ρ7, sfc7)  
	#packspecificenergy = 600
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
	
	while !feasible && λ <= 1.0
			
		#redefine Dornier 328 with less payload
		W_payload2=W_payload*(1-λ)
		maxbatteryvolume = PayloadVolume*λ #m^3
		Dornier328_2 = Aircraft(MTOW, W_payload2, W_empty, Sref, AR, e, Cd0, maxfuelweight)
	
	
		
			
				
		specificenergy = batt.packspecificenergy
		propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_p, η_electric_generator_efficiency)
			
	
		FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, LOITER, DIVERSION, LOITER2, LAND]
		
		η=1
		Max_iterations=3000
			
		W_motor = component_weight(propulsion.P_max_engine * maximum(ϕ), propulsion.power_to_weight_motor)
		W_controller = component_weight(propulsion.P_max_engine * maximum(ϕ) / propulsion.η_motor,propulsion.power_to_weight_controller)
		W_PGD= W_motor + W_controller
		
			
	
		#EDITED AIRCRAFT
		feasible, num_battery_packs, FuelWeight = batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, Dornier328_2, W_PGD, batt, maxbatteryvolume, g, η, μ, LD_max)
				

		if feasible
			MaxPayloadFactor[i,j]=λ
			NumberofBatteries[i,j]=num_battery_packs
			FuelWeightResult[i,j]=FuelWeight
			
		else
			λ+=0.01
		end
	
		
			
	end
		
	


end
end
end

  ╠═╡ =#

# ╔═╡ 66795004-239f-4be5-b13c-04afd867e81e
# ╠═╡ disabled = true
#=╠═╡
begin
	

	# Plot meshes

xt = collect(0:1000:5000)
yt = collect(0:1000:4000)


plot_Payload_Range = plot(
    xlabel = L"\mathrm{Range}\;(\mathrm{km})",
    ylabel = L"\mathrm{Payload\ Weight}\;(\mathrm{kg})",
    grid = true,
	xticks = (xt, latexstring.(string.(xt))),
    yticks = (yt, latexstring.(string.(yt))),
    marker = :circle,
    markersize = 2,
    linewidth = 5,
	size = (1200, 700),
    tickfontsize = 20,
    guidefontsize = 20,
    legendfontsize = 15,
    legend = :bottomleft,
	    bottom_margin = 18 * Plots.PlotMeasures.mm,
    left_margin = 10 * Plots.PlotMeasures.mm

	
)
		



	
	batt=battery(batteryselection)

	propulsion2 = Propulsion(η_motor, η_controller, η_battery, batt.packspecificenergy, SOC_min, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_p, η_electric_generator_efficiency)
	
	UnModifiedRanges, UnModifiedWPloads = PayloadRange(Dornier328, propulsion2, g, L_D_cruise; cp_cruise=cp_cruise)
	plot!(plot_Payload_Range, UnModifiedRanges, UnModifiedWPloads, linewidth=2,
    marker = :circle, markersize = 4, label = L"\mathrm{Unmodified\ Dornier\ 328}"
)

	#    taxi  takeoff  climb  cruise   loiter  diversion  loiter    land
	#ϕ = [0.02,  0.02,    0.02,   0.0,  0.0,    0.0,      0.0,   0.02]	

	#BatterySpecificEnergy=collect(300:50:1000)
	#Lambda=collect(0.0:0.01:0.05)
	Hybridization=[0.01, 0.015, 0.02]#25, 0.05, 0.075, 0.1]
	Hybr=length(Hybridization)
	
	BatterySpecificEnergy = [152.78] # Wh/kg
    Lambda = [0.4]#0.5 0.6 ] # 40% payload reduction
	
	nE = length(BatterySpecificEnergy)
    nL = length(Lambda)
	
    #BatteryWeight        = fill(NaN, nE, nL)
    #TotalWeightModified   = fill(NaN, nE, nL)#


	#BatteryWeight = fill(NaN, Hybr, nL, nE)
	#TotalWeight = fill(NaN, Hybr, nL, nE)
	#FuelWeight =fill(NaN, Hybr, nL, nE)
	
	
	
	    #for (i, packspecificenergy) in enumerate(BatterySpecificEnergy)
	     #   for (j, λ) in enumerate(Lambda)
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
			LAND      = MissionSegment(name8, h8, V8, duration8, ROC8, ϕ, load8, dVdt8, ρ8, sfc8)
			LOITER    = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ, load5, dVdt5, ρ5, sfc5)
			DIVERSION = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ, load6, dVdt6, ρ6, sfc6)
			LOITER2   = MissionSegment(name7, h7, V7, duration7, ROC7, ϕ, load7, dVdt7, ρ7, sfc7)  
			
			#weight=72
			batt=battery(batteryselection)
			#batt = (
			#	packspecificenergy = packspecificenergy,  #Wh/kg
			#	weight = weight,
			#	energystoragecapacity=weight*packspecificenergy,
			#	maxcontinuouspower=40000,
			#	volume = 0.05426,
			#	nominalvoltage = 345
			#)
		
				
			#redefine Dornier 328 with less payload
			W_payload2=W_payload*(1-λ)
			maxbatteryvolume = PayloadVolume*λ #m^3
			Dornier328_2 = Aircraft(MTOW, W_payload2, W_empty, Sref, AR, e, Cd0, maxfuelweight)
		
		
			
				
					
			specificenergy = batt.packspecificenergy
			propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_p, η_electric_generator_efficiency)
				
		
			FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, LOITER, DIVERSION, LOITER2, LAND]
			
			η=1
			Max_iterations=5000
				
			W_motor = component_weight(propulsion.P_max_engine * maximum(ϕ), propulsion.power_to_weight_motor)
			W_controller = component_weight(propulsion.P_max_engine * maximum(ϕ) / propulsion.η_motor,propulsion.power_to_weight_controller)
			W_PGD= W_motor + W_controller
			
				
		
			#EDITED AIRCRAFT
			feasible, num_battery_packs, W_f= batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, Dornier328_2, W_PGD, batt, maxbatteryvolume, g, η, μ, LD_max)
					
			if feasible
				#BatteryWeight[i,j]= batt.weight*num_battery_packs
				#FuelWeight[i,j]=W_f
				
				#TotalWeight[i,j]= W_f + Dornier328.W_empty + Dornier328_2.W_payload + W_PGD + BatteryWeight[i,j]+ FuelWeight[i,j]

				BatteryWeight= batt.weight*num_battery_packs
				FuelWeight=W_f
				
				TotalWeight= W_f + Dornier328.W_empty + Dornier328_2.W_payload + W_PGD + BatteryWeight+ FuelWeight

				
				ModifiedAircraft=Aircraft(MTOW, Dornier328_2.W_payload, W_empty, Sref, AR, e, Cd0, maxfuelweight)
				Ranges, WPloads = PayloadRange(Dornier328_2, propulsion, g, L_D_cruise;W_batt=BatteryWeight, cp_cruise=cp_cruise, W_PGD=W_PGD)
				
				plot!(plot_Payload_Range, Ranges, WPloads,linewidth = 2, marker =:circle, markersize = 4,label = latexstring("\\phi = ", ϕ))
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

# ╔═╡ Cell order:
# ╟─16b90e52-0e5d-11f1-ba99-a3a1d03a74d8
# ╟─5152dc35-4705-485f-80ed-e6d5bd4410b6
# ╟─22ad3350-9613-44ef-af64-1d97f20dd609
# ╟─f3fad18a-8f4f-4f8b-833a-40b7adec623c
# ╟─b4afeffc-df5f-4273-b26a-069895ec2969
# ╟─11cc591b-2a65-4b04-b216-427c2753083e
# ╟─76887937-77d8-493e-8d20-9368018a0da0
# ╟─9fad7afa-24f2-4307-8212-98c366c1461d
# ╠═2e21622b-dec2-439e-bd20-8616ef6c2c03
# ╠═1af18536-819d-45a0-b158-2f1de3cfb698
# ╟─0520fd1c-f0ba-429e-9ce6-b907bee5ac64
# ╟─76aad264-db25-4d84-bca0-29bd40934bca
# ╟─30ce33ea-3ce7-4902-b4d4-e102a58be64a
# ╟─266333df-bd57-4b46-a637-d3d50d62b0d4
# ╠═334de92f-d89b-47e8-aed7-f390fb25adaf
# ╟─5752e7ce-6f6a-4f8e-b2db-b997eed15a7b
# ╠═093b57dd-82e8-4308-9a6e-cdc882d546d1
# ╠═0072aa17-ef77-48ec-84cb-356b84dff6b0
# ╟─2096a77b-f6df-4b35-bf80-27951ad525c6
# ╠═738917d2-f2f9-4755-970a-52fdd1e10722
# ╠═57a066a3-c787-493f-afd4-7d16a64fbc81
# ╟─df072a6c-b035-4099-9ace-75d631621598
# ╠═c58f47e8-3471-488b-bc66-e0476dd7964c
# ╠═f2652873-9d4e-4e2d-990f-8ee9f8830dcd
# ╠═e7e4e892-5100-4ce5-aa96-6944ab976a4c
# ╠═144256ba-7bb1-4d0d-8e65-ca161ecd5ae7
# ╠═ba19ffa5-392a-4322-99c6-444fc68a080f
# ╠═4bd41ff1-58bf-4ae9-b76a-9954c6007fa7
# ╠═a2eafcf8-b4f3-4631-bbb5-d27bea346c8d
# ╠═f19c85b6-39e4-4e84-be4a-7385039d86bc
# ╟─6f2ea22d-164d-4059-a575-6f45d24b6dbb
# ╟─98cf803c-d5fb-448e-b0ef-5998d85dbc3a
# ╟─6bda136d-e082-4e15-ab68-58e5fb8ca645
# ╟─1381e1a6-bbca-43de-aa33-65ce363a2272
# ╠═5d05a1a7-b352-4a8f-83dd-84a3b41bd129
# ╠═c10629a3-ed21-42e2-99a2-44a6942bda16
# ╠═93220d43-ad79-4fba-830a-77961a20005a
# ╠═893a1cd5-6fec-4ed5-af44-bf2ecb77a172
# ╠═953be914-ee25-481c-8170-3e8a2be56d8e
# ╠═1b7762fa-112d-487f-a9ed-3c9da9e5b819
# ╠═01ddc548-6ca2-46a7-a450-5c4f2a91b295
# ╠═e9b5ca0d-e954-4e95-b545-7c7dc0223a58
# ╠═09cb2e0e-2a12-48f8-b6ba-9db79fce1474
# ╠═b91cdeab-73cb-40bd-8c05-c7336f5099c7
# ╟─8c24afaa-c13a-49f5-9309-d21bc7ff8254
# ╟─4a894509-afa5-4279-8b83-029f6afb122e
# ╠═838ac701-3858-4124-98a2-ac03b545b3a4
# ╟─aa910e6a-d8a5-431f-8c3b-7395fa3925c9
# ╠═a41cb9c5-7baa-4e96-aa4e-896230e6d60b
# ╟─28d93b23-0ebe-4102-a562-cc81bdbd5d9a
# ╠═803146ae-fe59-4f03-a53d-9c93180405e6
# ╟─130dc8ea-cc20-4023-a33a-3e8df3c88009
# ╠═07b2e1c6-4b4a-4125-bfb2-827b50c3205f
# ╠═f540c540-8b37-4080-9198-aa20f14585da
# ╠═49cb6cfa-c0e5-40e8-aa3f-d42ca04a89ac
# ╠═72ba1f93-a9a5-481a-8f57-b0cac158dbfa
# ╠═bfeedffc-011c-4ce3-9fec-54d4cc3b87c4
# ╠═48bdf374-9b66-454e-ac1e-3972492df869
# ╠═bb611fc8-6555-4524-8f25-2685e5934864
# ╠═cac63f44-b3bb-4787-be82-cbe7fb7f7202
# ╟─12f8b1c4-59d3-486e-9973-1394cd904a77
# ╠═70db71df-82e7-4872-9de5-db8055dc4a7b
# ╠═beb24382-6009-43a8-aaf6-deed9c5a31f1
# ╠═4e1f33b7-3ea2-4124-9bb0-fc9f191e40bc
# ╠═64e3e7dc-d0b3-4c1a-a8ba-4f0af4e850df
# ╟─0e3c3a9e-fb7b-4deb-b1c9-27c23fdfdafc
# ╠═1f7a5102-d622-424d-a29a-c11b650498f8
# ╠═ff85fae9-5a0f-4107-872a-53943a215dcb
# ╠═6908875d-388b-46f7-8a33-d70c6a493819
# ╠═ef0c3090-cd79-40c6-884b-5ac17ec49627
# ╠═4d81c3e1-e94f-48f5-9f9f-8afeaa7f74de
# ╠═6b7d87a6-8708-4ee8-82e1-1a10741d0e2c
# ╟─20318bb3-9183-4a84-b390-b9d9d3d2982f
# ╠═ec1c9497-c632-4c3d-b60f-7cc237d46966
# ╠═66795004-239f-4be5-b13c-04afd867e81e
# ╠═a7dcf46d-944b-4c66-91ef-923c0530d27e
# ╟─c46bae33-6e12-4df2-83ad-77d73546e4fc
# ╠═177584ba-ab35-4720-8080-13fae26519ca
# ╠═ab708373-6257-4d2c-9ac1-bfe7a8557d57
# ╠═11813f6f-6323-4022-ae19-71b3714ee0f8
# ╟─9c8da2a2-3ba3-4f4e-9f24-aaf59e29ab11
# ╟─206f87e5-6fc4-48d2-898e-5ca3460f9643
# ╟─77d10527-b376-4672-b623-98d7e8ab2428
# ╟─a771ce9c-15c4-4e4c-a3d4-60c5a5986a8e
# ╠═9b97c743-9bfe-4fb0-bf6a-01d64b88b217
# ╟─3dff90be-9103-4608-a3b0-ddcd67963fa2
# ╠═cb4b5100-a9aa-4a9d-86b3-232cd941eee6
# ╟─4512d4e7-199b-4482-80fb-0a032007afec
# ╠═afcfb78a-aabe-4d65-a51e-6b5557aefd80
# ╠═2927e38f-b48f-4f8c-892b-12aac93f2a98
# ╠═c438b229-008d-43da-913d-3f39d8ca181d
# ╠═95134a81-b549-4393-b1f6-e6a5254f482b
# ╠═753da66a-b0de-49ea-872d-2d62371576bb
# ╟─51c93fd6-401a-4cb2-8fc6-da9d36e1e9ef
# ╟─26dff2e7-177b-4e2b-8a0a-061148c2b10c
# ╠═c03bd7db-c9cf-4720-a0b4-0fc437a10e16
# ╟─21d5db3a-2b77-448d-9234-0ec5a6b3a5fd
# ╠═65f2a3fc-77d1-4183-88a2-5e6091c74fdc
# ╟─4e85b6e5-78d6-4201-a914-3bedb996acea
# ╠═4e74f82f-7963-4447-a7d8-6654d6a40bed
# ╟─25d5cd62-72a3-443f-95bf-9cda755e9742
# ╠═291f2c97-ebca-4d59-9d4f-a14ae0109df1
# ╠═e63ed07e-364e-4477-9773-6444aae161f5
