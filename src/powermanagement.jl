#power management
#how much energy comes from the battery vs generator
#input Ptotal, SOC-state of charge (0-1), phase
#output P1, P2, ϕ - powersplit

#define P1 as primary powersource
#define P2 as secondary powersource i.e electric motor
#latercould vary for distributed propulsion sources?

#adjust ϕ and χ at different flight phases based on SOC, power demand etc

function powerdistrubution(ϕ,Pmax)
    P2=ϕ*Pmax
    P1=Pmax-P2
    return (P1=P1, P2=P2)
end


function powerdistribution_dynamic(Ptotal, SOC, flightphase)
    ϕbase = Dict(
        :takeoff => 0.6,   # 60% battery, 40% engine
        :climb   => 0.4,
        :cruise  => 0.2,
        :descent => 0.1,
        :landing => 0.3
    )[flightphase]

    #batteries are only operable from 20% to 80% SoC
    ϕeff = ϕbase * clamp(SOC / 0.8, 0.0, 1.0) #as the state of charge decreases, the contribution from the battery decreases. clamp keeps it between 0 and 1

    P2 = ϕeff * Ptotal
    P1 = Ptotal - P2

    return (P2=P2, P1=P1, ϕ=ϕeff)
end


#P_total = 50000.0   # 50 kW demand
#SOC = 0.7
#phase = :climb


#serial or parallel?

#use this framework for distributed propulsion !
#function thrustdistribution(χ,T) #T is total thrust requirement
 #   T2=χ *T
  #  T1=Pmax-P2
   # return (P1=P1, P2=P2)
#end

