#to compute the drag force
#later add a section for the propeller efficiency modelling!

#inputs e, AR, Cd0, W(weight at the given flight phase), g (gravity), q (dynamic pressure defined), S, ρ
function atmosphere(altitude)
    #ISA model
    if altitude < 11000.0
        T = 288.15 - 0.0065 * altitude  # Temperature in K
        P = 101325.0 * (T / 288.15) ^ 5.2561  # Pressure in Pa
    elseif altitude < 20000.0
        T = 216.65  # Temperature in K
        P = 22632.06 * exp(-0.0001577 * (altitude - 11000.0))  # Pressure in Pa
    else
        T = 216.65 + 0.001 * (altitude - 20000.0)  # Temperature in K
        P = 5474.89 * (T / 216.65) ^ -34.1632  # Pressure in Pa
    end
    ρ = P / (287.05 * T)  # Density in kg/m³
    return T, P, ρ
end

function dragforce(e, AR, Cd0, W, g, q, S, ρ, V)
    K=1/(π*e*AR)
    Cl=W*g/(q*S)
    Cd  = Cd0 + K*Cl^2; #drag coefficient
    D=0.5*ρ*V^2*S*Cd #drag force
    return D
end