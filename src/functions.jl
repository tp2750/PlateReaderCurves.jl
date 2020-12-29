""" 
    rc_fit(::ReaderCurve, method::String)
    Fit a readercurve.
    Returns a ReaderCurveFit containing the original readercurve and a predict function that can be used to predict new values. It also contains Slope, intercept and mean residual.
    See @ref ReaderCurveFit
    Methods:
    - linreg_trim: linear regression omitting y_low_pct and y_high_pct of y range.
    - max_slope:
"""
function rc_fit(rc::ReaderCurve, method::String; y_low_pct=10, y_high_pct=90, lambda = 250, l4p_parameter=100)
    ## method dispatch options: https://discourse.julialang.org/t/dispatch-and-symbols/21162/7?u=tp2750
    (X,Y) = get_finite(rc.kinetic_time, rc.reader_value)
    if(length(Y) == 0)
        return(
            ReaderCurveFit(
                readercurve = rc,
                fit_method = method,
                fit_input_parameters = (;y_low_pct, y_high_pct, lambda),
                predict = t -> NaN,
                slope = NaN,
                intercept = NaN,
                fit_mean_residual = NaN
            )
        )
    end
    if method == "linreg_trim"
        f1 = linreg_trim(X,Y; y_low_pct, y_high_pct=90)
        pred_fun1(t) = f1.intercept + f1.slope * t
        return(
            ReaderCurveFit(
                readercurve = rc,
                fit_method = method,
                fit_input_parameters = (;y_low_pct, y_high_pct),
                predict = pred_fun1,
                slope = f1.slope,
                intercept = f1.intercept,
                fit_mean_residual = mean(abs.(pred_fun1.(X) .- Y))
            )
        )
    elseif (method == "max_slope")
        f1 = max_slope(X,Y)
        pred_fun2(t) = f1.intercept + f1.slope * t
        return(
            ReaderCurveFit(
                readercurve = rc,
                fit_method = method,
                fit_input_parameters = (;),
                predict = pred_fun2,
                slope = f1.slope,
                intercept = f1.intercept,
                fit_mean_residual = mean(abs.(pred_fun2.(X) .- Y))
            )
        )
    elseif method == "smooth_spline"
        l1 = convert(Float64,lambda)
        f1 = smooth_spline_fit(X,Y; lambda = l1)
        pred_fun3(t) = SmoothingSplines.predict(f1,convert(Float64,t))
        ms = max_slope(X,pred_fun3.(X))
        return(
            ReaderCurveFit(
                readercurve = rc,
                fit_method = method,
                fit_input_parameters = (;),
                predict = pred_fun3,
                slope = ms.slope,
                intercept = ms.intercept,
                fit_mean_residual = mean(abs.(pred_fun3.(X) .- Y))
            )
        )
    elseif method == "exp"
        p0 = [0,1,1,1]
        f1 = LsqFit.curve_fit(rc_exp,rc.kinetic_time, rc.reader_value, p0)
    elseif method == "L4P"
        lc4_params = rc_logistic_fit(X,Y; l4p_parameter=100)
        pred_l4p = t -> rc_logistic_fun(t,lc4_params)
        ms = max_slope(X,pred_l4p.(X))
        return(
            ReaderCurveFit(
                readercurve = rc,
                fit_method = method,
                fit_input_parameters = (;l4p_parameter),
                predict = pred_l4p,
                slope = ms.slope,
                intercept = ms.intercept,
                fit_mean_residual = mean(abs.(pred_l4p.(X) .- Y))
            )
        )        
    else
        error("This should not happen")
    end
end

"""
    Exponentially asymptotic readercurve
    rc_exp(t,A,k,y0) = y0 + A(1 - exp(-t/k))
"""
rc_exp(t,A,k,y0) = y0 .+ A.*(1 .- exp.(-t ./k))

rc_exp(t,p) = p[3] .+ p[1].*(1 .- exp.(-t ./p[2]))

function smooth_spline_fit(x,y; lambda=250.0)
    ## TODO auto select lambda based on GCV. see paper: ../Lukas_deH_RSA_2015.pdf
    ## From https://github.com/nignatiadis/SmoothingSplines.jl
    X = map(Float64,convert(Array,x))
    Y = map(Float64,convert(Array,y))
    spl = SmoothingSplines.fit(SmoothingSpline, X, Y, lambda)
    # Ypred = SmoothingSplines.predict(spl)
    # Ypred
end


"""
    linreg(x, y): Linear regression
    Output: (intercept, slope)
"""
function linreg(x, y)
    (i,s) = hcat(fill!(similar(x), 1), x) \ y ## https://github.com/JuliaStats/StatsBase.jl/issues/398#issuecomment-417875619
    (intercept = i, slope = s)
end

"""
    linreg_trim(ReaderCurve; y_low_pct=0, y_high_pct): trimmed linear regression
    linreg_trim(x,y; y_low_pct=0, y_high_pct)
    Skip the y_low_pct %, and y_high_pct % of the y-range.
    Eg linreg_trim(x,y; 5,95) will use the central 90% of the y-range.
    Note it is using the range of the y-values. Not the number of values, as a quantile would do.
    Output: (intercept, slope) or ReaderCurveFit object
"""
function linreg_trim(x,y; y_low_pct=10, y_high_pct=90)
    X,Y = get_finite(x,y)
    if(length(Y) == 0)
        return(intercept = NaN, slope = NaN)
    end
    y_cover = maximum(Y) - minimum(Y)
    y_1 = minimum(Y) + y_low_pct /100 * y_cover
    y_2 = minimum(Y) + y_high_pct/100 * y_cover
    idx = (Y .>= y_1) .& (Y .<= y_2)
    linreg(X[idx], Y[idx])
end

function max_slope(x,y)
    X,Y = get_finite(x,y)
    if(length(Y) == 0)
        return(intercept = NaN, slope = NaN)
    end
    slopes = diff(Y) ./ diff(X)
    slope = maximum(slopes)
    slope_idx = findfirst(slopes .== slope)    
    b = y[slope_idx] - slope * x[slope_idx]
    (intercept = b,slope = slope)
end

function get_finite(x,y)
    y_finite = isfinite.(y)
    X = x[y_finite]
    Y = y[y_finite]
    (X,Y)
end    

function rc_logistic_fun(t,p)
    @. p[1]/(1+exp(4*p[2]/p[1]*(p[3]-t)+2))+p[4] # logistic
end


function rc_logistic_fit(x,y; l4p_parameter=100)
    guess_parameter = l4p_parameter
    p0 = [0,0,0,0] ## A, µ, λ, bg
    fit1 = linreg_trim(x,y; y_low_pct=10, y_high_pct=90)
    A = maximum(y)
    µ = fit1[2]
    λ = -fit1[1]/fit1[2]
    bg = minimum(y)
    p0 = [A, µ, λ, bg]
    pl = minimum.([1/guess_parameter,guess_parameter, -1/guess_parameter, -guess_parameter].*x for x in [abs(A)+abs(bg), µ, λ, abs(A)+abs(bg)])
    pu = maximum.([1/guess_parameter,guess_parameter, -1/guess_parameter, -guess_parameter].*x for x in [abs(A)+abs(bg), µ, λ, abs(A)+abs(bg)])  ## [10 *A, 10 *µ, 10 *λ, maximum([bg*10, -bg*10])] [0.01,100, -0.01, -100]
    @debug p0 - pl
    @debug pu - p0
    fit2 = LsqFit.curve_fit(rc_logistic_fun, x, y ,p0; lower = pl, upper = pu)
    at_upper = abs.(pu .- coef(fit2)) .<= 1E-10
    at_lower = abs.(pl .- coef(fit2)) .<= 1E-10
    if any(at_upper)
        @show p0
        @show pu
        @show @sprintf("rc_logistic_fit Hitting upper bound at index %s", findall(at_upper))
    end
    if any(at_lower)
        @show p0
        @show pl
        @show @sprintf("rc_logistic_fit Hitting lower bound at index %s", findall(at_lower))
    end
    coef(fit2)
end

