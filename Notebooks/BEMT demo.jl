### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 92bfc810-c590-11f0-940e-dfb0e6cd3ef3
using Pkg

# ╔═╡ ca6e89a9-0d5a-42d8-9fd9-c2ae7a95fc2c
# ╠═╡ show_logs = false
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
md"# Hybrid Electric Aircraft Demo (BEMT)"

# ╔═╡ 1960531b-0b2b-447c-b973-5b8e8936162e
md"
This Demo shows how to use the BEMT module. The propeller geometry must be defined. The BEMT module is then used to compute the following parameters

* T: Thrust produced 
* Q: Torque required
* P: Power required
* η: Efficiency
* J: Advance Ratio
"

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
T, Q, P, η, J =BEMT(R, r_hub, Nb, chordroot, chordtip, twist_deg_root, twist_deg_tip,V∞,Ω, ν, ρ)

# ╔═╡ dfbd4a70-2a2b-4cf3-9201-e534b683fa6d
Power=round(P; digits = 3)

# ╔═╡ Cell order:
# ╟─96103d14-2329-406d-9683-6a8b678ece9e
# ╟─1960531b-0b2b-447c-b973-5b8e8936162e
# ╠═92bfc810-c590-11f0-940e-dfb0e6cd3ef3
# ╠═ca6e89a9-0d5a-42d8-9fd9-c2ae7a95fc2c
# ╠═fd44ce46-5f4b-4b2e-af25-de6de19ad347
# ╠═34692a74-b703-4fff-ba94-6e5b59b48b5a
# ╠═d86e68bf-8491-446d-9c84-204f97832b98
# ╠═4bd2df40-4bdc-4bd4-981f-eced474fbc49
# ╠═64dedb2d-a279-43db-86f0-46c3b2efaff9
# ╠═dfbd4a70-2a2b-4cf3-9201-e534b683fa6d
