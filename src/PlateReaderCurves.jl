module PlateReaderCurves

using CSV, Plots, Statistics, SmoothingSplines, DataFrames, DataFramesMeta, Dates, Printf, LsqFit, XLSX
import MTP, Setfield

include("ReaderCurves.jl")
include("functions.jl")
include("plots.jl")

export ReaderCurve, ReaderCurveFit, ReaderPlate, ReaderPlateFit, ReaderFile, ReaderRun, geometry
export linreg_trim, smooth_spline, max_slope
export rc_fit, Q, well_names
export plateplot
export xlsx

end
