module PlateReaderCurves

using CSV, Plots, Statistics, SmoothingSplines, DataFrames, Dates, Printf, LsqFit

include("ReaderCurves.jl")
include("functions.jl")
include("plots.jl")

export ReaderCurve, ReaderCurveFit, ReaderPlate, ReaderPlateFit, ReaderFile
export linreg_trim, smooth_spline, max_slope
export rc_fit
export plateplot

end
