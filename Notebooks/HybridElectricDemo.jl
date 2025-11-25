### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 92bfc810-c590-11f0-940e-dfb0e6cd3ef3
using Pkg

# ╔═╡ ca6e89a9-0d5a-42d8-9fd9-c2ae7a95fc2c
Pkg.add("Revise")

# ╔═╡ fd44ce46-5f4b-4b2e-af25-de6de19ad347
# ╠═╡ show_logs = false
Pkg.develop(path="C:\\Users\\sabin\\OneDrive\\Desktop\\FYP\\HybridElectric")

# ╔═╡ 34692a74-b703-4fff-ba94-6e5b59b48b5a
# ╠═╡ show_logs = false
using HybridElectric

# ╔═╡ d86e68bf-8491-446d-9c84-204f97832b98
using AeroFuse

# ╔═╡ 96103d14-2329-406d-9683-6a8b678ece9e
md"# Hybrid Electric Aircraft Demo"

# ╔═╡ 4bd2df40-4bdc-4bd4-981f-eced474fbc49
begin
	#INPUTS-------------------------------------------------------------------
	#Blade geometry 
	R         = 1.2; #radius  (m)
	r_hub     = 0.5; #hub radius (m)
	Nb        = 4; #Number of blades
	chordroot = 0.15;
	chordtip  = 0.08;
	twist_deg_root=25;
	twist_deg_tip=12;
	V∞      = 70;    #freestream velocity (m/s)
	Ω       = 2400;  #RPM
	ν       = 1.5e-5;#kinematic viscosity for Re (m^2/s)
	ρ       = 1.225;
	#-
end

# ╔═╡ 64dedb2d-a279-43db-86f0-46c3b2efaff9
solution=BEMT(R, r_hub, Nb, chordroot, chordtip, twist_deg_root, twist_deg_tip,V∞,Ω, ν, ρ)

# ╔═╡ dfbd4a70-2a2b-4cf3-9201-e534b683fa6d
Power=solution.P

# ╔═╡ f224e65a-99a5-447d-acb6-7ef632394f0e
md"Define Fuselage"

# ╔═╡ 021b1edf-cdbe-4525-a3dc-0176530cfccb
# Fuselage definition
fuse = HyperEllipseFuselage(
    radius = 1.2,          # Radius, m 
    length = 8.28,           # Length, m 
    x_a    = 0.19,          # Start of cabin, ratio of length 
    x_b    = 0.40,          # End of cabin, ratio of length
    c_nose = 1.6,           # Curvature of nose ??
    c_rear = 1.2,           # Curvature of rear ??
    d_nose = -0.5,          # "Droop" or "rise" of nose, m 
    d_rear = 0.7,           # "Droop" or "rise" of rear, m 
    position = [0.,0.,0.]   # Set nose at origin, m
)

# ╔═╡ 5ed75365-8ef1-4667-a609-5b44a58e1472
begin
	# Compute geometric properties
	ts = 0:0.1:1                # Distribution of sections for nose, cabin and rear
	S_f = wetted_area(fuse, ts) # Surface area, m²
	V_f = volume(fuse, ts)      # Volume, m³
end;

# ╔═╡ b02e76f9-a321-4642-8fd1-b7adcbc30217
batterymass(1)

# ╔═╡ Cell order:
# ╟─96103d14-2329-406d-9683-6a8b678ece9e
# ╠═92bfc810-c590-11f0-940e-dfb0e6cd3ef3
# ╠═ca6e89a9-0d5a-42d8-9fd9-c2ae7a95fc2c
# ╠═fd44ce46-5f4b-4b2e-af25-de6de19ad347
# ╠═34692a74-b703-4fff-ba94-6e5b59b48b5a
# ╠═d86e68bf-8491-446d-9c84-204f97832b98
# ╠═4bd2df40-4bdc-4bd4-981f-eced474fbc49
# ╠═64dedb2d-a279-43db-86f0-46c3b2efaff9
# ╠═dfbd4a70-2a2b-4cf3-9201-e534b683fa6d
# ╟─f224e65a-99a5-447d-acb6-7ef632394f0e
# ╠═021b1edf-cdbe-4525-a3dc-0176530cfccb
# ╠═5ed75365-8ef1-4667-a609-5b44a58e1472
# ╠═b02e76f9-a321-4642-8fd1-b7adcbc30217
