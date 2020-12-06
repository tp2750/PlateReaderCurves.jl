"""
    Exponentially asymptotic readercurve
    rc_exp(t,A,k,y0) = y0 + A(1 - exp(-t/k))
"""
rc_exp(t,A,k,y0) = y0 .+ A.*(1 .- exp.(-t ./k))

