### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 5eab50a0-c08e-11f0-a5d7-4d4ea062948d
using Pkg;

# ╔═╡ 2f783153-60e4-41a0-9261-4d9d0c6e0ba5
Pkg.develop(url="https://github.com/Sabinaaaaaaaaaa/AeroFuse.git");

# ╔═╡ df37da3d-df97-42da-9313-0f16f8d4f33c
Pkg.develop(url="https://github.com/Sabinaaaaaaaaaa/HybridElectric.git");

# ╔═╡ bdf80403-a6fe-4899-a1d9-162a3dcbcd55
using AeroFuse

# ╔═╡ 4bf2632c-e40b-4298-b340-20cb3cb1431f
using HybridElectric

# ╔═╡ a47b2fad-fc02-426e-b1a1-c7e37156db0d
# ╠═╡ disabled = true
#=╠═╡
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
  ╠═╡ =#

# ╔═╡ 530ff0b6-a046-403c-980e-5ee81ec4e3ee
# ╠═╡ disabled = true
#=╠═╡
solution=BEMT(R, r_hub, Nb, chordroot, chordtip, twist_deg_root, twist_deg_tip,V∞,Ω, ν, ρ)
  ╠═╡ =#

# ╔═╡ aa9b596b-ba69-4830-be79-954d255c9721
# ╠═╡ disabled = true
#=╠═╡
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
  ╠═╡ =#

# ╔═╡ 40893e4a-0b49-4f9c-a117-22b514aa4f30
# ╠═╡ disabled = true
#=╠═╡
begin
	# Compute geometric properties
	ts = 0:0.1:1                # Distribution of sections for nose, cabin and rear
	S_f = wetted_area(fuse, ts) # Surface area, m²
	V_f = volume(fuse, ts)      # Volume, m³
end;
  ╠═╡ =#

# ╔═╡ Cell order:
# ╠═5eab50a0-c08e-11f0-a5d7-4d4ea062948d
# ╠═2f783153-60e4-41a0-9261-4d9d0c6e0ba5
# ╠═df37da3d-df97-42da-9313-0f16f8d4f33c
# ╠═bdf80403-a6fe-4899-a1d9-162a3dcbcd55
# ╠═4bf2632c-e40b-4298-b340-20cb3cb1431f
# ╠═a47b2fad-fc02-426e-b1a1-c7e37156db0d
# ╠═530ff0b6-a046-403c-980e-5ee81ec4e3ee
# ╠═aa9b596b-ba69-4830-be79-954d255c9721
# ╠═40893e4a-0b49-4f9c-a117-22b514aa4f30
