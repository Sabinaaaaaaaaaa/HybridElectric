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
# ╠═╡ disabled = true
#=╠═╡
batt=battery(batteryselection)
  ╠═╡ =#

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

For an initial assumption can assume $K_{LD}=12$. 
"""

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

# ╔═╡ cf58a1b4-3af3-42ca-91f4-7c29bc5fe6c9
duration4        = 6.4547*60*60#6.4547*60*60 #26.4*60*60

# ╔═╡ 12fcbaf3-2cb6-42a2-b4d4-e96a33501b02
begin 
	ϕ = [0.0, 0.0, 0.2, 0.0, 0.0,0.0, 0.0]

end;

# ╔═╡ f656498f-5dd6-45fa-9bf7-0255856c7b34
begin
	ϕ1 				= ϕ[1]
	ϕ2 				= ϕ[2]
	ϕ3 				= ϕ[3]
	ϕ4 				= ϕ[4]
	ϕ5 				= ϕ[5]
	ϕ6 				= ϕ[6]
	ϕ7 				= ϕ[7]
end;

# ╔═╡ 2dfd5203-a981-4199-95aa-500c0b217885
begin
	
	name1            = "Taxi"
	h1               = 0.0
	V1               = 3
	duration1        = 3*60
	ROC1             = 0.0
	load1            = 1.0
	dVdt1            = 0.0
	sfc1             = 0.35 #kg/(kW·h) guesstimate
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
	sfc2             = 0.35 #kg/(kW·h) guesstimate
	TAKEOFF   = MissionSegment(name2, h2, V2, duration2, ROC2, ϕ2, load2, dVdt2, ρ2, sfc2)

	name3            = "Climb"
	h3               = 15850
	T3, P3, ρ3  = atmosphere(h3)
	ρ3 = round(ρ3, digits=3)
	V3 = 55 * sqrt(1.225 / ρ3)
	V3 = round(V3, digits=3)
	ROC3             = 1.43 #m/s
	duration3        = h3/ROC3 	
	load3            = 1.0
	dVdt3            = (V3-TAKEOFF.V)/duration3
	dVdt3=round(dVdt3, digits=3)
	sfc3             =  0.34 #kg/(kW·h) guesstimate
	CLIMB     = MissionSegment(name3, h3, V3, duration3, ROC3, ϕ3, load3, dVdt3, ρ3, sfc3)
	

	name4            = "Cruise" 
	h4               = 15850#4267.2
	#duration4        = 26.4*60*60    #CHANGES EVERYTHING 
	T4, P4, ρ4  = atmosphere(h4)
	ρ4 = round(ρ4, digits=3)
	V4               = 40 * sqrt(1.225 / ρ4)
	ROC4             = 0.0
	load4            = 1.0
	dVdt4            = 0.0
	
	sfc4             = 0.33
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
	sfc5             = 0.34
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
	sfc6             = 0.35 #kg/(kW·h) guesstimate
	LAND      = MissionSegment(name6, h6, V6, duration6, ROC6, ϕ6, load6, dVdt6, ρ6, sfc6)

	name7           = "Taxi"
	h7               = 0.0
	V7               = 3
	duration7        = 3*60
	ROC7             = 0.0
	load7            = 1.0
	dVdt7            = 0.0
	sfc7             = 0.35 #kg/(kW·h) guesstimate
	T7, P7, ρ7  = atmosphere(h7)
	ρ7 = round(ρ1, digits=3)
	TAXI2      = MissionSegment(name7, h7, V7, duration7, ROC7, ϕ7, load7, dVdt7, ρ7, sfc7)

	
end;

# ╔═╡ 72da1ebb-c5f2-4917-b9e3-86ab0f9a206e
md"""
## Mission Requirements

|Segment       | TAXI | TAKEOFF| CLIMB | CRUISE | DESCENT | LAND | TAXI|
|--- |---|---| ----- | ------ | ---- |----- | ---|
|name  | $name1| $name2| $name3| $name4| $name5| $name6| $name7 |
|Velocity (m/s)| $V1 | $V2 | $V3 | $V4 | $V5 | $V6 | $V7 |
|Duration (s)  | $duration1 | $duration2 | $duration3 | $duration4 | $duration5 | $duration6 | $duration7 |
|ROC (m/s)     | $ROC1 | $ROC2 | $ROC3 | $ROC4 | $ROC5 | $ROC6 | $ROC7|
|Load          | $load1 | $load2 | $load3 | $load4 | $load5 |$load6 | $load7 |
|dV/dt         | $dVdt1 | $dVdt2 | $dVdt3 | $dVdt4 | $dVdt5 | $dVdt6 | $dVdt7 |
|Density       | $ρ1| $ρ2 | $ρ3 | $ρ4 | $ρ5 | $ρ6 | $ρ7 |
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

# ╔═╡ dd1654ff-c375-4fe2-b375-19f96d7065ca
packspecificenergy = 800

# ╔═╡ 1275831a-47b1-4cf5-b6ae-5ebce365e44e
begin
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

end

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

# ╔═╡ 6e67d675-69f4-4011-b252-320838482004
# ╠═╡ disabled = true
#=╠═╡
begin
	#plot(UnModified.ranges, UnModified.payloads, 
	 #    xlabel="Range (km)", ylabel="Payload (kg)",
	  #   title="Payload-Range Diagram (Breguet Range Equation)",
	   #  marker=:circle, 
		#label ="Unmodified NASA Altair UAV")
	plot(Modified.ranges, Modified.payloads, 
	    marker=:circle, 
	label ="Modified NASA Altair UAV")

end
  ╠═╡ =#

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

# ╔═╡ 744f666b-2ec0-4592-844e-103dbff9b5fd
md"## Fuselage"

# ╔═╡ a6a96afd-f204-4144-8ffd-6948b1f63d6c
begin #if u want try a different method
	fuselage = HyperEllipseFuselage(
	
	radius = 1.1277/2,      # Radius, m 
	length = 11.03322158,   # Length, m 
	x_a    = 0.18,          #where nose ends
	x_b    = 0.78,   	    #where rear taper starts          
	#estimates
	c_nose = 2,           # Curvature of nose 
	c_rear = 1.5,           # Curvature of rear 
	d_nose = 0.0,          # "Droop" or "rise" of nose, m
	d_rear = 0.2,           # "Droop" or "rise" of rear, m 
	position = [0.,0.,0.]   # Set nose at origin, m
)
	fuselage_end = fuselage.affine.translation + [ fuselage.length, 0., 0. ];
end;

# ╔═╡ 9b95805c-bd53-43eb-ae37-9ea56257f6fa
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

	PayloadVolume, New_x_end = payloadvolume(0, z_start, z_start, z_end; radius=radius,λ=0)
	
end

# ╔═╡ f391e83a-4420-4e21-aaf1-67fb9afff913
FuselageVolume

# ╔═╡ 6365c847-6075-457d-8c6c-33600672caa7
md""" 
## Wing
**Define the airfoil profiles**

For NASA Altair UAV the wing's root, midspan and tip airfoils are substituted with similar airfoils. Note that AeroFuse uses a discretisation method to compute the wing parameters so they vary slightly from the literature. Accuracy is acceptable.
"""

# ╔═╡ 725e7bc4-275e-4565-a0e7-b17ed80a2200
begin 
    # Cambered UAV-style airfoils from AirfoilTools

    rootairfoil = read_foil(download("https://m-selig.ae.illinois.edu/ads/coord/naca4415.dat"))
    meanairfoil = read_foil(download("https://m-selig.ae.illinois.edu/ads/coord/naca4412.dat"))
    tipairfoil  = read_foil(download("https://m-selig.ae.illinois.edu/ads/coord/naca4412.dat"))

end;

# ╔═╡ a36b68a3-2bc7-44ae-86b6-41d90c514c74
begin
	wing = Wing(; 
	chords    = [1.645839683, 0.804, 0.731484304], 
	foils     = [rootairfoil, meanairfoil, tipairfoil],
	twists 	  = [1, 0.5, -1.5],
	spans     = [9.966, 3.137],  #13.1058 is the semi span

	sweeps    = [2, 2], 
	w_sweep   = 0.0, 
	dihedrals = [0.0, 0.0],#fill(2.5, 2),
	symmetry  = true,
	angle       = 0,            #Incidence angle (deg)
	axis = [0, 1, 0],
	position    = [4.8, 0., -0.2]  #approximated last no.
); 
end;

# ╔═╡ 5f83ed9d-eecf-4c82-b1e6-d633260eca0a
begin 
	AR = round(aspect_ratio(wing),digits=2)
	b_w = span(wing)  
	c_w = mean_aerodynamic_chord(wing)	
	Sref = round(projected_area(wing), digits=2)
	mac40_wing = mean_aerodynamic_center(wing, 0.40)
end;

# ╔═╡ 6e5909de-3846-4e17-932e-28fb80eda5be
md""" 
## Empennage
The values are taken from literature. Where assumptions are made, values from similar/typical aircraft data was used. NACA0012 and NACA0009 are typical empennage airfoil codes. 
"""

# ╔═╡ 1a95262a-bfec-4f92-82bc-7226f908e632
md"### Horizontal Tail"

# ╔═╡ edb76e31-e4df-48e0-835c-e33c1e59c865
horizontal_tail = WingSection( 
area        = 6.75,  		    # Area (m²). 
aspect      = 6.91,  		    # Aspect ratio
taper       = 0.5,  		    # Taper ratio  				GUESS
	dihedral    = 9.2,   		    	# Dihedral angle (deg)      
	sweep       = 15,  		    	# Sweep angle (deg)         GUESS
	w_sweep     =0.0,   		        # Leading-edge sweep        GUESS
	root_foil   = naca4(0,0,1,2), 	# Root airfoil              GUESS
	tip_foil    = naca4(0,0,1,2), 	# Tip airfoil               GUESS
	symmetry    = true,
	angle       = 0, 
	position    =  [8, 0.,0],
); #GUESS

# ╔═╡ eac09430-a759-4681-b253-fa18b73239ef
md"### Vertical Tail"

# ╔═╡ c080d78c-182b-470d-911b-f640ba443ba1
vertical_tail = WingSection(
	area        = 1.06, 	    #Area + dorsal fin (m²). 
	aspect      = 1.08,  			
	taper       = 0.3,  			#					GUESS
	dihedral    = 0.0,
	sweep       = 34, 			    #   				GUESS
	w_sweep     = 0.,   			#Leading-edge sweep GUESS
	root_foil   = naca4(0,0,1,2), 	#   				GUESS	
	tip_foil    = naca4(0,0,1,2), 	#   				GUESS	
	symmetry    = false,
	angle       = 90.,       		#To make it vertical
	axis        = [-1, 0, 0], 
	position    = [7.5, 0., 0.05]
);

# ╔═╡ 6e32660f-cda0-433d-a78f-0e68730490df
md" ## Meshing"

# ╔═╡ e870f93b-5b9e-4364-88d6-1e5d405e131a
begin
	wing_mesh = WingMesh(wing, [8,16], 10, span_spacing = Uniform());
	vertical_tail_mesh = WingMesh(vertical_tail, [8], 6);
	horizontal_tail_mesh = WingMesh(horizontal_tail, [10], 8);
end;
# Spacing: Uniform() or Cosine()


# ╔═╡ 2b6dabde-1843-4bd7-be53-df0848d5a9ee
begin
	K_LD   	   = 10 #Raymer high aspect ratio aircraft
	S_wet = (wetted_area(wing_mesh) + wetted_area(fuselage, 0:0.1:1) + wetted_area(horizontal_tail_mesh) + wetted_area(vertical_tail_mesh))
	Swett_Sref=  S_wet/Sref
	A_wett     = AR/Swett_Sref
	LD_max     = K_LD * sqrt(A_wett)
	g=9.81
	println("L/Dmax: ", round(LD_max, digits=2))
end

# ╔═╡ f94d1e79-08c9-4c4b-b69e-d97e78e1a330
begin 
	MTOW             = 3175 
	W_payload  		 = 340
	maxfuelweight    = 1361
	W_empty          = 1474
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

# ╔═╡ c917a753-3f79-49be-9863-20d491acb6ba
begin
	FuelTankVolumeTotal = maxfuelweight/775 #m^3
end;

# ╔═╡ 05e2e158-ce39-483a-a071-a68ace817d7e
begin 
# this is if we are looking at the long term endurance
	λ=0.5 #fraction of original fuel tank volume allocated to batteries
	λ2=0 #fraction of payload volume allocated to batteries
	maxbatteryvolume = FuelTankVolumeTotal*λ+PayloadVolume*λ2 #m^3 replacing fuselage volume
	W_payload2=W_payload*(1-λ2)
	maxfuelweight2=maxfuelweight*(1-λ)

end

# ╔═╡ d919009e-e83e-40fd-8ece-f3bcd606ad1c
begin
	#redefine with less payload. this aircraft, the 
	#payload is the same!
	#maybe we plot fuel instead?
	Altair2 = Aircraft(MTOW, W_payload2, W_empty, Sref, AR, e, Cd0, maxfuelweight2)
end

# ╔═╡ 1f46b0b2-ac0c-48f6-a113-79d6200a6b63
FuelTankVolumeTotal

# ╔═╡ eb75c58a-3c75-409a-9d0b-0fcb17108447
NewFuelVolume=FuelTankVolumeTotal*(1-λ)

# ╔═╡ f2a86f63-314b-4214-8011-54d39c14a840
BatteryVolumeAvailable=FuelTankVolumeTotal*(λ)

# ╔═╡ aa2c5d5c-372c-4807-9c88-bbb08eeaad50
begin
	η_p=0.85 #typical value
	C_bhp_cruise=0.5 #given as lb/(hp·hr)
	cp_cruise   =CRUISE.SFC/3.6e6#C_bhp_cruise* (0.4536 / (745.7 * 3600))  # kg/(W·s)
	L_D_cruise=LD_max

end;

# ╔═╡ d437db6c-9419-4096-af80-6a7c72efcd68
begin
	η_motor                    		= 0.85
	η_controller               		= 0.95
	η_battery                 		= 1
	specificenergy             		= batt.packspecificenergy #250 Wh/kg
	SOC_min                    		= 0.2
	power_to_weight_motor      		= 5000 #W/kg
	power_to_weight_controller 		= 2000 #W/kg
	W_engine 				   		= 95.95 #kg
	P_max_engine 			   		= 522000 #W
	No_Engines                 		= 1
	energy_density_fuel       	    = 11900.0
	η_gas_turbine_efficiency 		= 0.35  
	η_gearbox_efficiency 			= 0.95
	η_electric_generator_efficiency = 0.98
	
	propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines, energy_density_fuel, η_gas_turbine_efficiency, η_gearbox_efficiency, η_p, η_electric_generator_efficiency)
end

# ╔═╡ 542807ac-edbe-48b8-bd2d-114ef822a440
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

# ╔═╡ 72ea507c-cc58-4743-957b-01e79f2123e5
# ╠═╡ show_logs = false
begin
	FULLMISSION=[TAXI, TAKEOFF, CLIMB, CRUISE, DESCENT, LAND, TAXI2]
	
	η=1
	Max_iterations=2000
		
	W_motor = component_weight(propulsion.P_max_engine * maximum(ϕ), propulsion.power_to_weight_motor)
    W_controller = component_weight(propulsion.P_max_engine * maximum(ϕ) / propulsion.η_motor,propulsion.power_to_weight_controller)
    W_PGD= W_motor + W_controller

	feasible, num_battery_packs, W_f = batteryandfuelsizing(Max_iterations, FULLMISSION, propulsion, Altair2, W_PGD, batt, maxbatteryvolume, g, η, μ, LD_max)

	
end;


# ╔═╡ 3e08973f-b80e-41b3-b97c-3350a8e35dae
FuelVolumeRequired=W_f/775

# ╔═╡ b51f4a31-11ff-4c19-a2d9-32cc01167b32
BatteryVolumeRequired=num_battery_packs*batt.volume

# ╔═╡ 3fbc3c10-5de7-4896-92cd-e1214acd0153
begin 
	W_batt=batt.weight*num_battery_packs
	println("battery weight: ", W_batt, "kg")
	println("fuel weight: ", W_f, "kg")
	TotalWeight= W_f + Altair.W_empty + Altair2.W_payload + W_PGD + W_batt ;
	println("Total aircraft weight: ", TotalWeight, "kg")
	
	Valid, SOCstate, batterydepleted, leftoverfuel = runmission(FULLMISSION, propulsion, Altair2, W_PGD, batt, num_battery_packs, W_f, g, η, μ, LD_max)
end;

# ╔═╡ 5f26ad6f-807b-45b5-afce-3511f1862c83
begin

	UnModified= PayloadRange(Altair, propulsion, g, L_D_cruise; cp_cruise=cp_cruise)
	NewAircraft=Aircraft(TotalWeight, Altair2.W_payload, W_empty, Sref, AR, e, Cd0, Altair2.maxfuelweight)
	Modified= PayloadRange(NewAircraft, propulsion, g, L_D_cruise;W_batt=W_batt, cp_cruise=cp_cruise, W_PGD=W_PGD)

end

# ╔═╡ 55549957-9eff-4af6-bf88-2ec23bdf9164
md"## Plotting Parameters"

# ╔═╡ 8c3bb6c6-1c91-49f2-86d2-b6e81043b1a5
begin
	edgesBattery = Vector{Any}(undef, 4)
	startx=x_start+1
	startz=z_end+0.15
	lengthx=0.62
	lengthz=0.25
	lengthy=0.35

	edgesBattery[1] = plotvolume(startx, startx+lengthx, startz, startz+lengthz; width=lengthy*2, λ=0)
	edgesBattery[2] = plotvolume(startx+1, startx+lengthx+1, startz, startz+lengthz; width=lengthy*2, λ=0)
	edgesBattery[3] = plotvolume(startx+2, startx+lengthx+2, startz, startz+lengthz; width=lengthy*2, λ=0)
	edgesBattery[4] = plotvolume(startx+3, startx+lengthx+3, startz, startz+lengthz; width=lengthy, λ=0)
	
end

# ╔═╡ 10f8bac3-ecb1-4a50-892e-ea9c55ddd35a
begin
	φ_s 			= @bind φ Slider(-180:1e-2:180, default = 35)
	ψ_s 			= @bind ψ Slider(-180:1e-2:180, default = 20)
end;


# ╔═╡ e2b656b9-877a-4e4a-9d06-a0d0a299b1eb
toggles = md"""
φ: $(φ_s)
ψ: $(ψ_s)
"""


# ╔═╡ ba2cb13b-00ab-4850-baed-0d565157c61e
begin
	plot_aircraft = plot(
	    # aspect_ratio = 1,
	    xaxis = "x", yaxis = "y", zaxis = "z",
	    zlim = (-15,20),#(-0.5, 0.5) .* span(wing_mesh),
		xlim = (-10,25),
		ylim = (-17.5,17.5),

	
		
		axis = false,
	    camera = (φ, ψ),
		grid = false
	)
	plot!(plot_aircraft, vertical_tail_mesh, label = false, mac = false)
	
	plot!(wing_mesh, label = false, mac = false)
	
	
for battery in edgesBattery
        for (ex, ey, ez) in battery
            plot!(plot_aircraft, ex, ey, ez, color = :purple, label = false, lw = 2)
        end
end
	plot!(plot_aircraft, horizontal_tail_mesh, label = false, mac = false)
	plot!(plot_aircraft, fuselage, label = false)
	

	#Cuboid
	#edges2 = plotvolume(7, 10, z_start, z_end; width=radius*1.5, λ=FACTOR)
	#for (ex, ey, ez) in edges2
	 #   plot!(p2, ex, ey, ez, color=:purple, label=false, lw=2)
	#end

	# Cylinder
	#for (ex, ey, ez) in cyl_edges
	#    plot!(plot_aircraft,ex, ey, ez, color=:pink, label=false, lw=2)
	#end
	plot_aircraft
	#savefig(plot_aircraft, "battery_layout.svg")
	
end

# ╔═╡ 3c66a4ae-e98f-47d3-9a2b-748d19e7a839
md"## Variation of Specific Energy"

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

# ╔═╡ 362f16ea-04d2-408d-b9a1-5327ff32bd96


# ╔═╡ 2e5cac5e-edd9-497b-b0e1-68607dfaf856
md"## Variation of Hybridization Ratio ϕ"

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

# ╔═╡ 6156c4fb-73ba-4b9f-810e-9d61d58faa1c
#md"## Variation of Controller P/W"
md"## Variation of Electric Motor P/W"

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

# ╔═╡ Cell order:
# ╟─5f1441ea-2158-4b08-98db-7c85b92307d4
# ╟─44d1c167-fc6c-4124-b1ac-5c643308f203
# ╟─4580f93b-25b0-4f41-bdfa-a0cd2f503278
# ╟─16ee62e4-8741-48de-998c-f344a317ca31
# ╟─be176d8b-e577-4726-be3c-3cf75477f04b
# ╟─6e781f8c-dee8-4d23-afa0-a79404518abc
# ╟─f94d1e79-08c9-4c4b-b69e-d97e78e1a330
# ╟─542807ac-edbe-48b8-bd2d-114ef822a440
# ╟─d437db6c-9419-4096-af80-6a7c72efcd68
# ╟─8327cd48-4d5e-4a18-97e0-20b9df6dd058
# ╠═60b6bc84-abac-481d-b547-ac1d9c493ee2
# ╠═87f4784b-323f-47f7-843b-ebe2c247230f
# ╟─72da1ebb-c5f2-4917-b9e3-86ab0f9a206e
# ╟─2dfd5203-a981-4199-95aa-500c0b217885
# ╟─76cd066f-06f0-456e-bce6-c220d0e8abbf
# ╠═2b6dabde-1843-4bd7-be53-df0848d5a9ee
# ╠═aa2c5d5c-372c-4807-9c88-bbb08eeaad50
# ╠═b514367c-3f6c-4602-8898-b6cfd63b4372
# ╟─4b73459d-6f4a-4778-859d-4ebb7a5ff6a0
# ╠═f656498f-5dd6-45fa-9bf7-0255856c7b34
# ╟─fa68ddb1-5299-44cd-a7e1-09a010f7d3be
# ╟─e6299196-d5a2-4a42-a69f-3af4ae688bbb
# ╠═d919009e-e83e-40fd-8ece-f3bcd606ad1c
# ╠═72ea507c-cc58-4743-957b-01e79f2123e5
# ╠═3fbc3c10-5de7-4896-92cd-e1214acd0153
# ╠═cf58a1b4-3af3-42ca-91f4-7c29bc5fe6c9
# ╠═12fcbaf3-2cb6-42a2-b4d4-e96a33501b02
# ╠═dd1654ff-c375-4fe2-b375-19f96d7065ca
# ╠═05e2e158-ce39-483a-a071-a68ace817d7e
# ╠═1275831a-47b1-4cf5-b6ae-5ebce365e44e
# ╠═6e67d675-69f4-4011-b252-320838482004
# ╟─9404471f-e980-4a23-91a3-e40eccc48d63
# ╠═5f26ad6f-807b-45b5-afce-3511f1862c83
# ╟─409ea466-8f4a-4896-ba9c-047cf52ae96d
# ╟─744f666b-2ec0-4592-844e-103dbff9b5fd
# ╠═a6a96afd-f204-4144-8ffd-6948b1f63d6c
# ╟─9b95805c-bd53-43eb-ae37-9ea56257f6fa
# ╠═1f46b0b2-ac0c-48f6-a113-79d6200a6b63
# ╠═c917a753-3f79-49be-9863-20d491acb6ba
# ╠═1afee013-750c-4d50-98e5-05cff6cbf67b
# ╠═f391e83a-4420-4e21-aaf1-67fb9afff913
# ╠═3e08973f-b80e-41b3-b97c-3350a8e35dae
# ╠═eb75c58a-3c75-409a-9d0b-0fcb17108447
# ╠═b51f4a31-11ff-4c19-a2d9-32cc01167b32
# ╠═f2a86f63-314b-4214-8011-54d39c14a840
# ╟─6365c847-6075-457d-8c6c-33600672caa7
# ╠═725e7bc4-275e-4565-a0e7-b17ed80a2200
# ╠═a36b68a3-2bc7-44ae-86b6-41d90c514c74
# ╠═5f83ed9d-eecf-4c82-b1e6-d633260eca0a
# ╟─6e5909de-3846-4e17-932e-28fb80eda5be
# ╟─1a95262a-bfec-4f92-82bc-7226f908e632
# ╠═edb76e31-e4df-48e0-835c-e33c1e59c865
# ╟─eac09430-a759-4681-b253-fa18b73239ef
# ╠═c080d78c-182b-470d-911b-f640ba443ba1
# ╟─6e32660f-cda0-433d-a78f-0e68730490df
# ╠═e870f93b-5b9e-4364-88d6-1e5d405e131a
# ╟─55549957-9eff-4af6-bf88-2ec23bdf9164
# ╟─8c3bb6c6-1c91-49f2-86d2-b6e81043b1a5
# ╟─e2b656b9-877a-4e4a-9d06-a0d0a299b1eb
# ╟─ba2cb13b-00ab-4850-baed-0d565157c61e
# ╟─10f8bac3-ecb1-4a50-892e-ea9c55ddd35a
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
