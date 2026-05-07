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
# NASA Altair

This demonstration explores the design space of NASA's Altair small UAV.
"""

# ╔═╡ 44d1c167-fc6c-4124-b1ac-5c643308f203
md"**Define Packages**"

# ╔═╡ 16ee62e4-8741-48de-998c-f344a317ca31
gr(
	size = (900, 700),  # INCREASE THE SIZE FOR THE PLOTS HERE.
	palette = :tab20    # Color scheme for the lines and markers in plots
)

# ╔═╡ be176d8b-e577-4726-be3c-3cf75477f04b
md"""
# Aircraft Definition
The aircraft explored in this demonstration will be **NASA Altair**, modified to use hybrid electric propulsion.

![Three-perspective of NASA Altair](https://www.nasa.gov/wp-content/uploads/2015/03/altair-3-view-10-01.jpg)
"""

# ╔═╡ 60b6bc84-abac-481d-b547-ac1d9c493ee2
@bind batteryselection Select(["PB345V124E-L"])

# ╔═╡ 87f4784b-323f-47f7-843b-ebe2c247230f
batt=battery(batteryselection)

# ╔═╡ 8327cd48-4d5e-4a18-97e0-20b9df6dd058
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

# ╔═╡ 72da1ebb-c5f2-4917-b9e3-86ab0f9a206e
md"""
## Mission Requirements

|Segment       | TAXI | TAKEOFF| CLIMB | CRUISE | DESCENT | LAND |
|--- |---|---| ----- | ------ | ---- |----- | 
|name  | $name1| $name2| $name3| $name4| $name5| $name6|
|Velocity (m/s)| $V1 | $V2 | $V3 | $V4 | $V5 | $V6 | 
|Duration (s)  | $duration1 | $duration2 | $duration3 | $duration4 | $duration5 | $duration6 |
|ROC (m/s)     | $ROC1 | $ROC2 | $ROC3 | $ROC4 | $ROC5 | $ROC6 |
|Load          | $load1 | $load2 | $load3 | $load4 | $load5 |$load6 |
|dV/dt         | $dVdt1 | $dVdt2 | $dVdt3 | $dVdt4 | $dVdt5 | $dVdt6 |
|Density       | $ρ1| $ρ2 | $ρ3 | $ρ4 | $ρ5 | $ρ6 |
Note: In order for the code to work the name of the cruise segment must be Cruise, the name of the climb segment must be Climb, the name of take-off must be Takeoff and the name of taxi must be Taxi. 

Validation/paper comparison
Mission=60 mins, fuel =135.90kg
W0 = 1605.0 kg
We = 1170.1 kg

Long endurance capability
Mission =30 hours, fuel =1410kg
We=1559.0 kg
W0=3268 kg

"""

# ╔═╡ 76cd066f-06f0-456e-bce6-c220d0e8abbf
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

For an initial assumption can assume $S_{wett}/S_{ref}=5$ and assume $K_{LD}=13$. Note: Can compte actual $S_{wett}/S_{ref}$ later.
"""

# ╔═╡ 20012e75-c631-47ea-b021-b0e4a0430ed4
md"""
Additionally, for a propeller driven aircraft, $L/D_{max}$ varies for cruise and loiter. Cruise $L/D_{max}=L/D_{max}$ and Loiter $L/D_{max}=0.866L/D_{max}$

### Specific Fuel Consumption
NASA Altair UAV is equipped with 1 Allied-Signal TPE-331-10T turboprop engine.

For a propeller driven aircraft, SFC is dependent on the flight conditions. SFC can be approximated using the equation $C=C_{bhp}\frac{V}{550 η_p}$. These equations assume V is in ft/s and $C_{bhp}$ is in lb/(hp·hr).

Typical values for $C_{bhp}$ range from 0.5-0.8 at cruise and 0.6-0.8 for loiter.

"""

# ╔═╡ aa2c5d5c-372c-4807-9c88-bbb08eeaad50
begin
	η_p=0.85 #typical value
	C_bhp_cruise=0.5 #given as lb/(hp·hr)
	cp_cruise   = C_bhp_cruise* (0.4536 / (745.7 * 3600))  # kg/(W·s)
	L_D_cruise=LD_max

end;

# ╔═╡ ab965761-df78-41bf-a1e3-26ca5e401956
# ╠═╡ disabled = true
#=╠═╡
md"""
### Fuel Weight Fraction
As fuel is consumed during flight, it's maximum varies with the mission requirements, so these must be defined beforehand. The mission segment weight fractions are given as:
1) Taxi and Takeoff $W_1/W_0=0.97$ (Raymer)
2) Climb $W_i/W_{i-1}=0.985$ (Raymer)
3) Cruise $W_i/W_{i-1} = e^{-\frac{EC}{L/D}}$
4) Descent $W_i/W_{i-1}=0.99$ (Raymer)
5) Landing $W_i/W_{i-1}=0.995$ (Raymer)
The aircraft has 1-2% trapped fuel so $W_f/W_0=1.01(1-W_x/W_0)$
"""
  ╠═╡ =#

# ╔═╡ a835fd52-c061-4364-89d8-ceb3323882a1
# ╠═╡ disabled = true
#=╠═╡
md"""
### $W_0$ Convergence
The convergence of $W_0$ is based on an initial guess and regression data. It combines both equations $W_0 = \frac{W_{crew}+W_{payload}}{1- \left(\frac{W_f}{W_0} \right)- \left(\frac{W_e}{W_0} \right)  }$ and $W_e=AW^C_0$. 

Approximate values of A=2.36 and C=-0.18 were used.
"""
  ╠═╡ =#

# ╔═╡ ec7486e0-fe5c-4d20-ab74-92427aba721a
# ╠═╡ disabled = true
#=╠═╡
begin
	W0_guess = 10000 
	A=2.36               
	C=-0.18
end;
  ╠═╡ =#

# ╔═╡ 4b73459d-6f4a-4778-859d-4ebb7a5ff6a0
md"""
# Battery Sizing Methodology

## Hybridization Ratio
The Hybridization ratio is defined as 

$ϕ=\frac{P_{EM}}{P_{EM}+P_{FB}}$

so when ϕ=1 it is a fully electric aircraft and when ϕ=0 it is a conventional aircraft.

"""

# ╔═╡ fa68ddb1-5299-44cd-a7e1-09a010f7d3be
md"""
## Battery Geometry Constraints

Since we are retrofitting an existing aircraft, the geometry is constrained. Need to define how much space will be available for the battery and how much payload we need to sacrifice.

"""

# ╔═╡ e6299196-d5a2-4a42-a69f-3af4ae688bbb
md"## Battery Sizing"

# ╔═╡ 9404471f-e980-4a23-91a3-e40eccc48d63
md"""

## Payload Range Diagram
The payload range diagram has 4 features/points
1. Maximum payload, zero range
2. Maximum payload, max range
3. Maximum fuel, some payload remaining
4. Zero payload, maximum fuel

"""

# ╔═╡ 409ea466-8f4a-4896-ba9c-047cf52ae96d
md"""
# Aircraft Geometry
"""

# ╔═╡ a6a96afd-f204-4144-8ffd-6948b1f63d6c
begin
	fuselage = HyperEllipseFuselage(
	#known
	radius = 0.56388,          # Radius, m 
	length = 10.9728,        # Length, m 
	x_a    = 0.2707,          # Start of cabin, ratio of length
	x_b    = 0.78,         # End of cabin, ratio of length 
	#estimates
	c_nose = 1.6,           # Curvature of nose 
	c_rear = 1.2,           # Curvature of rear 
	d_nose = -0.4,          # "Droop" or "rise" of nose, m
	d_rear = 0.8,         # "Droop" or "rise" of rear, m 
	position = [0.,0.,0.]   # Set nose at origin, m
	)
	fuselage_end = fuselage.affine.translation + [ fuselage.length, 0., 0. ];
end;

# ╔═╡ 143c04c7-7371-46b0-ab7c-9c56addedda9
md"## Payload"

# ╔═╡ 1afee013-750c-4d50-98e5-05cff6cbf67b
begin #define payload along the body of the fuselage
	x_start = fuselage.length*fuselage.x_a
	x_end   = fuselage.length*fuselage.x_b
	z_start = fuselage.radius- 3/1000   #typical fuselage thickness is about 1.5 to 3mm
	z_end   =-(fuselage.radius- 3/1000 ) #m
	radius  = fuselage.radius
	cyl_edges = plotvolume(x_start, x_end, z_start, z_end; radius=radius, λ=0)
	
	FuselageVolume, New_x_end = payloadvolume(x_start, x_end, z_start, z_end; radius=radius,λ=0) #lambda=0 to signify no payload has been sacrificed this is full volume
	
end

# ╔═╡ 26f74f47-b3e9-4c64-85cb-4c3b873531e4
begin
	AR = 23.5
	Sref=29.23 
end

# ╔═╡ f94d1e79-08c9-4c4b-b69e-d97e78e1a330
begin 
	MTOW             = 3268 #round(W0,digits=2)
	W_payload  		 = 340
	maxfuelweight    = 1410 #kg
	W_empty          = MTOW-W_payload-maxfuelweight
	e                = 0.85
	Cd0              = round(π*AR*e/(2*LD_max)^2, digits=4)
	Altair = Aircraft(MTOW, W_payload, W_empty, Sref, AR, e, Cd0, maxfuelweight)
end

# ╔═╡ 6e781f8c-dee8-4d23-afa0-a79404518abc
md"""
### NASA Altair
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

# ╔═╡ b514367c-3f6c-4602-8898-b6cfd63b4372
W_fuel_max = Altair.maxfuelweight

# ╔═╡ 9b95805c-bd53-43eb-ae37-9ea56257f6fa
md"## Payload"

# ╔═╡ c917a753-3f79-49be-9863-20d491acb6ba
begin
	FuelTankVolumeTotal = maxfuelweight/775 #m^3
end;

# ╔═╡ 05e2e158-ce39-483a-a071-a68ace817d7e
begin 
# this is if we are looking at the long term endurance
	λ=0.5 #fraction of original fuel tank volume allocated to batteries
	maxbatteryvolume = FuelTankVolumeTotal*λ #m^3 replacing fuselage volume
	maxfuelweight2=maxfuelweight*(1-λ)

#Validation case
	#λ =0.3 #fraction of fuselage volume allocated to batteries
	#maxbatteryvolume = FuselageVolume*λ #m^3 #how much of fuselage 
end

# ╔═╡ d919009e-e83e-40fd-8ece-f3bcd606ad1c
begin
	#redefine with less payload. this aircraft, the 
	#payload is the same!
	#maybe we plot fuel instead?
	Altair2 = Aircraft(MTOW, W_payload, W_empty, Sref, AR, e, Cd0, maxfuelweight2)
	#Altair2 = Aircraft(MTOW, W_payload, W_empty, Sref, AR, e, Cd0, maxfuelweight)
end

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

# ╔═╡ f9182ddf-6782-44b5-ad06-276e84b136db
# ╠═╡ disabled = true
#=╠═╡
begin
	W1_W0 = 0.97
	W2_W1 = 0.985

	
#Cruise Definition using endurance
	W3_W2 = exp(-CRUISE.duration*CRUISE.V*cp_cruise*g/(η_p*L_D_cruise))
	W4_W3 = 0.99
	W5_W4 = 0.995

end;
  ╠═╡ =#

# ╔═╡ 097a038b-bf7f-4359-8d76-7de07b7dca08
# ╠═╡ disabled = true
#=╠═╡
begin
	W4_W0=W1_W0*W2_W1*W3_W2*W4_W3*W5_W4
	Wf_W0=1.06*(1-W4_W0) 
end;
  ╠═╡ =#

# ╔═╡ 2fd28068-beda-4363-a9f9-072f75d93453
# ╠═╡ disabled = true
#=╠═╡
W0, weights, iterations=weight_iteration(A, C, W_payload, Wf_W0, W0_guess)
  ╠═╡ =#

# ╔═╡ 7abbc18f-0a0f-4d39-85e0-e7947e3c1e4a
# ╠═╡ disabled = true
#=╠═╡
plot(iterations, weights,
	     xlabel = "Iteration",
	     ylabel = "W₀ (kg)",
	     marker = :circle,
		 title = "W₀ Convergence",
	     legend = false)
  ╠═╡ =#

# ╔═╡ 04f18fb5-268a-4655-81e5-0e2acfdc6776
# ╠═╡ disabled = true
#=╠═╡
W0
  ╠═╡ =#

# ╔═╡ c07187c0-dc94-48e1-8c54-e94680d1650e
# ╠═╡ disabled = true
#=╠═╡
begin
	#empty weight remains fixed
		We_W0=A*(W0 * 2.205)^(C) #lbs
	    We = We_W0 * W0 
end
  ╠═╡ =#

# ╔═╡ 7691036b-39f3-47f9-8a03-2e9fda88f295
# ╠═╡ disabled = true
#=╠═╡
We_W0
  ╠═╡ =#

# ╔═╡ 2b922b69-99bc-4c19-9e3b-20f61c26ddd7
# ╠═╡ disabled = true
#=╠═╡
Wf_W0
  ╠═╡ =#

# ╔═╡ 5f26ad6f-807b-45b5-afce-3511f1862c83
#=╠═╡
begin

	UnModified= PayloadRange(Altair, propulsion, g, L_D_cruise; cp_cruise=cp_cruise)
	
	ModifiedAircraft=Aircraft(2255.7559505882355, W_payload, W_empty, Sref, AR, e, Cd0, maxfuelweight) #phi=0.3 battery weight: 216.0kg, fuel weight: 16.0kg, Total aircraft weight: 2255.7559505882355kg
	Modified= PayloadRange(ModifiedAircraft, propulsion, g, L_D_cruise;W_batt=W_batt, cp_cruise=cp_cruise, W_PGD=W_PGD)

end
  ╠═╡ =#

# ╔═╡ 6e67d675-69f4-4011-b252-320838482004
#=╠═╡
begin
	plot(UnModified.ranges, UnModified.payloads, 
	     xlabel="Range (km)", ylabel="Payload (kg)",
	     title="Payload-Range Diagram (Breguet Range Equation)",
	     marker=:circle, 
		label ="Unmodified NASA Altair UAV")
	plot!(Modified.ranges, Modified.payloads, 
	    marker=:circle, 
	label ="Modified NASA Altair UAV")

end
  ╠═╡ =#

# ╔═╡ 542807ac-edbe-48b8-bd2d-114ef822a440
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

# ╔═╡ 2b6dabde-1843-4bd7-be53-df0848d5a9ee
#=╠═╡
begin
	K_LD   	   = 11 #Raymer high aspect ratio aircraft
	#S_wet = (wetted_area(wing_mesh) + wetted_area(fuselage, 0:0.1:1) + wetted_area(horizontal_tail_mesh) + wetted_area(vertical_tail_mesh))
	Swett_Sref=  6 #S_wet/Sref
	A_wett     = AR/Swett_Sref
	LD_max     = K_LD * sqrt(A_wett)
	g=9.81
	println("L/Dmax: ", round(LD_max, digits=2))
end
  ╠═╡ =#

# ╔═╡ 2dfd5203-a981-4199-95aa-500c0b217885
#=╠═╡
begin
	name1            = "Taxi"
	h1               = 0.0
	V1               = 3
	duration1        = 3*60
	ROC1             = 0.0
	load1            = 1.0
	dVdt1            = 0.0
	sfc1             = 0.365 #kg/(kW·h) guesstimate
	T1, P1, ρ1  = atmosphere(h1)
	ρ1 = round(ρ1, digits=3)
	TAXI      = MissionSegment(name1, h1, V1, duration1, ROC1, ϕ1, load1, dVdt1, ρ1, sfc1)

	name2            = "Takeoff"
	h2               = 457.2
	V2               = 40
	duration2        = 60
	ROC2             = 0.0
	load2            = 1.0
	dVdt2            = (V2-0.0)/duration2
	dVdt2 = round(dVdt2, digits=3)
	T2, P2, ρ2  = atmosphere(h2)
	ρ2 = round(ρ2, digits=3)
	μ = 0.02
	sfc2             = 0.335 #kg/(kW·h) guesstimate
	TAKEOFF   = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ2, load2, dVdt2, ρ2, sfc2)

	name3            = "Climb"
	h3               = 4267.2
	T3, P3, ρ3  = atmosphere(h3)
	ρ3 = round(ρ3, digits=3)
	V3 = 47.5 * sqrt(1.225 / ρ3)
	V3 = round(V3, digits=3)
	duration3        = 8*60
	ROC3             = 10.2 #m/s
	load3            = 1.0
	dVdt3            = (V3-TAKEOFF.V)/duration3
	dVdt3=round(dVdt3, digits=3)
	sfc3             =  0.335 #kg/(kW·h) guesstimate
	CLIMB     = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ3, load3, dVdt3, ρ3, sfc3)
	

	name4            = "Cruise" 
	h4               = 4267.2
	duration4        = 24*60    #CHANGES EVERYTHING
	V4               = 51.44
	ROC4             = 0.0
	load4            = 1.0
	dVdt4            = 0.0
	T4, P4, ρ4  = atmosphere(h4)
	ρ4 = round(ρ4, digits=3)
	sfc4             = 0.304
	CRUISE    = MissionSegment(name4, h4, V4, duration4, ROC4, ϕ4, load4, dVdt4, ρ4, sfc4)

	name5            = "Descent"
	h5               = 457.2
	duration5        = 16*60
	V5               = 37.5
	ROC5             = -3.97 #m/s
	load5            = 1.0
	dVdt5            = 0.0
	T5, P5, ρ5  = atmosphere(h5)
	ρ5 = round(ρ5, digits=3)
	sfc5             = 0.365
	DESCENT    = MissionSegment(name5, h5, V5, duration5, ROC5, ϕ5, load5, dVdt5, ρ5, sfc5)

	
	name6            = "Land"
	h6               = 0
	T6, P6, ρ6  = atmosphere(h6)
	V6 = 32.5 * sqrt(1.225 / ρ6)
	V6 = round(V6, digits=3)
	duration6        = 5*60
	ROC6             = -1.52       #m/s descending
	load6            = 1.0
	dVdt6            = (0.0-V6)/duration6
	dVdt6 = round(dVdt6, digits=3)
	ρ6 = round(ρ6, digits=3)
	sfc6             = 0.365 #kg/(kW·h) guesstimate
	LAND      = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ6, load6, dVdt6, ρ6, sfc6)

end;
  ╠═╡ =#

# ╔═╡ d437db6c-9419-4096-af80-6a7c72efcd68
#=╠═╡
begin
	η_motor                    		= 0.85
	η_controller               		= 0.95
	η_battery                 		= 1
	specificenergy             		= 250 #250 Wh/kg
	SOC_min                    		= 0.2
	power_to_weight_motor      		= 5000 #W/kg
	power_to_weight_controller 		= 2000 #W/kg
	W_engine 				   		= 175 #kg
	P_max_engine 			   		= 700958 #W
	No_Engines                 		= 1
	energy_density_fuel       	    = 11900.0
	η_gas_turbine_efficiency 		= 0.35  
	η_gearbox_efficiency 			= 0.95
	η_electric_generator_efficiency = 0.98
	
	propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_p, η_electric_generator_efficiency)
end
  ╠═╡ =#

# ╔═╡ 72ea507c-cc58-4743-957b-01e79f2123e5
#=╠═╡
begin
	FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, DESCENT, LAND]
	
	η=1
	Max_iterations=10000
		
	W_motor = component_weight(propulsion.P_max_engine * maximum(ϕ), propulsion.power_to_weight_motor)
    W_controller = component_weight(propulsion.P_max_engine * maximum(ϕ) / propulsion.η_motor,propulsion.power_to_weight_controller)
    W_PGD= W_motor + W_controller

	feasible, num_battery_packs, W_f = batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, Altair2, W_PGD, batt, maxbatteryvolume, g, η, μ, LD_max)

	
end;

  ╠═╡ =#

# ╔═╡ 3dc7c369-dc0c-4996-9f80-feb0ec912a35
# ╠═╡ disabled = true
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

# ╔═╡ 3fbc3c10-5de7-4896-92cd-e1214acd0153
#=╠═╡
begin 
	W_batt=batt.weight*num_battery_packs
	println("battery weight: ", W_batt, "kg")
	println("fuel weight: ", W_f, "kg")
	TotalWeight= W_f + Altair.W_empty + Altair2.W_payload + W_PGD + W_batt ;
	println("Total aircraft weight: ", TotalWeight, "kg")
	
	Valid, SOCstate, batterydepleted, leftoverfuel = runmission(FULLMISSION, propulsion, Altair2, W_PGD, batt, num_battery_packs, W_f, g, η, μ, LD_max)
end;
  ╠═╡ =#

# ╔═╡ dc267ffa-2525-48b1-b6ac-9eccb6827918
# ╠═╡ disabled = true
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

# ╔═╡ f656498f-5dd6-45fa-9bf7-0255856c7b34
#=╠═╡
begin
	ϕ = [0.3, 0.3, 0.3, 0.3, 0.3,0.3]
	ϕ1 				= ϕ[1]
	ϕ2 				= ϕ[2]
	ϕ3 				= ϕ[3]
	ϕ4 				= ϕ[4]
	ϕ5 				= ϕ[5]
	ϕ6 				= ϕ[6]
end;
  ╠═╡ =#

# ╔═╡ Cell order:
# ╟─5f1441ea-2158-4b08-98db-7c85b92307d4
# ╟─44d1c167-fc6c-4124-b1ac-5c643308f203
# ╟─4580f93b-25b0-4f41-bdfa-a0cd2f503278
# ╟─16ee62e4-8741-48de-998c-f344a317ca31
# ╟─be176d8b-e577-4726-be3c-3cf75477f04b
# ╟─6e781f8c-dee8-4d23-afa0-a79404518abc
# ╠═f94d1e79-08c9-4c4b-b69e-d97e78e1a330
# ╟─542807ac-edbe-48b8-bd2d-114ef822a440
# ╠═d437db6c-9419-4096-af80-6a7c72efcd68
# ╟─8327cd48-4d5e-4a18-97e0-20b9df6dd058
# ╟─60b6bc84-abac-481d-b547-ac1d9c493ee2
# ╠═87f4784b-323f-47f7-843b-ebe2c247230f
# ╟─72da1ebb-c5f2-4917-b9e3-86ab0f9a206e
# ╟─2dfd5203-a981-4199-95aa-500c0b217885
# ╟─76cd066f-06f0-456e-bce6-c220d0e8abbf
# ╠═2b6dabde-1843-4bd7-be53-df0848d5a9ee
# ╟─20012e75-c631-47ea-b021-b0e4a0430ed4
# ╠═aa2c5d5c-372c-4807-9c88-bbb08eeaad50
# ╠═ab965761-df78-41bf-a1e3-26ca5e401956
# ╠═f9182ddf-6782-44b5-ad06-276e84b136db
# ╠═097a038b-bf7f-4359-8d76-7de07b7dca08
# ╠═a835fd52-c061-4364-89d8-ceb3323882a1
# ╠═ec7486e0-fe5c-4d20-ab74-92427aba721a
# ╠═2fd28068-beda-4363-a9f9-072f75d93453
# ╠═2b922b69-99bc-4c19-9e3b-20f61c26ddd7
# ╠═7abbc18f-0a0f-4d39-85e0-e7947e3c1e4a
# ╠═04f18fb5-268a-4655-81e5-0e2acfdc6776
# ╠═c07187c0-dc94-48e1-8c54-e94680d1650e
# ╠═7691036b-39f3-47f9-8a03-2e9fda88f295
# ╠═b514367c-3f6c-4602-8898-b6cfd63b4372
# ╟─4b73459d-6f4a-4778-859d-4ebb7a5ff6a0
# ╠═f656498f-5dd6-45fa-9bf7-0255856c7b34
# ╟─fa68ddb1-5299-44cd-a7e1-09a010f7d3be
# ╠═05e2e158-ce39-483a-a071-a68ace817d7e
# ╟─e6299196-d5a2-4a42-a69f-3af4ae688bbb
# ╠═d919009e-e83e-40fd-8ece-f3bcd606ad1c
# ╠═72ea507c-cc58-4743-957b-01e79f2123e5
# ╠═3fbc3c10-5de7-4896-92cd-e1214acd0153
# ╟─9404471f-e980-4a23-91a3-e40eccc48d63
# ╠═5f26ad6f-807b-45b5-afce-3511f1862c83
# ╠═6e67d675-69f4-4011-b252-320838482004
# ╟─409ea466-8f4a-4896-ba9c-047cf52ae96d
# ╠═a6a96afd-f204-4144-8ffd-6948b1f63d6c
# ╟─143c04c7-7371-46b0-ab7c-9c56addedda9
# ╠═1afee013-750c-4d50-98e5-05cff6cbf67b
# ╠═26f74f47-b3e9-4c64-85cb-4c3b873531e4
# ╟─9b95805c-bd53-43eb-ae37-9ea56257f6fa
# ╠═c917a753-3f79-49be-9863-20d491acb6ba
# ╟─04f5332d-8555-40ba-9c34-957fddb89034
# ╟─dc267ffa-2525-48b1-b6ac-9eccb6827918
# ╠═3dc7c369-dc0c-4996-9f80-feb0ec912a35
# ╠═734faa23-3471-491b-bf04-b4464e14fab6
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
