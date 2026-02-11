### A Pluto.jl notebook ###
# v0.20.19

using Markdown
using InteractiveUtils

# ╔═╡ a7c0b5c4-b127-4783-beba-cc20e43c4c0f
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

# ╔═╡ a8934270-fbb9-11f0-bb4a-bf856ac781c2
md"# Range Evaluation"

# ╔═╡ d443e909-a9bb-4088-b23e-ff486e328207
md"
This demonstration investigates the Range equation module for Hybrid Electric Aircraft.

The inputs of the function are descibed in the table below. $W_{empty}$ and $W_{payload}$ are from the Aircraft struct. They are defined in kilograms, and are converted to Newtons as compatible with the range equations.

The following are from the Propulsion struct: $e_{batt}$, $η_{em}$, $η_{eg}$, $η_{gt}$, $η_{p}$, $η_{gb}$ and $e_{f}$. $e_{batt}$ and $e_{f}$ are defined in Wh/kg, and are converted to Joules as compatible with the range equations.


| Input 		| Name 						 	  | Units 		|
| ---- 			| ----- 					 	  | ----- 		|
| W_empty     | Aircraft empty weight   		  | kg --> N    |
| W_payload   | Aircraft payload weight 	      | kg --> N	|
| e_batt   	| Battery energy density 		  | Wh/kg --> J |
| η_em  	    | Electric motor efficiency  	  |  	        |
| η_eg  	    | Electric generator efficiency   |  	        |
| η_gt    	| Gas turbine efficiency 		  |  	        |
| η_p 	  	| Propulsive efficiency 		  |  	        |
| η_gb    	| Gearbox efficiency			  |  	        |
| e_f 	   	| Energy density of aviation fuel | Wh/kg --> J |
| E_0total	| Total input energy  			  | J 	        |
| L/D           | Lift-to-drag ratio 			  |  	        |
| g	   	        | Acceleration due to gravity  	  | m/s² 	    |
| ϕ   	        | Hybridization ratio	 		  |  	        |

"

# ╔═╡ a4231e2a-c03d-4e25-b95e-faf87973b954
md"**Define Packages**"

# ╔═╡ 4e31f1ea-8218-4a15-928f-70f6558d8be5
md"### Parallel Hybrid-Electric Aircraft"

# ╔═╡ 9a5daa27-1e0c-434f-be82-5ec3e3bf65b3
md"
$Range = η_{gt} η_{gb} η_{p} \left(\frac{L}{D}\right) \left(1 + \frac{𝛗}{1-𝛗}\right) \left(\frac{e_{f}}{g}\right) \log \left(\frac{ W_{OE} + W_{PL} + (\frac{ E_{0,tot}g }{e_{bat}})  ( \frac{𝛗}{ η_{em} }  +  \frac{ e_{bat}(1-𝛗)  }{ e_{f} η_{gt} }   )  }{   W_{OE}   +W_{PL}   +  \frac{g}{ e_{bat}  } \frac{ 𝛗 E_{0,tot}   }{ η_{em}  }    } \right)$
"

# ╔═╡ 7fae75a6-d21b-4b4d-b4a0-6526047faadc
md"### Series Hybrid-Electric Aircraft"

# ╔═╡ d9e0f2da-26a1-4f03-a1a4-1a1006cdf62d
md"
$Range = η_{gt} η_{eg} η_{em} η_{gb} η_{p} \left(\frac{L}{D}\right) \left(1 + \frac{𝛗}{1-𝛗}\right) \left(\frac{e_{f}}{g}\right) \log \left(\frac{ W_{OE} + W_{PL} + (\frac{ E_{0,tot}g }{e_{bat}})  ( 𝛗  +  \frac{ e_{bat}(1-𝛗)  }{ e_{f} η_{gt} η_{eg} }   )  }{   W_{OE}   +W_{PL}   +  \frac{g 𝛗 E_{0,tot}}{ e_{bat}  }   } \right)$


"

# ╔═╡ 39079456-eacf-41b3-894a-8588d0051393
md"## Case Study/ Validation Checks"

# ╔═╡ c0d0cf86-1af4-4c16-a9ef-8f270c5b3439
md"
The following are the variables used in the paper.

| Variable  					  		  | Value 	    |
| ---- 							  		  | ----- 		| 
| Aircraft empty weight [N]		  		  |50,000             |
| Aircraft payload weight [N]	      	  |20,000         	|
| Electric motor efficiency  	  		  | 0.95 	        |
| Electric generator efficiency   		  |  0.98	        |
| Gas turbine efficiency 		  		  | 0.35 	        |
| Propulsive efficiency 		  		  | 0.8 	        |
| Gearbox efficiency			  		  |  0.95	        |
| Energy density of aviation fuel [Wh/kg] | 11,900			|
| Total input energy [G]  			  	  | 25	        |
| Lift-to-drag ratio 			  		  | 12 	        |
| Acceleration due to gravity [m/s²] 	  | 9.81 			|

"

# ╔═╡ 28a0be2f-3b76-4485-bd44-cae39c77cbd9
md"**Defining the Input parameters**"

# ╔═╡ 93f0877e-6e48-4c6f-817b-2cbd354df71d
	md"0.0 is used for parameters which are not used in this example"



# ╔═╡ 81a34601-5dc4-4287-bef2-aaf7d36405a0
	aircraft = Aircraft(0.0, 20000/9.81 , 50000/9.81, 0.0, 0.0, 0.0, 0.0)
	

# ╔═╡ 40fde0c9-5cde-43b5-8cda-9b9db2a7e4c5
propulsion = Propulsion(0.95, 0.0, 0.0, 400, 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 11900, 0.35, 0.95, 0.8, 0.98)

# ╔═╡ 25e053e9-6109-45fa-b41c-8659f2b863d4
md"
In the paper for a parallel configuration: a battery energy density of 400 Wh/kg and a hybridization factor of 0.3 gives a Range of 1761.7km. For a series configuration: a battery energy density of 400 Wh/kg and a hybridization factor of 0.3 gives a Range of 1707.6km.
"

# ╔═╡ c157e2cb-d1c7-42ed-9835-920e398a4a6e
begin
	E_0total =25*10^9
	ϕ =0.3
	LD =12
	g =9.81
	specificenergy= 400
end;

# ╔═╡ fd06f744-8090-4dd3-8376-34f77fc93585
rangeparallel=Range_parallel(aircraft, propulsion, E_0total, ϕ, LD, g; e_batt_Whkg = specificenergy)/1000

# ╔═╡ 1dda2d04-b15b-4060-9966-06daf7ce5741
rangeseries=Range_series(aircraft, propulsion, E_0total, ϕ, LD, g; e_batt_Whkg = specificenergy)/1000

# ╔═╡ ac54cd37-412e-4fde-81d5-c3710cd693aa
md"The paper states that the range equation for parallel configuration yields a higher range, thus this will be explored in the further studies."

# ╔═╡ 78bb9794-de74-470b-8805-31736e392ad7


# ╔═╡ 9d86e652-7561-4b93-adda-12e0e6e9f28f
md"## Parameter Sweep"

# ╔═╡ fb4a24f2-c7eb-44eb-bb3f-c13fe5c9a2e3
md"
The effects of the following parameters on the aircraft's Range will be investigated
* Hybridization ratio
* Battery specific energy
"

# ╔═╡ 0ab6745a-ac85-4abc-8d53-d2d29c020abd
begin
    H = Base.range(0.0, 0.99, length=121)
    battspecificenergy = 400

    RkmH_parallel = zeros(length(H))
	RkmH_series = zeros(length(H))
	
    for i = 1:length(H)
        RkmH_parallel[i] = Range_parallel(aircraft, propulsion, E_0total, H[i], LD, g; e_batt_Whkg=battspecificenergy) / 1000
		RkmH_series[i] = Range_series(aircraft, propulsion, E_0total, H[i], LD, g;
                                       e_batt_Whkg=battspecificenergy) / 1000
    end

    p1 = plot(H, RkmH_parallel; label="Parallel")
    plot!(p1, H, RkmH_series; label="Series")
	xlabel!("Hybridization ratio Φ ")
	ylabel!("Range (km)")
end


# ╔═╡ ce3a1075-f463-44e0-ac57-407adb6ce495
begin
    H1=0.3 #H = Base.range(0.0, 0.99, length=121)
    battspecificenergy1 = Base.range(0.0, 2500, length=121)

    RkmE_parallel = zeros(length(battspecificenergy1))
	RkmE_series = zeros(length(battspecificenergy1))

    for i = 1:length(battspecificenergy1)
        RkmE_parallel[i] = Range_parallel(aircraft, propulsion, E_0total, H1, LD, g;
                                       e_batt_Whkg=battspecificenergy1[i]) / 1000
		RkmE_series[i] = Range_series(aircraft, propulsion, E_0total, H1, LD, g;
                                       e_batt_Whkg=battspecificenergy1[i]) / 1000
    end

    p2 = plot(battspecificenergy1, RkmE_parallel; label="Parallel")
    plot!(p2, battspecificenergy1, RkmE_series; label="Series")
	xlabel!("Battery Specific Energy Wh/kg ")
	ylabel!("Range (km)")
end

# ╔═╡ 08a76f39-ac8f-4cb5-85ee-63aaa11da383
begin
    phi  = Base.range(0.0, 0.99, length=121)       
    batsp = Base.range(50.0, 10000.0, length=121)      

    Rkm = zeros(length(batsp), length(phi))

    for i = 1:length(batsp)
        for j = 1:length(phi)
            Rkm[i, j] = Range_parallel(aircraft, propulsion, E_0total, phi[j], LD, 							g; e_batt_Whkg=batsp[i]) / 1000
        end
    end

	levels_fine   = collect(0:10:3500)        # smooth shading
	levels_labels = collect(2500:30:3500)    # ONLY these get labels


    levels = collect(0:10:3500)
    Z = clamp.(Rkm, 200.0, 3500.0)

    p_main = contourf(phi, batsp, Z;
        levels=levels_fine,
        color=:plasma,
        xlabel="Hybridization ratio Φ ",
        ylabel="Battery specific energy (Wh/kg)",
        xlims=(0,1), ylims=(0,10000),
    )

    contour!(p_main, phi, batsp, Z;
        levels=levels_labels,
        color=:black,
		linewidth =1.2,
        clabels=true,
	    colorbar_title = "Range (km)",
    )

end


# ╔═╡ 0d67397c-77c1-495c-bd6d-fe545b9b70e4
begin
	levels_fine2   = collect(0:75:3500)        # smooth shading
	levels_labels2 = collect(0:100:3500)    # ONLY these get labels

    p_main2 = contourf(phi, batsp, Z;
        levels=levels_fine2,
        color=:plasma,
        xlabel="Hybridization ratio Φ ",
        ylabel="Battery specific energy (Wh/kg)",
        xlims=(0,1), ylims=(0,1000),
    )

    contour!(p_main2, phi, batsp, Z;
        levels=levels_labels2,
        color=:black,
		linewidth =1.2,
        clabels=true,
	    colorbar_title = "Range (km)",
    )
end

# ╔═╡ Cell order:
# ╟─a8934270-fbb9-11f0-bb4a-bf856ac781c2
# ╟─d443e909-a9bb-4088-b23e-ff486e328207
# ╟─a4231e2a-c03d-4e25-b95e-faf87973b954
# ╟─a7c0b5c4-b127-4783-beba-cc20e43c4c0f
# ╟─4e31f1ea-8218-4a15-928f-70f6558d8be5
# ╟─9a5daa27-1e0c-434f-be82-5ec3e3bf65b3
# ╟─7fae75a6-d21b-4b4d-b4a0-6526047faadc
# ╟─d9e0f2da-26a1-4f03-a1a4-1a1006cdf62d
# ╟─39079456-eacf-41b3-894a-8588d0051393
# ╟─c0d0cf86-1af4-4c16-a9ef-8f270c5b3439
# ╟─28a0be2f-3b76-4485-bd44-cae39c77cbd9
# ╟─93f0877e-6e48-4c6f-817b-2cbd354df71d
# ╟─81a34601-5dc4-4287-bef2-aaf7d36405a0
# ╟─40fde0c9-5cde-43b5-8cda-9b9db2a7e4c5
# ╟─25e053e9-6109-45fa-b41c-8659f2b863d4
# ╠═c157e2cb-d1c7-42ed-9835-920e398a4a6e
# ╠═fd06f744-8090-4dd3-8376-34f77fc93585
# ╠═1dda2d04-b15b-4060-9966-06daf7ce5741
# ╟─ac54cd37-412e-4fde-81d5-c3710cd693aa
# ╟─78bb9794-de74-470b-8805-31736e392ad7
# ╟─9d86e652-7561-4b93-adda-12e0e6e9f28f
# ╟─fb4a24f2-c7eb-44eb-bb3f-c13fe5c9a2e3
# ╟─0ab6745a-ac85-4abc-8d53-d2d29c020abd
# ╟─ce3a1075-f463-44e0-ac57-407adb6ce495
# ╟─08a76f39-ac8f-4cb5-85ee-63aaa11da383
# ╟─0d67397c-77c1-495c-bd6d-fe545b9b70e4
