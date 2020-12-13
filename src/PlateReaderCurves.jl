module PlateReaderCurves

using CSV, Plots, Statistics, SmoothingSplines, DataFrames

include("ReaderCurves.jl")
include("functions.jl")
include("plots.jl")

export ReaderCurve, ReaderCurveFit
export plot_r
export linreg_trim
export fit

end
