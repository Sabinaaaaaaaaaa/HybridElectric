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

# ╔═╡ f858e0ae-496c-4dcb-a997-e77cb4a48684
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

# ╔═╡ 4cbf94c2-ca00-11f0-8184-432af9656ff0
md"# Hybrid Electric Aircraft Demo (Inputs)"

# ╔═╡ 4148d196-cabb-46fc-9680-8d29e423fa0b
md"## Dornier 328 Example"

# ╔═╡ 589e18a3-aa42-4feb-968a-d142e0b51d32
md"
This Inputs demo shows how to define the following features for interactive parameter definition and sizing:
* Aircraft geometry
* Propulsion features
* Mission parameters
"

# ╔═╡ c2096e9e-10f6-4f77-90e5-7fe4c54db946
	md"**Define Packages**"

# ╔═╡ 9e98e3c8-cb09-4242-baaf-a299bc914f1f
# ╠═╡ disabled = true
#=╠═╡
import Pkg
  ╠═╡ =#

# ╔═╡ 76d3de73-2f2f-4e8b-99d7-a5a3bb22d4ba
# ╠═╡ show_logs = false
# ╠═╡ disabled = true
#=╠═╡
Pkg.add("PlutoUI")
  ╠═╡ =#

# ╔═╡ 10f15af1-af71-4298-8597-c89831ae5fd5


# ╔═╡ 520372cc-3008-4306-b1df-8014c4debe00
md"## Define Aircraft Geometry"

# ╔═╡ 2be2e720-6c6b-48fc-9fae-52388d604af9
md"### HybridElectric Aircraft Struct Initialisation"

# ╔═╡ 21bb461e-434d-4332-a6a1-0bf6a165e2ce
md"
| Parameter | Name 						 | Units |
| ---- 		| ----- 					 | ----- |
| MTOW 		| Maximum Take-off Weight    | kg    |
| W_payload | Payload Weight 		     | kg	 |
| W_empty   | Empty Weight 				 | kg 	 |
| S 		| Wing Planform Area 		 | m^2 	 |
| AR 		| Aspect Ratio 				 |  	 |
| e 		| Oswald Efficieny 		     |  	 |
| Cd0 		| Zero-Lift Drag Coefficient |  	 |
"

# ╔═╡ b1288e04-9fa6-4bdc-8911-7a1411524331
md"""
MTOW
$(@bind MTOW Slider(5000.0:20000.0, default=13990.0, show_value=true)) kg
"""

# ╔═╡ f3fc7161-bf65-4bad-998f-6c48e9eb6a57
md"""
Payload Weight
$(@bind W_payload Slider(50.0:3000.0, default=2720.0, show_value=true)) kg
"""

# ╔═╡ fc8ef408-efa1-4cf8-8b8e-9028fefdccb7
md"""
Empty Weight
$(@bind W_empty Slider(2500.0:9000.0, default=8900.0, show_value=true)) kg
"""

# ╔═╡ 04861189-1866-4b6b-a1e1-58829cfcefe2
begin
    S   = 40.0;
    AR  = 11.0;
    e   = 0.80;
    Cd0 = 0.0220;
end;

# ╔═╡ 35edb82f-b24a-44ca-a003-01d1230f9334
md"""
**Summary**

**MTOW** 	  = $(MTOW) kg  
**W_payload** = $(W_payload) kg  
**W_empty**   = $(W_empty) kg  
**S** 		  = $(S) m²  
**AR** 		  = $(AR)  
**e** 		  = $(e)  
**Cd₀** 	  = $(Cd0)
"""

# ╔═╡ 52b8acb8-c193-4ffe-91a1-b836ff80808c
aircraft = Aircraft(MTOW, W_payload, W_empty, S, AR, e, Cd0)#remember to remove this after the update!

# ╔═╡ 6edd7a19-d21c-4c00-bf75-19a46d90ce42


# ╔═╡ c9d509b7-d182-4da4-92fa-601e79fb487b
md"#### AeroFuse Aircraft Wing Geometry add plot as well!"

# ╔═╡ 8d658e88-12de-46b4-b509-4e5999942d11
# ╠═╡ disabled = true
#=╠═╡
# Wing
wing = Wing(
    foils     = fill(naca4(2,4,1,2), 2),
    chords    = [1.0, 0.6],
    twists    = [2.0, 0.0],
    spans     = [4.0],
    dihedrals = [5.],
    sweeps    = [5.],
    symmetry  = true,
);

x_w, y_w, z_w = wing_mac = mean_aerodynamic_center(wing)
S, b, c = projected_area(wing), span(wing), mean_aerodynamic_chord(wing);
  ╠═╡ =#

# ╔═╡ 76bcc84a-c67e-454b-91fa-7062c9bf4354
# ╠═╡ disabled = true
#=╠═╡
wing = Wing(
    foils     = fill(naca4((2,4,1,2)), 3),  # Airfoils, type Foil
    chords    = [2.0, 1.6, 0.2],            # Chord lengths (m)
    twists    = [0.0, 0.0, 0.0],            # Twist angles (deg)
    spans     = [5., 0.6],                  # Span lengths (m)
    dihedrals = [5., 5.],                   # Dihedral angles (deg)
    sweeps    = [20.,20.],                  # Sweep angles (deg)
    w_sweep   = 0.25,                       # Chord length fraction of sweep location
    # symmetry  = true,                       # Symmetry in x-z plane
    # flip      = true                        # Reflection about x-z plane
)

## Create symmetric wing instead
using Accessors

wing = @set wing.symmetry = true

## Evaluate geometric properties
x_w, y_w, z_w = wing_mac = mean_aerodynamic_center(wing) # Aerodynamic center
S_w = projected_area(wing) # Projected area
b_w = span(wing) # Wingspan
c_w = mean_aerodynamic_chord(wing) # Mean aerodynamic chord
tau_w = taper_ratio(wing) # Taper ratio

lambda_w_c4 = sweeps(wing, 0.25) # Quarter-chord sweep angles
lambda_w_c2 = sweeps(wing, 0.5) # Half-chord sweep angles

ct = camber_thickness(wing, 60) # Camber-thickness distribution
coords = coordinates(wing) # Leading and trailing edge coordinates

## Plotting
using Plots
plt = plot(
    size = (800, 600),
    aspect_ratio = 1, 
    zlim = (-0.5, 0.5) .* span(wing),
    camera = (30, 60)
)
plot!(wing, label = "Wing", 
    # mac = false # Disable mean aerodynamic center plot
)

# savefig(plt, "plots/wing_geom.pdf")
  ╠═╡ =#

# ╔═╡ 4083b165-feab-4f24-b7ea-d87e4000d0f3


# ╔═╡ 050d7357-431a-4ba1-991b-e365c0b072d2
md"#### AeroFuse Aircraft Fuselage Geometry"

# ╔═╡ 6060ae31-f680-452a-b6e2-132029be77d5
# ╠═╡ disabled = true
#=╠═╡
# Fuselage
l_fuselage = 8.      # Length (m)
h_fuselage = 0.6     # Height (m)
w_fuselage = 0.7     # Width (m)

# Chordwise locations and corresponding radii
lens = [0.0, 0.005, 0.01, 0.03, 0.1, 0.2, 0.4, 0.6, 0.7, 0.8, 0.98, 1.0]
rads = [0.05, 0.15, 0.25, 0.4, 0.8, 1., 1., 1., 1., 0.85, 0.3, 0.01] * w_fuselage / 2

fuse = Fuselage(l_fuselage, lens, rads, [-3.0, 0., 0.])
  ╠═╡ =#

# ╔═╡ a60e7deb-836f-4ff7-947d-22407d9146de
# ╠═╡ disabled = true
#=╠═╡
## Fuselage example
using AeroFuse
using Plots

# Fuselage parameters
l_fuselage = 18. # Length (m)
h_fuselage = 1.5 # Height (m)
w_fuselage = 1.8 # Width (m)

## Hyperelliptic fuselage
fuse = HyperEllipseFuselage(
    radius = w_fuselage / 2,
    length = l_fuselage,
    c_nose = 2,
    c_rear = 2,
)

ts = 0:0.1:1                # Distribution of sections
S_f = wetted_area(fuse, ts) # Surface area, m²
V_f = volume(fuse, ts)      # Volume, m³

## Plot
plot(fuse, 
    aspect_ratio = 1, 
    zlim = (-0.5, 0.5) .* fuse.length,
    label = "Fuselage"
)

## Chordwise locations and corresponding radii
lens = [0.0, 0.005, 0.01, 0.03, 0.1, 0.2, 0.4, 0.6, 0.7, 0.8, 0.98, 1.0]
rads = [0.05, 0.15, 0.25, 0.4, 0.8, 1., 1., 1., 1., 0.85, 0.3, 0.01] * w_fuselage / 2

fuse = Fuselage(l_fuselage, lens, rads, [0., 0., 0.])

## Plotting
plot(fuse, aspect_ratio = 1, zlim = (-10,10))
  ╠═╡ =#

# ╔═╡ 160598df-3b11-407e-a122-fe491e46f759


# ╔═╡ a586a32e-3e07-4db5-81e2-8084004e857d
md"#### AeroFuse Aircraft Horizontal Tail Geometry"

# ╔═╡ 007d6533-9d5c-461f-b284-dc0a72729c02
# ╠═╡ disabled = true
#=╠═╡
# Horizontal tail
htail = Wing(
    foils     = fill(naca4(0,0,1,2), 2),
    chords    = [0.7, 0.42],
    twists    = [0.0, 0.0],
    spans     = [1.25],
    dihedrals = [0.],
    sweeps    = [6.39],
    position  = [4., 0, -0.1],
    angle     = -2.,
    axis      = [0., 1., 0.],
    symmetry  = true
)
  ╠═╡ =#

# ╔═╡ 7e2a93ab-2852-4e7e-b971-4e3d600829ec


# ╔═╡ 5bb71efb-626d-45ab-af84-cebdc090d69e
md"#### AeroFuse Aircraft Vertical Tail Geometry"

# ╔═╡ 972c6a7f-0282-477e-9a85-f4353c278b54
# ╠═╡ disabled = true
#=╠═╡
# Vertical tail
vtail = Wing(
    foils     = fill(naca4(0,0,0,9), 2),
    chords    = [0.7, 0.42],
    twists    = [0.0, 0.0],
    spans     = [1.0],
    dihedrals = [0.],
    sweeps    = [7.97],
    position  = [4., 0, 0],
    angle     = 90.,
    axis      = [1., 0., 0.]
)
  ╠═╡ =#

# ╔═╡ f444e1cb-8da4-4b41-bf41-f89fc8e2bb96


# ╔═╡ 97f379f2-ef81-490c-9802-aae122058dd8
md"#### AeroFuse Aircraft Geometry Plot"

# ╔═╡ 9bbe660a-7adf-4eea-be4c-1efd89f94c4b
# ╠═╡ disabled = true
#=╠═╡
plt = plot(
    size = (1000, 600),
    aspect_ratio = 1,
    zlim = (-0.5, 0.5) .* span(wing),
    camera = (-60,15)
)
plot!(wing, label = "Wing")
plot!(htail, label = "Horizontal Tail")
plot!(vtail, label = "Vertical Tail")
plot!(fuse, color = :grey, label = "Fuselage")

  ╠═╡ =#

# ╔═╡ 0068a8e5-e3da-43b8-9300-18c1b8e3270e


# ╔═╡ c4f9bcae-f77e-463e-b190-ac06e6b2d6ec
md"## Define Propulsion Features"

# ╔═╡ 7661aa21-9ebc-48b2-8e07-90416a9794ff
md"#### HybridElectric Propulsion Struct Initialisation"

# ╔═╡ 6d1f9727-b9b9-48e5-a08c-d4e0d63fa8e0
md"
| Parameter 				 | Name 							| Units 		 |
| ---- 			 		     | ----- 							| ----- 		 |
| η_motor 		 		     | Motor Efficiency 				| 				 |
| η_controller 	 			 | Controller Efficiency			|                |
| η_battery 	 			 | Battery Efficiency				|                |
| specificenergy 			 | Specific Energy 					| Wh/kg          |
| SOC_min 		 			 | Minimum State of Charge   		| decimal (not %)|
| SFC 			 			 | Specific Fuel Consumption     	| kg/(kW h)      |
| power_to_weight_motor 	 | Motor Power to Weight Ratio      | W/kg           |
| power_to_weight_controller | Controller Power to Weight Ratio | W/kg           |
| W_engine 					 | Engine Weight                    | kg             |


"

# ╔═╡ 6869c82f-55d0-468b-b9e6-62f8df5e00f4
begin
	η_motor                    = 0.95 #95-97% efficiency   
	η_controller               = 0.96
	η_battery                  = 0.95
	specificenergy             = 250.0
	SOC_min                    = 0.2
	SFC                        = 0.332
	power_to_weight_motor      = 5200
	power_to_weight_controller = 3702.70
	W_engine 				   = 2270.0
	P_max_engine 			   = 3251252
	No_Engines                 = 2
end;

# ╔═╡ 63305423-e5e7-4368-9c30-f2103c6069c9
md"""
**Summary**

**η_motor** 	  				  = $(η_motor) 
**η_controller** 				  = $(η_controller) 
**η_battery**                     = $(η_battery) 
**specificenergy** 		  		  = $(specificenergy) Wh/kg    
**SOC_min** 		  			  = $(SOC_min)  
**power_to_weight_motor** 		  = $(power_to_weight_motor) W/kg 
**power_to_weight_controller** 	  = $(power_to_weight_controller) W/kg
**W_engine** 	  				  = $(W_engine) kg
**P_max_engine**                  = $(P_max_engine) W
**No_Engines**                    = $(No_Engines)
"""

# ╔═╡ e6b63c45-ff11-4f18-997a-c6a74bc08439
propulsion = Propulsion(η_motor, η_controller, η_battery, specificenergy, SOC_min, SFC, power_to_weight_motor, power_to_weight_controller, W_engine, P_max_engine, No_Engines)

# ╔═╡ 79276a33-b7e9-4e9d-b3b6-0d40e6ee233f


# ╔═╡ e868d3aa-e84a-48d4-b6ed-bb531f97df72
md"## Define Mission Segment Parameters"

# ╔═╡ 62bab93a-2a92-4e03-86c8-51a65a6e2242
md"#### HybridElectric MissionSegment Struct Initialisation"

# ╔═╡ 4d9d3fc8-6ab4-4d9f-b078-a6db198b1ee0
md"
| Parameter 	  | Name 							    | Units 		  |
| ---- 			  | ----- 							    | ----- 		  |
| name 	 		  | Name of the Mission Segment	     	| 				  |
| h 		 	  | Altitude			                | m               |
| V 	 		  | Airspeed				            | m/s             |
| duration 		  | Segment Duration 					| s               |
| ROC 	    	  | Rate of Climb   		            | m/s             |
| ϕ	 			  | Hybridisation Factor     	        |                 |
| load 	 		  | Load Factor                         |          		  |
| SOC_initial 	  | Initial State of Charge for Segment | decimal (not %) |
| weight_fraction | Weight Fraction for Segment         |                 |
| dVdt 			  | Acceleration                        | m/s^2           |
| ρ 			  | Density                             | kg/m^3          |

"

# ╔═╡ 9dc2d3f4-e4fb-436e-bbd6-2f845e179a8e
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

# ╔═╡ 7ce89f40-f96a-4d6a-9771-0b4bb0454ae3
md"""
**Summary**

**name** 	  	    = $(name) 
**altitude** 		= $(h) 
**duration**        = $(duration) kg  
**ROC** 		    = $(ROC)   
**ϕ** 		  		= $(ϕ)  
**load** 		    = $(load) 
**dVdt** 	  	    = $(dVdt)
**ρ** 	  	    	= $(ρ)
"""

# ╔═╡ 6a2a83e5-ca37-4f18-aea8-425ab528bf83
CRUISE = MissionSegment(name, h, V, duration, ROC, ϕ, load, dVdt, ρ)

# ╔═╡ Cell order:
# ╟─4cbf94c2-ca00-11f0-8184-432af9656ff0
# ╟─4148d196-cabb-46fc-9680-8d29e423fa0b
# ╟─589e18a3-aa42-4feb-968a-d142e0b51d32
# ╟─c2096e9e-10f6-4f77-90e5-7fe4c54db946
# ╠═f858e0ae-496c-4dcb-a997-e77cb4a48684
# ╠═9e98e3c8-cb09-4242-baaf-a299bc914f1f
# ╠═76d3de73-2f2f-4e8b-99d7-a5a3bb22d4ba
# ╟─10f15af1-af71-4298-8597-c89831ae5fd5
# ╟─520372cc-3008-4306-b1df-8014c4debe00
# ╟─2be2e720-6c6b-48fc-9fae-52388d604af9
# ╟─21bb461e-434d-4332-a6a1-0bf6a165e2ce
# ╟─b1288e04-9fa6-4bdc-8911-7a1411524331
# ╟─f3fc7161-bf65-4bad-998f-6c48e9eb6a57
# ╟─fc8ef408-efa1-4cf8-8b8e-9028fefdccb7
# ╠═04861189-1866-4b6b-a1e1-58829cfcefe2
# ╟─35edb82f-b24a-44ca-a003-01d1230f9334
# ╠═52b8acb8-c193-4ffe-91a1-b836ff80808c
# ╟─6edd7a19-d21c-4c00-bf75-19a46d90ce42
# ╟─c9d509b7-d182-4da4-92fa-601e79fb487b
# ╠═8d658e88-12de-46b4-b509-4e5999942d11
# ╠═76bcc84a-c67e-454b-91fa-7062c9bf4354
# ╟─4083b165-feab-4f24-b7ea-d87e4000d0f3
# ╟─050d7357-431a-4ba1-991b-e365c0b072d2
# ╟─6060ae31-f680-452a-b6e2-132029be77d5
# ╟─a60e7deb-836f-4ff7-947d-22407d9146de
# ╟─160598df-3b11-407e-a122-fe491e46f759
# ╟─a586a32e-3e07-4db5-81e2-8084004e857d
# ╟─007d6533-9d5c-461f-b284-dc0a72729c02
# ╟─7e2a93ab-2852-4e7e-b971-4e3d600829ec
# ╟─5bb71efb-626d-45ab-af84-cebdc090d69e
# ╟─972c6a7f-0282-477e-9a85-f4353c278b54
# ╟─f444e1cb-8da4-4b41-bf41-f89fc8e2bb96
# ╟─97f379f2-ef81-490c-9802-aae122058dd8
# ╟─9bbe660a-7adf-4eea-be4c-1efd89f94c4b
# ╟─0068a8e5-e3da-43b8-9300-18c1b8e3270e
# ╟─c4f9bcae-f77e-463e-b190-ac06e6b2d6ec
# ╟─7661aa21-9ebc-48b2-8e07-90416a9794ff
# ╟─6d1f9727-b9b9-48e5-a08c-d4e0d63fa8e0
# ╠═6869c82f-55d0-468b-b9e6-62f8df5e00f4
# ╟─63305423-e5e7-4368-9c30-f2103c6069c9
# ╠═e6b63c45-ff11-4f18-997a-c6a74bc08439
# ╟─79276a33-b7e9-4e9d-b3b6-0d40e6ee233f
# ╟─e868d3aa-e84a-48d4-b6ed-bb531f97df72
# ╟─62bab93a-2a92-4e03-86c8-51a65a6e2242
# ╟─4d9d3fc8-6ab4-4d9f-b078-a6db198b1ee0
# ╠═9dc2d3f4-e4fb-436e-bbd6-2f845e179a8e
# ╟─7ce89f40-f96a-4d6a-9771-0b4bb0454ae3
# ╠═6a2a83e5-ca37-4f18-aea8-425ab528bf83
