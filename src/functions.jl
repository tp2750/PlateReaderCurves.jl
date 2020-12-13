""" 
    fit(::ReaderCurve, method::String)
    Fit a readercurve.
    Returns a ReaderCurveFit containing the original readercurve and a predict function that can be used to predict new values. It also contains Slope, intercept and mean residual.
    See @ref ReaderCurveFit
"""
function fit(rc::ReaderCurve, method::String; y_low_pct=10, y_high_pct=90)
    ## method dispatch options: https://discourse.julialang.org/t/dispatch-and-symbols/21162/7?u=tp2750    
    if method == "linreg_trim"
        f1 = linreg_trim(rc.kinetic_time, rc.reader_value; y_low_pct, y_high_pct=90)
        pred_fun(t) = f1.intercept .+ f1.slope .* t
        return(
            ReaderCurveFit(
                readercurve = rc,
                fit_method = method,
                fit_input_parameters = (;y_low_pct, y_high_pct),
                predict = pred_fun,
                slope = f1.slope,
                intercept = f1.intercept,
                fit_mean_residual = mean(abs.(pred_fun(rc.kinetic_time) .-  rc.reader_value))
            )
        )
    end
end

"""
    Exponentially asymptotic readercurve
    rc_exp(t,A,k,y0) = y0 + A(1 - exp(-t/k))
"""
rc_exp(t,A,k,y0) = y0 .+ A.*(1 .- exp.(-t ./k))

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
    y_cover = maximum(y) - minimum(y)
    y_1 = minimum(y) + y_low_pct /100 * y_cover
    y_2 = minimum(y) + y_high_pct/100 * y_cover
    idx = (y .>= y_1) .& (y .<= y_2)
    linreg(x[idx], y[idx])
end

