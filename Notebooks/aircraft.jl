### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ c9fb0da0-beef-11f0-89c3-4b46802e5b17
println("HelloWorld")

# ╔═╡ 64ee6e8d-e4b9-46b2-9ea2-ad0b0d7f7d26


# ╔═╡ ae619115-f506-4972-b627-3426bdcf9d09


# ╔═╡ c2c1d2c1-a9a7-4350-884b-eafc8f3d8793
### Cell 1 — Inputs
R = 0.75

# ╔═╡ 58d48851-c5e8-4b94-ace9-d2745ea12805
r_hub = 0.15

# ╔═╡ d145185e-dc26-4989-a9f8-953c87d40720
Nb = 3

# ╔═╡ cdc0b4ca-7fea-4754-a638-fbd888f61a61
chordroot = 0.1

# ╔═╡ 27a25e13-89f2-42c3-be6a-80c5688615a6
chordtip = 0.055

# ╔═╡ 471ac1a5-0fee-401c-adb3-d4051f8e6cea
twist_deg_root = 13

# ╔═╡ 19738c35-befd-4d7e-92a7-3a854a911ce8
twist_deg_tip = 5

# ╔═╡ 772ab3c5-680c-4c08-af7d-9a18fda0e5fb
V∞ = 70

# ╔═╡ ffaf76c5-18d6-4755-9d48-c03abfc40ad2
Ω = 1800

# ╔═╡ 5754cd51-86a4-462a-8576-daaabc6de38d
ν = 1.5e-5

# ╔═╡ ad29daa1-69ed-45c2-a10a-3b3726d76fa1
ρ = 1.225

# ╔═╡ a57fecc9-2bf4-4be3-b65d-c2efa14e2323
results = BEMT(R, r_hub, Nb, chordroot, chordtip, twist_deg_root, twist_deg_tip, V∞, Ω, ν, ρ)


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.0"
manifest_format = "2.0"
project_hash = "71853c6197a6a7f222db0f1978c7cb232b87c5ee"

[deps]
"""

# ╔═╡ Cell order:
# ╠═c9fb0da0-beef-11f0-89c3-4b46802e5b17
# ╠═64ee6e8d-e4b9-46b2-9ea2-ad0b0d7f7d26
# ╠═ae619115-f506-4972-b627-3426bdcf9d09
# ╠═c2c1d2c1-a9a7-4350-884b-eafc8f3d8793
# ╠═58d48851-c5e8-4b94-ace9-d2745ea12805
# ╠═d145185e-dc26-4989-a9f8-953c87d40720
# ╠═cdc0b4ca-7fea-4754-a638-fbd888f61a61
# ╠═27a25e13-89f2-42c3-be6a-80c5688615a6
# ╠═471ac1a5-0fee-401c-adb3-d4051f8e6cea
# ╠═19738c35-befd-4d7e-92a7-3a854a911ce8
# ╠═772ab3c5-680c-4c08-af7d-9a18fda0e5fb
# ╠═ffaf76c5-18d6-4755-9d48-c03abfc40ad2
# ╠═5754cd51-86a4-462a-8576-daaabc6de38d
# ╠═ad29daa1-69ed-45c2-a10a-3b3726d76fa1
# ╠═a57fecc9-2bf4-4be3-b65d-c2efa14e2323
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
