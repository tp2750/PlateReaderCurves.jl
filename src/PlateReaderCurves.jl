module PlateReaderCurves

using CSV, Plots, Statistics, SmoothingSplines, DataFrames, DataFramesMeta, Dates, Printf, LsqFit, XLSX

include("ReaderCurves.jl")
include("functions.jl")
include("plots.jl")

export ReaderCurve, ReaderCurveFit, ReaderPlate, ReaderPlateFit, ReaderFile, ReaderRun
export linreg_trim, smooth_spline, max_slope
export rc_fit
export plateplot
export xlsx

end
