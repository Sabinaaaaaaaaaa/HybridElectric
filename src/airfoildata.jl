using DelimitedFiles
using Interpolations


function calculateclcd(a)
    data = readdlm("Files/file.txt", skipstart=12)

    alpha = data[:,1]
    CL = data[:,2]
    CD = data[:,3]
    CM = data[:,5]
 
    calculateclvalue = LinearInterpolation(alpha, CL; extrapolation_bc = Line())
    calculatecdvalue = LinearInterpolation(alpha, CD; extrapolation_bc = Line())
    return  (CL = calculateclvalue(a), CD = calculatecdvalue(a))
end

#calculateclcd(-16)

#using Plots
#plot(alpha,CL)
#hello