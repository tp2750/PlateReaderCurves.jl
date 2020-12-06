module PlateReaderCurves

using CSV, Plots

include("ReaderCurves.jl")
include("functions.jl")
include("plots.jl")

export ReaderCurve
export plot_r

end
