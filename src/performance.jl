# Parameters
#From Aircraft struct 
#NOTE THESE ARE KG IN STRUCTS! so convert to N
# W_empty: Aircraft empty weight N 
# W_payload: Aircraft payload weight N

#From Propulsion Struct
# e_batt: Battery energy density Wh/kg converted to J in function
# η_em: Electric motor efficiency
# η_eg: Electric generator efficiency
# η_gt: Gas turbine efficiency
# η_p: Propulsive efficiency from BEMT
# η_gb: Gearbox efficiency
# e_f: Energy density of aviation fuel Wh/kg converted to J in function

# E_0total: Total input energy J
# LD: Lift-to-drag ratio
# g: Acceleration due to gravity m/s²
# ϕ: Hybridization ratio

#parameter sweep: ϕ, LD, e_batt, W_empty , W_payload


function Range_parallel(Aircraft, Propulsion, E_0total, ϕ, LD, g; e_batt_Whkg = Propulsion.specificenergy, W_empty_override = nothing, W_payload_override = nothing)
    # allow sweeping weights without rebuilding structs
    W_empty   = isnothing(W_empty_override)   ? Aircraft.W_empty   : W_empty_override
    W_payload = isnothing(W_payload_override) ? Aircraft.W_payload : W_payload_override

    W_empty   *= g
    W_payload *= g
    
    η_em= Propulsion.η_motor
    η_p =Propulsion.η_propulsive_efficiency
    η_gt= Propulsion.η_gas_turbine_efficiency
    η_gb = Propulsion.η_gearbox_efficiency
    e_f = Propulsion.energy_density_fuel * 3600.0 #in J
    e_batt = e_batt_Whkg*3600 #Wh/kg to J/kg
    numerator   = W_empty + W_payload + (E_0total *g /e_batt)*( ϕ/η_em + (e_batt*(1-ϕ))/(e_f*η_gt) )
    denominator = W_empty + W_payload + (g*ϕ*E_0total)/(e_batt*η_em)
    Range = η_gt * η_gb * η_p * (LD)  *  (1 + ϕ/(1-ϕ) )* (e_f/g) * log( numerator/denominator)
    return Range #in metres
end


function Range_series(Aircraft, Propulsion, E_0total, ϕ, LD, g; e_batt_Whkg = Propulsion.specificenergy, W_empty_override = nothing, W_payload_override = nothing)
    # allow sweeping weights without rebuilding structs
    W_empty   = isnothing(W_empty_override)   ? Aircraft.W_empty   : W_empty_override
    W_payload = isnothing(W_payload_override) ? Aircraft.W_payload : W_payload_override

    W_empty   *= g
    W_payload *= g
    η_em= Propulsion.η_motor
    η_p =Propulsion.η_propulsive_efficiency
    η_gt= Propulsion.η_gas_turbine_efficiency
    η_gb = Propulsion.η_gearbox_efficiency
    η_eg = Propulsion.η_electric_generator_efficiency
    e_f = Propulsion.energy_density_fuel * 3600.0 #in J
    e_batt = e_batt_Whkg*3600 #Wh/kg to J/kg
     numerator   = W_empty + W_payload + (E_0total *g /e_batt)*( ϕ + (e_batt*(1-ϕ))/(e_f*η_gt*η_eg) )
     denominator = W_empty + W_payload + (g*ϕ*E_0total)/(e_batt)
     Range = η_gt * η_eg *η_em * η_gb * η_p * (LD)  *  (1 + ϕ/(1-ϕ) )* (e_f/g) * log( numerator/denominator)
     return Range
 end

function weight_iteration(A, C, W_payload, Wf_W0, W0_guess)
		iterations = Int[]
		weights = Float64[]
		NumIterations=0
		tol=1e-3
		while true
			We_W0=A*(W0_guess* 2.205)^(C) #need to convert to lbs for this correlation
			den = 1 - Wf_W0 - We_W0
	        if den <= 0
	            error("Invalid weight fractions")
				break
	        end
			W0=W_payload / den
			NumIterations+=1
			push!(iterations, NumIterations)
	    	push!(weights, W0)
			if abs(W0_guess - W0) < tol || NumIterations>=100
				break
			end
			W0_guess=W0
		end
		return W0_guess, weights, iterations
end



function PayloadRange(Aircraft, Propulsion, g, L_D_cruise; W_batt=0, cp_cruise=0.0, sfc_cruise=0.0, W_PGD=0.0)
	W_payload=Aircraft.W_payload
	W0=Aircraft.MTOW
	We=Aircraft.W_empty + W_batt + W_PGD
	W_fuel_max=Aircraft.maxfuelweight

	if cp_cruise < 0.0 || sfc_cruise < 0.0
		println("Error: cp_cruise and sfc_cruise must be positive.")
		return nothing
	elseif cp_cruise >0.0
		η_p=Propulsion.η_propulsive_efficiency 
    	range_factor = (η_p / (cp_cruise * g)) * L_D_cruise
	elseif sfc_cruise>0.0
		cp_cruise = sfc_cruise / 3.6e6   # kg/J
		range_factor = L_D_cruise / (cp_cruise * g)
	end
	

    # POINT A: max payload, no fuel
    R_A = 0.0
    Wpl_A = W_payload

    # POINT B: max payload, fuel limited by MTOW and fuel tank capacity
    Wpl_B = W_payload

    Wf_B = min(W_fuel_max, W0 - We - Wpl_B)
    

    Wf_B = max(Wf_B, 0.0)

    WB_i = We + Wpl_B + Wf_B
    WB_f = We + Wpl_B

    R_B = range_factor * log(WB_i / WB_f) / 1000

    # POINT C: max fuel, payload reduced if needed
    Wf_C = min(W_fuel_max, W0 - We)
    Wpl_C = W0 - We - Wf_C

    Wpl_C = max(Wpl_C, 0.0)
    Wpl_C = min(Wpl_C, W_payload)

    WC_i = We + Wpl_C + Wf_C
    WC_f = We + Wpl_C

    R_C = range_factor * log(WC_i / WC_f) / 1000

    # POINT D: zero payload, max fuel / ferry range
    Wpl_D = 0.0
    Wf_D = min(W_fuel_max, W0 - We)

    WD_i = We + Wf_D
    WD_f = We

    R_D = range_factor * log(WD_i / WD_f) / 1000

    ranges_pts = [R_A, R_B, R_C, R_D]
    payloads_pts = [Wpl_A, Wpl_B, Wpl_C, Wpl_D]

    return (ranges=ranges_pts, payloads=payloads_pts)

end


function P_W(W_S, α, β, Segment, Propulsion, Aircraft; constraint="empty", altitude=0)
		CD_0=Aircraft.Cd0
		AR=Aircraft.AR
		e=Aircraft.e
		V = Segment.V
    	ρ = Segment.ρ
		η_p = Propulsion.η_propulsive_efficiency 
		ROC=Segment.ROC
		G=ROC/V
		dV_dt=Segment.dVdt
	    CL = α .* W_S ./ (0.5 * ρ * V^2)
		
		if constraint == "empty"
			if Segment.name=="Cruise"
				P_W = (V * α)/(η_p * β) .* (CD_0 ./ (α .* CL) .+ (α .* CL)./(π * AR * e));
			elseif Segment.name == "Climb"
				P_W = (V * α)/(η_p * β) .* (G .+ CD_0 ./ (α .* CL) .+ (α .* CL)./(π * AR * e));
			else
				P_W = (V/η_p).*(α/β) .* ( G .+ (1/g)*dV_dt .+ (0.5 .* ρ .* V^2 .* CD_0) ./ (α .* W_S) .+ (n^2 .* W_S) ./ (0.5 .* ρ .* V^2 .* π .* AR .* e) )
			end
		end

		if constraint == "Ceiling"
			-,-,ρ_ceiling=atmosphere(altitude)
			σ_ceil = ρ_ceiling / 1.225
			P_W = (α/β) * (2/η_p) * sqrt(CD_0/(π*AR*e)) / σ_ceil^0.7
			
		end
		
		return P_W
	    
		
end


function payloadvolume(x_start, x_end, z_start, z_end; width= -1.0 ,radius=-1.0, λ=-1)
	#assuming symmetrical
	#assume reduction in volume is proportional to reduction in mass?
	#assume reduction in volume takes place along the length!!!
	
	#VAIDATION
	if λ < 0.0 || λ > 1.0
		println("Error: λ must be between 0 and 1.")
		return nothing
	end

	if width < 0.0 && radius < 0.0
        println("Error: width or radius must be provided.")
        return nothing
    end

	if width > 0.0 && radius > 0.0
        println("Error: both width and radius are defined.")
        return nothing
    end

	len = (x_end - x_start)*(1-λ)
	height = abs(z_end - z_start)
	new_x_end=x_end*(1-λ)
		

	if width>=0.0
		volume = len*height*width
		return volume, new_x_end
	end
	if radius >=0.0 
		# Clamp height to valid range [0, 2*radius]
	    height = clamp(height, 0, 2 * radius)
		
		if height >= radius*2
		        # Full circle
		        area = π * radius^2
		    else
		        # Circular segment:
		        # θ is the half-angle subtended at the centre by the chord at depth (radius - height)
		        t = radius - height
		        θ = acos(t / radius)           # half-angle in radians
		        area = radius^2 * (θ - sin(θ) * cos(θ))
		    end
		
		    volume = area * len
		return volume, new_x_end
	end
	
end

function plotvolume(x_start, x_end, z_start, z_end; width= -1.0 ,radius=-1.0, λ=-1.0)

	#VAIDATION
	if λ < 0.0 || λ > 1.0
		println("Error: λ must be between 0 and 1.")
		return nothing
	end

	if width < 0.0 && radius < 0.0
        println("Error: width or radius must be provided.")
        return nothing
    end

	if width > 0.0 && radius > 0.0
        println("Error: both width and radius are defined.")
        return nothing
    end

	len = (x_end - x_start)*(1-λ)
	
		

	if width >= 0.0 
		#rectanglular
		x0, x1 = x_start, x_start + len
		y0, y1 = -width/2, width/2
		z0, z1 = z_start, z_end

		edges = [
			# bottom face
			([x0,x1],[y0,y0],[z0,z0]),
			([x0,x1],[y1,y1],[z0,z0]),
			([x0,x0],[y0,y1],[z0,z0]),
			([x1,x1],[y0,y1],[z0,z0]),
			# top face
			([x0,x1],[y0,y0],[z1,z1]),
			([x0,x1],[y1,y1],[z1,z1]),
			([x0,x0],[y0,y1],[z1,z1]),
			([x1,x1],[y0,y1],[z1,z1]),
			# verticals
			([x0,x0],[y0,y0],[z0,z1]),
			([x1,x1],[y0,y0],[z0,z1]),
			([x0,x0],[y1,y1],[z0,z1]),
			([x1,x1],[y1,y1],[z0,z1]),
		]

		return edges
	end
	
	if radius >=0.0 
		# Parametric cylinder surface

		θ_start = asin(z_start / radius)
		θ = range(-π - θ_start, 0 + θ_start, length=50)
		y_edge = sqrt(radius^2 - z_start^2)
		x0, x1 = x_start, x_start + len

        edges = []

        # Arc rings at each end
        for xi in [x0, x1]
            ys_ring = [radius * cos(θi) for θi in θ]
            zs_ring = [radius * sin(θi) for θi in θ]
            push!(edges, (fill(xi, length(θ)), ys_ring, zs_ring))
        end

        # Flat top edge closing the semicircle at each end
        for xi in [x0, x1]
            push!(edges, ([xi, xi], [-y_edge, y_edge], [z_start, z_start]))
        end

        # Longitudinal lines along the length
        n_lines = 8
        for θi in range(-π - θ_start, 0 + θ_start, length=n_lines)
            yi = radius * cos(θi)
            zi = radius * sin(θi)
            push!(edges, ([x0, x1], [yi, yi], [zi, zi]))
        end
	    return edges
	end

end