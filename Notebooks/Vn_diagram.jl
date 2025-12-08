### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 682e2815-b0d1-465a-b650-9102c5f712bd
# ╠═╡ show_logs = false
begin
	using Pkg
	using Plots
    using PlutoUI
	using Roots
    import PlutoUI: Slider, NumberField, TextField, CheckBox
	Pkg.add("Revise")
	Pkg.develop(path="C:\\Users\\sabin\\OneDrive\\Desktop\\FYP\\HybridElectric")
	using HybridElectric
	using AeroFuse
	TableOfContents()
end

# ╔═╡ 547f0f90-ca6b-11f0-b9ea-cdc7a35f6e6e
md"# Hybrid Electric Aircraft Demo (V-n diagram)"

# ╔═╡ 0846f4cc-6e32-4c5f-be92-ef262bd0f910
md"
This Demo shows how to use the HybridElectric module to plot a V-n diagram.
To construct V-n diagram, the following parameters must be prescribed.
* 𝑉𝑠1: +1𝑔 stall speed of the minimum steady flight speed which is possible.
* 𝑉𝑐: design cruising speed
* 𝑉𝐷: Design diving speed
* 𝑉𝐴: Design maneuvering speed
* 𝑉𝐵 : Design speed for maximum gust intensity
"

# ╔═╡ 71628473-ebdb-4748-afdf-394e2b11269a
	md"**Define Packages**"

# ╔═╡ 15c41521-27f0-467d-ae0c-e5eca27a2c63
md"### Determination of +1g stall speed"

# ╔═╡ 655fd09d-5039-4a04-9582-c3a59dc95f45
md"
The minimum achievable steady flight speed for FAR 25 certified airplanes is
given by

$V_{s1} = \sqrt{\frac{2W_t/S}{\rho C_{n_{max}}}}$

* 𝑊𝑡 is gross takeoff weight in lbs determined from preliminary weight sizing
* 𝑆 is wing area in 𝑓𝑡^2
* 𝜌 is air density in 𝑠𝑙𝑢𝑔𝑠/𝑓𝑡^3
* 𝐶𝑛𝑚𝑎𝑥 is the maximum normal force coefficient

The maximum normal force coefficient is given by
$C_{n_{max}} = \sqrt{ C_{L_{max}}^2 +C_{D_{max}}^2}$

It is also acceptable to use
$𝐶_{𝑛_{𝑚𝑎𝑥𝑖}} = 1.1𝐶_{𝐿_{𝑚𝑎𝑥}}$
"

# ╔═╡ 90131c72-db1b-4c20-9efb-60e73840cda1
begin
	Wt    = 56800 #lbs
	ρ     = 0.002377 #slugs/ft^3
	Clmax = 1.6
	S     = 728 #ft^2
	Cnmax = 1.1*Clmax
	Vs1=sqrt(  (2*Wt/S)   /(ρ*Cnmax)    )/ 1.688 #knots
end;

# ╔═╡ 22307936-81ba-40d6-b3d1-c78bd0a6e25a


# ╔═╡ 2ac32400-ce08-464e-87b9-5ce62d915660
md"### Determination of design limit load factor"

# ╔═╡ a2ab0bb7-0efb-4ca0-861b-8b1a80d175ce
begin
    nlim_plus = 2.1 + 24000/(Wt+10000)
    if nlim_plus < 2.5
		nlim_plus=2.5
	end
	if nlim_plus > 3.8
		nlim_plus=3.8
    end
	md"nlim+ = $(nlim_plus)"
end

# ╔═╡ bf900cb6-de88-4995-a8c3-7befeef7e11b


# ╔═╡ ea0284b0-f933-40ee-aa13-c3dd3a95b6d4
md"### Determination of design maneuvering speed"

# ╔═╡ cd3171c9-7b41-4213-9341-bf52a187a689
md"The design maneuvering speed (the corner speed)"

# ╔═╡ 17b4c560-3eda-4259-b973-2c5c0995593c
Va=round(Vs1*sqrt(nlim_plus), digits=2) #knots

# ╔═╡ 967b3b0e-0d0d-4803-82a6-bf7625400d36


# ╔═╡ e979424f-ef90-4ac8-9136-a5536d470eb8
md"### Construction of gust load factor lines"

# ╔═╡ fa77f574-dcb7-4bcf-930b-caa65f8e2d7a
md"""
$n_{lim} = 1+ \frac{K_g U_{de} V C_{Lα}}{498W_t/S}$
$K_g = \frac{0.88 μ_g}{5.3 +μ_g}$
$μ_g = \frac{2W_t/S}{ρcgC_{Lα}}$
"""

# ╔═╡ 52f814c4-d15d-4b81-a6ed-31725b8ec5d2
begin
	c=5.95 #mac ft
	Clα = 4.33 #rad^-1
	g=32.174 #ft/s^2
end;

# ╔═╡ 1774eaf3-0af2-45cc-93bf-fd6d07135d97
μg=round((2*Wt/S)/(ρ*c*g*Clα), digits=2)

# ╔═╡ dfe08eee-afcd-4d24-8aa3-92cc516c0c4c
Kg=round((0.88*μg)/(5.3+μg), digits=2)

# ╔═╡ 90e45bbf-c546-4100-bb0c-5a2e667129ef
md"""
The derived gust velocities 𝑈𝑑𝑒 in FAR 25 (at 24,000𝑓𝑡) are the following.
* For gust line marked 𝑉𝐵:𝑈𝑑𝑒 = 84.7 − 0.000933ℎ = 63𝑓𝑝𝑠
* For gust line marked 𝑉𝐶:𝑈𝑑𝑒 = 66.67 − 0.00083ℎ = 47𝑓𝑝𝑠
* For gust line marked 𝑉𝐷:𝑈𝑑𝑒 = 33.34 − 0.000417ℎ = 24𝑓𝑝𝑠
"""

# ╔═╡ 4dffaf40-6e75-441a-9401-33de8989a391
begin
	h=24000 #ft
	UdeVb = 84.7 -0.000933*h
	UdeVc = 66.67 -0.00083*h
	UdeVd = 33.34 -0.000417*h
end;

# ╔═╡ c1cd7c76-8985-4942-97cb-0cb30810f65b
begin
	factor=Kg*Clα/(498*Wt/S)
		
	nlimVb(V) = 1 + factor*UdeVb*V*1.68781
	nlimVc(V) = 1 + factor*UdeVc*V*1.68781
	nlimVd(V) = 1 + factor*UdeVd*V*1.68781
	# Negative gust lines (dashed)
    nlimVb_neg(V) = 1 - factor*UdeVb*V*1.68781  # Note the minus sign
    nlimVc_neg(V) = 1 - factor*UdeVc*V*1.68781
    nlimVd_neg(V) = 1 - factor*UdeVd*V*1.68781
end;

# ╔═╡ 03a96358-a550-4f22-bf33-4f1c2d6cd463


# ╔═╡ a189b86e-b148-4368-b80f-ce110c148d36
md"### Determination design speed for maximum gust intensity"

# ╔═╡ 5c3118e0-978b-465b-927c-d71cb4a5a31e
stall_line_pos(V) = (V/Vs1)^2

# ╔═╡ 3f7a4909-0b18-4103-a44f-6be2b43394a2
begin
	# Find the root of the difference
    Vb = find_zero(V -> stall_line_pos(V) - nlimVb(V), (0, 400))  # search range
    n_intersect = stall_line_pos(Vb)
    
    md"Intersection at Vb = $(round(Vb, digits=2)) knots, n = $(round(n_intersect, digits=2))"
	
end

# ╔═╡ e134e1a1-b112-4f06-8d83-cd9752c72916


# ╔═╡ eb6ae05c-32cf-4bf3-8add-e338172a5c96
md"### Determination of design cruising speed"

# ╔═╡ dea84caa-45b3-41fe-b6ab-89b982c72c3a
Vc = round(Vb+43, digits=2) #knots

# ╔═╡ a116f639-4234-4ec8-a72c-416152aefe35


# ╔═╡ 3289ffd4-7f0f-43d9-b5f7-afef3716e06e
md"### Determination of design diving speed"

# ╔═╡ 2333c43e-ad2b-4644-b97e-4d9fbec251f9
Vd=round(1.2*Vc, digits=2)

# ╔═╡ 19426273-e075-4d39-abcd-9a307d379ca8


# ╔═╡ cbccec3d-8e5c-479b-bb30-3c19345a61f8
md"### Determination of negative stall speed line"

# ╔═╡ 8493d67f-b5fb-40b2-91a7-71d0ec9c1c3e
begin
	Cnmax_neg=1.1
	Vsneg=sqrt(  (2*Wt/S)   /(ρ*Cnmax_neg)    )/ 1.688 #knots
end;

# ╔═╡ a7d5c433-deb1-4ef2-ab63-02e0c1e5bbc0
stall_line_neg(V)=-(V/Vsneg)^2;

# ╔═╡ 00282910-b6ab-475e-876a-a96dac939e67


# ╔═╡ 7164a8c9-189b-4cca-8b61-dfa40dc19d0e
md"## V-n diagram"

# ╔═╡ b0e5f0e1-f779-4442-a860-381c9862b5c3
md"
The region bounded between the maximum positive load factor and the minimum
positive load factor is allowable load factor region. Any load factor greater than +𝑛𝑚𝑎𝑥 and less than −𝑛𝑚𝑎𝑥 is unobtainable region. The region out of the allowable region is highly likely to cause structural damage to the airframe. 
"

# ╔═╡ 6aec31e7-b164-4930-8961-e91a357bf16a
begin
    V = 0:10:400  # V in knots
	
	plot(V, nlimVb.(V), label="VB gust line", linewidth=2)
		

	    # Add more lines
    plot!(V, nlimVc.(V), label="VC gust line")
    plot!(V, nlimVd.(V), label="VD gust line")
	
	plot!(V, nlimVb_neg.(V), label="VB gust line", linewidth=2, linestyle=:dash)
    plot!(V, nlimVc_neg.(V), label="VC gust line", linewidth=2, linestyle=:dash)
    plot!(V, nlimVd_neg.(V), label="VD gust line", linewidth=2, linestyle=:dash)

	plot!(V, stall_line_pos.(V),label="+Stall line", linewidth=3)
	plot!(V, stall_line_neg.(V),label="-Stall line", linewidth=3)

	xlabel!("V (knots)")
	ylabel!("Load Factor (n)")
	ylims!(-3,6)
end

# ╔═╡ Cell order:
# ╟─547f0f90-ca6b-11f0-b9ea-cdc7a35f6e6e
# ╟─0846f4cc-6e32-4c5f-be92-ef262bd0f910
# ╟─71628473-ebdb-4748-afdf-394e2b11269a
# ╟─682e2815-b0d1-465a-b650-9102c5f712bd
# ╟─15c41521-27f0-467d-ae0c-e5eca27a2c63
# ╟─655fd09d-5039-4a04-9582-c3a59dc95f45
# ╠═90131c72-db1b-4c20-9efb-60e73840cda1
# ╟─22307936-81ba-40d6-b3d1-c78bd0a6e25a
# ╟─2ac32400-ce08-464e-87b9-5ce62d915660
# ╠═a2ab0bb7-0efb-4ca0-861b-8b1a80d175ce
# ╟─bf900cb6-de88-4995-a8c3-7befeef7e11b
# ╟─ea0284b0-f933-40ee-aa13-c3dd3a95b6d4
# ╟─cd3171c9-7b41-4213-9341-bf52a187a689
# ╠═17b4c560-3eda-4259-b973-2c5c0995593c
# ╟─967b3b0e-0d0d-4803-82a6-bf7625400d36
# ╟─e979424f-ef90-4ac8-9136-a5536d470eb8
# ╟─fa77f574-dcb7-4bcf-930b-caa65f8e2d7a
# ╠═52f814c4-d15d-4b81-a6ed-31725b8ec5d2
# ╠═1774eaf3-0af2-45cc-93bf-fd6d07135d97
# ╠═dfe08eee-afcd-4d24-8aa3-92cc516c0c4c
# ╟─90e45bbf-c546-4100-bb0c-5a2e667129ef
# ╠═4dffaf40-6e75-441a-9401-33de8989a391
# ╠═c1cd7c76-8985-4942-97cb-0cb30810f65b
# ╟─03a96358-a550-4f22-bf33-4f1c2d6cd463
# ╟─a189b86e-b148-4368-b80f-ce110c148d36
# ╠═5c3118e0-978b-465b-927c-d71cb4a5a31e
# ╟─3f7a4909-0b18-4103-a44f-6be2b43394a2
# ╟─e134e1a1-b112-4f06-8d83-cd9752c72916
# ╟─eb6ae05c-32cf-4bf3-8add-e338172a5c96
# ╠═dea84caa-45b3-41fe-b6ab-89b982c72c3a
# ╟─a116f639-4234-4ec8-a72c-416152aefe35
# ╟─3289ffd4-7f0f-43d9-b5f7-afef3716e06e
# ╠═2333c43e-ad2b-4644-b97e-4d9fbec251f9
# ╟─19426273-e075-4d39-abcd-9a307d379ca8
# ╟─cbccec3d-8e5c-479b-bb30-3c19345a61f8
# ╠═8493d67f-b5fb-40b2-91a7-71d0ec9c1c3e
# ╠═a7d5c433-deb1-4ef2-ab63-02e0c1e5bbc0
# ╟─00282910-b6ab-475e-876a-a96dac939e67
# ╟─7164a8c9-189b-4cca-8b61-dfa40dc19d0e
# ╟─b0e5f0e1-f779-4442-a860-381c9862b5c3
# ╟─6aec31e7-b164-4930-8961-e91a357bf16a
