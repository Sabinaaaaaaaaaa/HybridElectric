### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 13afb595-136d-4b86-8717-0ce574770dd2
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

The efficiency from BEMT is implemented in the Total power requirements of the aircraft. 

$P_{req}=\frac{P_{total}}{η_{prop, BEMT}}$
"

# ╔═╡ 737332d8-ee5f-4e8c-8a0d-59a2e125358c
md"**Define Packages**"

# ╔═╡ 4bd2df40-4bdc-4bd4-981f-eced474fbc49
begin
	#INPUTS-------------------------------------------------------------------
	#Blade geometry 
	R          = 22.86/200; #radius  (m)
	r_hub      = 0.017145; #hub radius (m)
	Nb         = 2 #Number of blades
	V∞         = 9.14    #freestream velocity (m/s)
	Ω          = 4000  #RPM
	ρ          = 1.225
	r_R        = [0.15, 0.2, 0.25, 0.3, 0.35, 0.4, 0.45, 0.5, 0.55, 0.6, 0.65, 0.7, 0.75, 0.8, 0.85, 0.90, 0.95, 1.00]
	c_R        = [0.16, 0.146, 0.144, 0.143, 0.143, 0.146, 0.151, 0.155, 0.158, 0.160, 0.159, 0.155, 0.146, 0.133, 0.114, 0.089, 0.056, 0.022]
	beta_table = [31.68, 34.45, 35.93, 33.33, 29.42, 26.25, 23.67, 21.65, 20.02, 18.49, 17.06, 15.95, 14.87, 13.82, 12.77, 11.47, 10.15, 8.82]

	n = Ω / 60  # Convert RPM to rev/s
	D = 2 * R   # Diameter
	A= π*R^2#disk area m^2
end;

# ╔═╡ b3039873-a1e5-4443-b748-96802be057ba
begin
	Vvalues=5.5:0.05:12.0
	
	T = zeros(Float64, length(Vvalues))
	Q = zeros(Float64, length(Vvalues))
	P = zeros(Float64, length(Vvalues))
	η = zeros(Float64, length(Vvalues))
	J = zeros(Float64, length(Vvalues))
	CP= zeros(Float64, length(Vvalues))
	CT= zeros(Float64, length(Vvalues))
	CQ= zeros(Float64, length(Vvalues))
end;

# ╔═╡ 342303aa-3e70-43eb-8243-486ce015e803
for i=1:length(Vvalues)
	T[i], Q[i], P[i], η[i], J[i] = BEMT(R, r_hub, Nb, r_R, c_R,beta_table ,Vvalues[i],Ω, ρ)	



	CT[i] = T[i] / (ρ * n^2 * D^4)    
	CP[i] = P[i] / (ρ * n^3 * D^5)    
	CQ[i] = Q[i] / (ρ * n^2 * D^5)    

end

# ╔═╡ 91c9d637-cff3-47bc-8440-42163e0e0c20
md"## Validation"

# ╔═╡ f878fe4f-6202-4342-8c4b-d95c42583af2
plot(J, η, xlabel="J", ylabel="η", marker=:circle, linewidth=2,title="Efficiency at Ω=$Ω RPM",legend=false, ylims=(0,0.8))

# ╔═╡ ad01a19c-27db-4c8f-bf9d-44f5a60cf7ba
plot(J, P, xlabel="J", ylabel="P", marker=:circle, linewidth=2,title="Power at Ω=$Ω RPM",legend=false)

# ╔═╡ bb09f689-94a9-441a-98f6-e28ed8f07ca9
plot(J, Q, xlabel="J", ylabel="Q", marker=:circle, linewidth=2,title="Torque at Ω=$Ω RPM",legend=false)

# ╔═╡ e6c23bfb-0b94-4498-80e6-ed3a40987555
plot(J, T, xlabel="J", ylabel="T", marker=:circle, linewidth=2,title="Thrust at Ω=$Ω RPM",legend=false)

# ╔═╡ 41d024f0-8671-44ff-9bba-0578e6fd411e
plot(J, CT, xlabel="J", ylabel="CT", marker=:circle, linewidth=2,title="CT at Ω=$Ω RPM",legend=false, ylims=(0,0.15))

# ╔═╡ 08fcce0b-b432-43b9-87e5-d652fc740ad8
plot(J, CP, xlabel="J", ylabel="CP", marker=:circle, linewidth=2,title="CP at Ω=$Ω RPM",legend=false, ylims=(0,0.1))

# ╔═╡ 54ddfee6-ddb7-4ef6-b140-6074d948326c


# ╔═╡ 84c394ec-49cb-47b4-8022-4d0e8cfca7aa


# ╔═╡ ddc0a52a-50c1-4a32-94bd-ad2b5d590fd6
plot(J, CQ, xlabel="J", ylabel="CQ", marker=:circle, linewidth=2,title="CQ at Ω=$Ω RPM",legend=false)

# ╔═╡ Cell order:
# ╟─96103d14-2329-406d-9683-6a8b678ece9e
# ╟─1960531b-0b2b-447c-b973-5b8e8936162e
# ╟─737332d8-ee5f-4e8c-8a0d-59a2e125358c
# ╟─13afb595-136d-4b86-8717-0ce574770dd2
# ╠═4bd2df40-4bdc-4bd4-981f-eced474fbc49
# ╠═b3039873-a1e5-4443-b748-96802be057ba
# ╠═342303aa-3e70-43eb-8243-486ce015e803
# ╟─91c9d637-cff3-47bc-8440-42163e0e0c20
# ╟─f878fe4f-6202-4342-8c4b-d95c42583af2
# ╟─ad01a19c-27db-4c8f-bf9d-44f5a60cf7ba
# ╟─bb09f689-94a9-441a-98f6-e28ed8f07ca9
# ╟─e6c23bfb-0b94-4498-80e6-ed3a40987555
# ╟─41d024f0-8671-44ff-9bba-0578e6fd411e
# ╟─08fcce0b-b432-43b9-87e5-d652fc740ad8
# ╟─54ddfee6-ddb7-4ef6-b140-6074d948326c
# ╟─84c394ec-49cb-47b4-8022-4d0e8cfca7aa
# ╟─ddc0a52a-50c1-4a32-94bd-ad2b5d590fd6
