#Blade Element Momentum Theory
#gives Thrust T, Torque Q, Power P, and efficiency η for each propeller
include("airfoildata.jl")  #Airfoil Data

function BEMT(R, r_hub, Nb, r_R, c_R, beta_table ,V∞,Ω, ρ)
   

    #solver parameters
    maxiter = 400;   #maximum number of iterations
    tol     = 1e-6;
    relax   = 0.3;   #relaxation factor damps the update, preventing oscillation
    N       = length(r_R);    #discretisation

    ω       = Ω*2*pi/60; # angular velocity
    r       = r_R.*R;

    dr      = zeros(N)  
    for i in 1:N
        if i == 1
            dr[i] = (r[i+1] - r[i])
        elseif i == N
            dr[i] = (r[i] - r[i-1])
        else
            dr[i] = (r[i+1] - r[i-1]) / 2
        end
    end

    c       = c_R.*R # chord distribution
    θ       = deg2rad.(beta_table) #twist distribution



    #INITIAL GUESS FOR INDUCED VELOCITY
    #guess initial axial induction factor ai=0.1 for each section
    a       = fill(0.0,N); #axial induction
    ap      = zeros(N)  ;  #tangential induction
    dT      = zeros(N);
    dQ      = zeros(N);

    function prandtl_F(Nb, R, r_hub, ri, φ)
        sphi = abs(sin(φ))
        if sphi < 1e-8
            return 1.0
        end
        
        # Tip loss
        f_tip = (Nb/2.0) * (R - ri) / (ri * sphi)
        f_tip = clamp(f_tip, -20, 20)  # prevent overflow
        F_tip = (2.0/π) * acos(clamp(exp(-f_tip), 0.0, 1.0))
        
        # Hub loss
        f_hub = (Nb/2.0) * (ri - r_hub) / (ri * sphi)
        f_hub = clamp(f_hub, -20, 20)
        F_hub = (2.0/π) * acos(clamp(exp(-f_hub), 0.0, 1.0))
        
        # Combined
        F = F_tip * F_hub
        return max(F, 1e-6)
    end 


    for i in 1:N
        #summation of N, index i
        ri= r[i]; ci = c[i]; θi= θ[i] ;#in radians
        a[i]  = 0.0;
        ap[i] = 0.0;

        for iter in 1:maxiter
            #compute local velocities
            Ut     = ω*ri*(1+ap[i]) ;#tangential velocity
            Uax    = V∞*(1-a[i]);    #axial velocity
            Ut = abs(Ut) < 1e-12 ? 1e-12 : Ut
            Uax = abs(Uax) < 1e-12 ? sign(Uax)*1e-12 : Uax


            Urel   = sqrt( (Ut)^2 + (Uax)^2 );

            #compute local inflow angle
            φ         = atan(Uax,Ut);
            α         = rad2deg(θi-φ); #degrees


            #interpolate airfoil Data
            clcd=calculateclcd(α); 
            Cl=clcd.CL; Cd=clcd.CD;

            #forces
            Cn        = Cl*cos(φ) + Cd*sin(φ) ;#normal force coefficient
            Ct        = Cl*sin(φ) - Cd*cos(φ); #tangential force coefficienct
            
            F = prandtl_F(Nb, R, r_hub, ri, φ)#prantl meyer correction

            #solidity
            σ         = Nb*ci/(2*pi*ri);


            # BEM equations for induction factors
            # Standard formulation
            if abs(sin(φ)) > 1e-6
                a_new = 1.0 / (4*F*sin(φ)^2/(σ*Cn) + 1);
            else
                a_new = a[i];
            end
            
            if abs(sin(φ)*cos(φ)) > 1e-6
                ap_new = 1.0 / (4*F*sin(φ)*cos(φ)/(σ*Ct) - 1);
            else
                ap_new = ap[i];
            end

         # Apply Glauert/Buhl correction for high induction
             if a_new > 0.4
                 ac = 0.2;
                 K = 4*F*sin(φ)^2 / (σ*Cn);
                 discriminant = (K*(1-2*ac)+2)^2 + 4*(K*ac^2 - 1);
                 if discriminant >= 0
                     a_new = 0.5*(2 + K*(1-2*ac) - sqrt(discriminant));
                 else
                     # If discriminant is negative, use momentum theory result clamped at 0.95
                     a_new = min(a_new, 0.95);
                 end
             end

            # Clamp values to physical bounds
            a_new = clamp(a_new, -0.5, 0.95);
            ap_new = clamp(ap_new, -1.0, 1.0);

            # relaxation
            a_next = (1-relax)*a[i] + relax*a_new;
            ap_next = (1-relax)*ap[i] + relax*ap_new;

            # convergence check
            if max(abs(a_next - a[i]), abs(ap_next - ap[i])) < tol
                a[i] = a_next; 
                ap[i] = ap_next;
                break
            end

            # update and continue
            a[i] = a_next; 
            ap[i] = ap_next;
        end

         

        #after convergence compute element forces with final a,ap
        Uax      = V∞ * (1 - a[i]);
        Ut      = ω * ri * (1 + ap[i]);
        Urel    = sqrt(Uax^2 + Ut^2);
        φ       = atan(Uax,Ut);
        α       = rad2deg(θi - φ);

        clcd = calculateclcd(α); Cl = clcd.CL; Cd = clcd.CD;
        
        Cn     = Cl*cos(φ) + Cd*sin(φ);
        Ct      = Cl*sin(φ) - Cd*cos(φ);

        dT[i]   = 0.5*ρ* (Urel^2) * ci * Cn * dr[i];
        dQ[i]   = 0.5*ρ* (Urel^2) * ci * Ct * ri * dr[i];


    end
    #repeat until convergence
    

    #OUTPUT RESULTS
    T       = sum(dT)*Nb         #Thrust per propeller!!!
    Q       = sum(dQ)  *Nb       #Torque
    P       = Q * ω           #Power
    η = (T*V∞)/P;       #efficiency 
    J       = V∞/((Ω/60)*2*R) #advance ratio
    return T, Q, P, η, J
end
