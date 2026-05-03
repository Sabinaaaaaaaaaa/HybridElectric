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

# ╔═╡ 75abc55d-ccf6-428f-9b3b-5e4951d7e939
# ╠═╡ show_logs = false
begin
    using Pkg
	using Plots
    using PlutoUI
    using LaTeXStrings
    import PlutoUI: Slider, NumberField, TextField, CheckBox
    using AeroFuse
    Pkg.add("Revise")
    Pkg.develop(path="C:\\Users\\sabin\\OneDrive\\Desktop\\FYP\\HybridElectric")
    using HybridElectric
    TableOfContents()
	using StaticArrays
end

# ╔═╡ 9f9a3b00-41bf-11f1-ac40-07b0b6a03969
md"# Plotting Cabin Area/Volume"

# ╔═╡ 25dc3b01-2407-4d9f-8904-0a21dc206f3c
md"**Define Packages** "

# ╔═╡ 5b191cad-d14b-4903-bbcf-279a36cf7675
md"## Aircraft to Modify Cabin"

# ╔═╡ ac6a2903-0360-4f82-b731-a17e036bba6f
md"## Payload Modification"

# ╔═╡ 6ae6b68f-5e22-4f0b-b7fe-f8d5da5a2345
md"""
This tool is used to measure the feasibility of adjusting payload for hybrid electric aircraft design. 

The payloadvolume function computes the volume with the specified coordinates. The plotvolume function outputs arrays with the surface coordinates. 

To alter the payload effectively, a payload sacrifice factor $λ$ is implemented. $λ$ is the percentage of volume sacrificed from cargo. The remaining volume is allocated for the battery volume constraints.

For example, if the cabin takes up $V$ volume and we want to sacrifice $30%$ of the cabin volume for batteries: 
* the new cabin volume will be $V(1-λ)$
* the battery volume constraint will be $Vλ$
where $λ = 0.3$.

This implementation assumes the payload mass is evenly distributed, thus the new cabin mass will also be $m(1-λ)$. 

"""

# ╔═╡ 7817aeca-96e9-4aa1-a62a-bea96be88186
md"""
Payload Volume and Plot Volume have the same input parameters

**Input Parameters**

| Parameter | Name 							| Units |
|---------- | ----- 						| ----- |
| x_start   | Payload length start position | m     | 
| x_end     | Payload length end position   | m     |
| z_start   | Payload height start position | m     |
| z_end     | Payload height end position   | m     |
| width     | Width of payload              | m     |
| radius    | Radius of payload             | m     |
| λ         | Payload sacrifice factor      | -     |

**Output Parameters**

| Parameter | Name                      | Units   |
|---------- | -----                     | ------- |
| edges     | Plot edges                | -       |



This implementation assumes the width is symmetric about the aircraft's vertical midplane. It also assumes payload reduction takes place along the x-axis, corresponding to the length.

"""

# ╔═╡ 25c56bbc-6b88-44ed-9caa-bb75635e2ee6
md"## Aircraft Definition"

# ╔═╡ d5ef65c0-4864-44bc-a071-2c00b1ace4ac
md"### Fuselage"

# ╔═╡ df74c6ff-9953-41fc-821e-e94d191f8740
begin
		fuselage = HyperEllipseFuselage(
		#known
	    radius = 1.09,          # Radius, m 
	    length = 20.915,        # Length, m 
	    x_a    = 0.15,          # Start of cabin, ratio of length
	    x_b    = 0.7,           # End of cabin, ratio of length 
		#estimates
	    c_nose = 1.6,           # Curvature of nose 
	    c_rear = 1.2,           # Curvature of rear 
	    d_nose = -0.4,          # "Droop" or "rise" of nose, m
	    d_rear = 0.8,           # "Droop" or "rise" of rear, m 
	    position = [0.,0.,0.]   # Set nose at origin, m
	)
	fuselage_end = fuselage.affine.translation + [ fuselage.length, 0., 0. ];
end;

# ╔═╡ 136fbc95-5389-48f9-a419-332dd4342743
begin
	radius = fuselage.radius
	
	x_start = 5
	x_end   = 15
	z_start = 0
	z_end = -1
	FACTOR = 1
end;

# ╔═╡ 064dac79-29e1-4540-8222-f14ef8085b4d
payloadvolume(x_start, x_end, z_start, z_end; width=0,radius=0.5, λ=FACTOR)

# ╔═╡ 9b6b3d47-dcc4-4b5a-95bb-80d83ac39c53
begin
	wingairfoil = read_foil(download("http://airfoiltools.com/airfoil/seligdatfile?airfoil=doa5-il"))
end;

# ╔═╡ ea40783c-1343-4074-9fa1-709b16edd39f
md"### Wing"

# ╔═╡ 3fddb990-d053-41cc-8f26-078e1d9ff464
wing = Wing(;
    chords    = [2.22, 2.22, 1.33], 
    foils     = [wingairfoil,wingairfoil, wingairfoil],
	twists 	  = [1.5, 1.5, -0.5],
	spans     = [3.15, 7.338],   
	sweeps    = [0.0, 7.1], 
	w_sweep   = 0.25, 
    dihedrals = fill(2.5, 2),
    symmetry  = true,
    angle       = 2.5,            #Incidence angle (deg)
	axis = [0, 1, 0],
    position    = [7.878, 0., 0.9]  #approximated last no.
);

# ╔═╡ a42a4353-f027-439f-a0d5-b527a1803706
begin
	AR = round(aspect_ratio(wing),digits=2)
	b_w = span(wing)
	c_w = mean_aerodynamic_chord(wing)	
	Sref = round(projected_area(wing), digits=2)
	mac40_wing = mean_aerodynamic_center(wing, 0.40)
end;

# ╔═╡ e1116ab3-1242-4860-bcd0-779c6f80c976
md"### Vertical Tail"

# ╔═╡ a96a61ed-b63e-4b6f-bcab-702d5780b5ee
vertical_tail = WingSection(
    area        = 11.06, 	    #Area + dorsal fin (m²). 
    aspect      = 1.58,  			
    taper       = 0.6,  			#					GUESS
    sweep       = 37, 			    #   				GUESS
    w_sweep     = 0.,   			#Leading-edge sweep GUESS
    root_foil   = naca4(0,0,1,2), 	#   				GUESS	
	tip_foil    = naca4(0,0,1,2), 	#   				GUESS	
    angle       = 90.,       		#To make it vertical
    axis        = [1, 0, 0], 
    position    = fuselage_end - [3.435+4.323-3, 0., -fuselage.d_rear]
);

# ╔═╡ 9a2b50f8-37c6-4a09-b7dc-52d7bfbf32d5
md"### Horizontal Tail"

# ╔═╡ 8b45c0e3-1205-460d-850e-e1b93abf8f05
horizontal_tail = WingSection(
    area        = 9.03,  		    # Area (m²). 
	aspect      = 4.97,  		    # Aspect ratio
	taper       = 0.6,  		    # Taper ratio  				GUESS
	dihedral    = 6,   		    	# Dihedral angle (deg)      GUESS
    sweep       = 10,  		    	# Sweep angle (deg)         GUESS
    w_sweep     = 0,   		        # Leading-edge sweep        GUESS
    root_foil   = naca4(0,0,1,2), 	# Root airfoil              GUESS
	tip_foil    = naca4(0,0,1,2), 	# Tip airfoil               GUESS
    symmetry    = true,
    angle       = 0, 
    position    = vertical_tail.affine.translation + [ 2.8, 0., span(vertical_tail)-0.6],
); 

# ╔═╡ 38796500-1622-4752-bfab-8d6cf5a354a1
md"## Plotting Tools"

# ╔═╡ 12f1fe83-a74d-48dd-9297-a5b65e544b17
md"### Meshing"

# ╔═╡ d280891b-cd5f-4102-9c68-488086338100
begin
	wing_mesh = WingMesh(wing, [8,16], 10, span_spacing = Uniform());
	vertical_tail_mesh = WingMesh(vertical_tail, [8], 6);
	horizontal_tail_mesh = WingMesh(horizontal_tail, [10], 8);
end;

# ╔═╡ a83be408-a3a7-4873-9dcb-c28bf659103d
md"### Plotting Parameters"

# ╔═╡ 14a931bf-0874-4951-8efb-2cb58b401a6f
begin
	φ_s 			= @bind φ Slider(-180:1e-2:180, default = 45)
	ψ_s 			= @bind ψ Slider(-180:1e-2:180, default = -45)
end;

# ╔═╡ fa313733-6c89-4927-96a1-3ce4ce7ca619
toggles = md"""
φ: $(φ_s)
ψ: $(ψ_s)
"""

# ╔═╡ 4bfa9f17-1921-4389-9db4-b11337bf5422
begin
	φ_s1 			= @bind φ1 Slider(-180:1e-2:180, default = 45)
	ψ_s1 			= @bind ψ1 Slider(-180:1e-2:180, default = -45)
end;

# ╔═╡ 0ad3b910-4e95-4af7-adc1-4903fbb2f50c
toggles1 = md"""
φ: $(φ_s1)
ψ: $(ψ_s1)
"""

# ╔═╡ 8995a33e-c807-4cb5-8a20-1966354b63ac
begin
    p2 = plot(
        xaxis="x", yaxis="y", zaxis="z",
        zlim=(-10,15),
        xlim=(-1,24),
        ylim=(-12.5,12.5),
        camera=(φ1, ψ1),
        grid=false
    )
	plot!(p2,wing_mesh, label = false, mac = false)
	
    plot!(p2, horizontal_tail_mesh, label =false, mac = false)
	plot!(p2, vertical_tail_mesh, label = false, mac = false)

	


	edges2 = plotvolume(7, 10, z_start, z_end; width=radius*1.5, λ=FACTOR)
for (ex, ey, ez) in edges2
    plot!(p2, ex, ey, ez, color=:purple, label=false, lw=2)
end


	plot!(p2, fuselage, label=false, color=:blue)



# Cylinder
cyl_edges = plotvolume(4.0, 5.0, 0, -radius; radius=radius, λ=0.75)
for (ex, ey, ez) in cyl_edges
    plot!(p2, ex, ey, ez, color=:pink, label=false, lw=2)
end

	
    p2
end

# ╔═╡ c971cecf-cd62-48d9-8bbd-2cadf0370c3e
begin
	# Plot meshes
	plot_aircraft = plot(
	    # aspect_ratio = 1,
	    xaxis = "x", yaxis = "y", zaxis = "z",
	    zlim = (-10,15),#(-0.5, 0.5) .* span(wing_mesh),
		xlim = (-1,24),
		ylim = (-12.5,12.5),
	    camera = (φ, ψ),
		grid = false,
		legend = false 
	)	
end;

# ╔═╡ 39cc20cc-847f-4dcb-b406-10a5c48fc86c
begin
	plot!(plot_aircraft, horizontal_tail_mesh, label =false, mac = false)
	plot!(plot_aircraft, vertical_tail_mesh, label = false, mac = false)
	plot!(plot_aircraft, fuselage, label = false)
	plot!(plot_aircraft,wing_mesh, label = false, mac = false)
end

# ╔═╡ Cell order:
# ╟─9f9a3b00-41bf-11f1-ac40-07b0b6a03969
# ╟─25dc3b01-2407-4d9f-8904-0a21dc206f3c
# ╠═75abc55d-ccf6-428f-9b3b-5e4951d7e939
# ╟─5b191cad-d14b-4903-bbcf-279a36cf7675
# ╠═39cc20cc-847f-4dcb-b406-10a5c48fc86c
# ╟─fa313733-6c89-4927-96a1-3ce4ce7ca619
# ╟─ac6a2903-0360-4f82-b731-a17e036bba6f
# ╟─6ae6b68f-5e22-4f0b-b7fe-f8d5da5a2345
# ╟─7817aeca-96e9-4aa1-a62a-bea96be88186
# ╠═064dac79-29e1-4540-8222-f14ef8085b4d
# ╠═136fbc95-5389-48f9-a419-332dd4342743
# ╟─0ad3b910-4e95-4af7-adc1-4903fbb2f50c
# ╠═8995a33e-c807-4cb5-8a20-1966354b63ac
# ╟─25c56bbc-6b88-44ed-9caa-bb75635e2ee6
# ╟─d5ef65c0-4864-44bc-a071-2c00b1ace4ac
# ╠═df74c6ff-9953-41fc-821e-e94d191f8740
# ╠═9b6b3d47-dcc4-4b5a-95bb-80d83ac39c53
# ╟─ea40783c-1343-4074-9fa1-709b16edd39f
# ╠═3fddb990-d053-41cc-8f26-078e1d9ff464
# ╠═a42a4353-f027-439f-a0d5-b527a1803706
# ╟─e1116ab3-1242-4860-bcd0-779c6f80c976
# ╠═a96a61ed-b63e-4b6f-bcab-702d5780b5ee
# ╟─9a2b50f8-37c6-4a09-b7dc-52d7bfbf32d5
# ╠═8b45c0e3-1205-460d-850e-e1b93abf8f05
# ╟─38796500-1622-4752-bfab-8d6cf5a354a1
# ╟─12f1fe83-a74d-48dd-9297-a5b65e544b17
# ╠═d280891b-cd5f-4102-9c68-488086338100
# ╟─a83be408-a3a7-4873-9dcb-c28bf659103d
# ╠═14a931bf-0874-4951-8efb-2cb58b401a6f
# ╠═4bfa9f17-1921-4389-9db4-b11337bf5422
# ╠═c971cecf-cd62-48d9-8bbd-2cadf0370c3e
