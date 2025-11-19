AIRFOILDATA = let 

     filepath = joinpath(@__DIR__, "file.txt")
     data = readdlm(filepath; skipstart=12)
     
     alpha = data[:,1]
     CL = data[:,2]
     CD = data[:,3]
     CM = data[:,5]
     
     calculateclvalue = LinearInterpolation(alpha, CL; extrapolation_bc = Line())
     calculatecdvalue = LinearInterpolation(alpha, CD; extrapolation_bc = Line())
     
     # Return the interpolation objects themselves, not the result
     (cl = calculateclvalue, cd = calculatecdvalue)
end


function calculateclcd(a)
    return (CL = AIRFOILDATA.cl(a), CD = AIRFOILDATA.cd(a))
end

calculateclcd(5.0)  # Example usage
 