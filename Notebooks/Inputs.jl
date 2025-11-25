### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ 76d3de73-2f2f-4e8b-99d7-a5a3bb22d4ba
# ╠═╡ show_logs = false
# ╠═╡ disabled = true
#=╠═╡
Pkg.add("PlutoUI")
  ╠═╡ =#

# ╔═╡ 4cbf94c2-ca00-11f0-8184-432af9656ff0
md"# Hybrid Electric Aircraft Demo (Inputs)"

# ╔═╡ 589e18a3-aa42-4feb-968a-d142e0b51d32
md"
This Inputs demo shows how to define the following features for interactive parameter definition and sizing:
* Aircraft geometry
* Propulsion features
* Mission parameters
"

# ╔═╡ 010419dc-43c9-4bd1-be96-c15e5486bc95


# ╔═╡ 31df9527-d396-4b18-badc-c37c63e51bc4


# ╔═╡ 2d3a3518-0998-4068-bedb-8d1ffb80194a


# ╔═╡ bda9adb2-23eb-4b17-a108-50d8c68dc277


# ╔═╡ f858e0ae-496c-4dcb-a997-e77cb4a48684
begin
	md"**Define Packages**"
	using Pkg
	using Plots
    using PlutoUI
    import PlutoUI: Slider, NumberField, TextField, CheckBox
	Pkg.add("Revise")
	Pkg.develop(path="C:\\Users\\sabin\\OneDrive\\Desktop\\FYP\\HybridElectric")
	using HybridElectric
	using AeroFuse
end

# ╔═╡ 9e98e3c8-cb09-4242-baaf-a299bc914f1f
# ╠═╡ disabled = true
#=╠═╡
import Pkg
  ╠═╡ =#

# ╔═╡ Cell order:
# ╟─4cbf94c2-ca00-11f0-8184-432af9656ff0
# ╟─589e18a3-aa42-4feb-968a-d142e0b51d32
# ╠═f858e0ae-496c-4dcb-a997-e77cb4a48684
# ╠═9e98e3c8-cb09-4242-baaf-a299bc914f1f
# ╠═76d3de73-2f2f-4e8b-99d7-a5a3bb22d4ba
# ╠═010419dc-43c9-4bd1-be96-c15e5486bc95
# ╠═31df9527-d396-4b18-badc-c37c63e51bc4
# ╠═2d3a3518-0998-4068-bedb-8d1ffb80194a
# ╠═bda9adb2-23eb-4b17-a108-50d8c68dc277
