#Blade Element Momentum Theory
#gives Thrust T, Torque Q, Power P, and efficiency η for each propeller

#INPUTS-------------------------------------------------------------------
#Blade geometry 
R         = 0.75; #radius  (m)
r_hub     = 0.15; #hub radius (m)
Nb        = 3; #Number of blades
chordroot = 0.1;
chordtip  = 0.055;
twist_deg_root=13;
twist_deg_tip=5;
V∞      = 70;    #freestream velocity (m/s)
Ω       = 1800;  #RPM
ν       = 1.5e-5;#kinematic viscosity for Re (m^2/s)
ρ       = 1.225;
#--------------------------------------------------------------------------

function BEMT(R, r_hub, Nb, chordroot, chordtip, twist_deg_root, twist_deg_tip,V∞,Ω, ν, ρ)
    include("airfoildata.jl")  #Airfoil Data

    #solver parameters
    maxiter = 400;   #maximum number of iterations
    tol     = 1e-6;
    relax   = 0.5;   #relaxation factor damps the update, preventing oscillation
    N       = 30;    #discretisation

    ω       = Ω*2*pi/60; # angular velocity
    r       = range(r_hub, R, length=N);
    dr_uniform = (R - r_hub) / (N-1);
    dr      = fill(dr_uniform, N) ;  

    c       = LinRange(chordroot, chordtip, N)  ;  #linear chord distribution
    θ       = deg2rad.(LinRange(twist_deg_root,twist_deg_tip,N)); #linear twist distribution



    #INITIAL GUESS FOR INDUCED VELOCITY
    #guess initial axial induction factor ai=0.1 for each section
    a       = fill(0.1,N); #axial induction
    ap      = zeros(N)  ;  #tangential induction
    dT      = zeros(N);
    dQ      = zeros(N);

    function prandtl_F(Nb, R, ri, φ)
        sphi = sin(φ)
        # if sphi is very small, avoid division by zero and set F≈1 (no tip loss)
        if abs(sphi) < 1e-8
            return 1.0
        end
        f = (Nb/2.0) * (R - ri) / (ri * sphi)
        ex = exp(-f)
        ex = clamp(ex, 0.0, 1.0)
        F = (2.0/π) * acos(ex)
        # ensure F is not exactly zero (prevents denom blow up)
        return max(F, 1e-6)
    end

    for i in 1:N
        #summation of N, index i
        ri= r[i]; ci = c[i]; θi= θ[i] ;#in radians
        a[i]  = 0.1;
        ap[i] = 0.0;

        for iter in 1:maxiter
            #compute local velocities
            Ut     = ω*ri*(1+ap[i]) ;#tangential velocity
            Uax    = V∞*(1-a[i]);    #axial vwlocity
            Ut = abs(Ut) < 1e-12 ? 1e-12 : Ut
            Uax = abs(Uax) < 1e-12 ? 1e-12 : Uax


            Urel   = sqrt( (Ut)^2 + (Uax)^2 );

            #compute local inflow angle
            φ         = atan(Uax,Ut);
            α         = rad2deg(θi-φ); #degrees


            #interpolate airfoil Data
            clcd=calculateclcd(α); 
            Cl=clcd.CL; Cd=clcd.CD;

            #forces
            Fa        = Cl*cos(φ) - Cd*sin(φ) ;#axial
            Ft        = Cl*sin(φ) + Cd*cos(φ); #tangential
            
            F = prandtl_F(Nb, R, ri, φ) #prantl meyer correction

            #solidity
            σ         = Nb*ci/(2*pi*ri);


            # fixed-point updates (explicit)
            denom_a   = 4*F*(sin(φ)^2) + σ*Fa;
            denom_ap  = 4*F*sin(φ)*cos(φ) - σ*Ft;
            a_new  = abs(denom_a)  < 1e-12 ? a[i]  : (σ * Fa) / denom_a
            ap_new = abs(denom_ap) < 1e-12 ? ap[i] : (σ * Ft)  / denom_ap
            # relaxation
            a_next = clamp((1-relax)*a[i] + relax*a_new, -0.2, 0.95);
            ap_next = clamp((1-relax)*ap[i] + relax*ap_new, -0.5, 0.5);



            # convergence check
            if max(abs(a_next - a[i]), abs(ap_next - ap[i])) < tol
                a[i] = a_next; ap[i] = ap_next;
                break
            end

            # update and continue
            a[i] = a_next; ap[i] = ap_next;
        end

        #after convergence compute element forces with final a,ap
        Uax      = V∞ * (1 - a[i]);
        Ut      = ω * ri * (1 + ap[i]);
        Urel    = sqrt(Uax^2 + Ut^2);
        φ       = atan(Uax,Ut);
        α       = rad2deg(θi - φ);
        println(α)
        clcd = calculateclcd(α); Cl = clcd.CL; Cd = clcd.CD;
        
        Fa      = Cl*cos(φ) - Cd*sin(φ);
        Ft      = Cl*sin(φ) + Cd*cos(φ);

        dT[i]   = 0.5*Nb*ρ* (Urel^2) * ci * Fa * dr[i];
        dQ[i]   = 0.5*Nb*ρ* (Urel^2) * ci * Ft * ri * dr[i];



    end
    #repeat until convergence

    #OUTPUT RESULTS
    T       = sum(dT)         #Thrust per propeller!!!
    Q       = sum(dQ)         #Torque
    P       = Q * ω           #Power
    Efficiency      = T*V∞/P          #efficiency 
    Advanceratio       = V∞/((Ω/60)*2*R) #advance ratio
    return (T=T, Q=Q, P=P, η=Efficiency, J=Advanceratio)
end

BEMT(R, r_hub, Nb, chordroot, chordtip, twist_deg_root, twist_deg_tip,V∞,Ω, ν, ρ)
using Plots
plot(r,dT)
#plot(r,dQ)
