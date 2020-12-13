module PlateReaderCurves

using CSV, Plots, Statistics, SmoothingSplines, DataFrames

include("ReaderCurves.jl")
include("functions.jl")
include("plots.jl")

export ReaderCurve, ReaderCurveFit
export linreg_trim, smooth_spline, max_slope
export fit

end
