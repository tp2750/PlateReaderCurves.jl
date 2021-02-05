module PlateReaderCurves

using CSV, Plots, Statistics, SmoothingSplines, DataFrames, DataFramesMeta, Dates, Printf, LsqFit, XLSX, Hyperscript
import MTP, Setfield

include("ReaderCurves.jl")
include("functions.jl")
include("plots.jl")
include("adhoc_parsers.jl")
include("app_fit.jl")

export ReaderCurve, ReaderCurveFit, ReaderPlate, ReaderPlateFit, ReaderFile, ReaderRun, geometry
export linreg_trim, smooth_spline, max_slope
export rc_fit, Q, well_names, well
export plateplot, phaseplot
export xlsx

end
