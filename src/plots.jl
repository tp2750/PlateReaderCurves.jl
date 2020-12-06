"""
    Plot a readercurve
    plot(::ReaderCurve; marker_size=6)    
"""
@recipe function f(r::ReaderCurve; markersize=6)
    seriestype := :scatter
    label --> ""
    marker --> :+
    markersize --> markersize
    markercolor --> "black"
    title --> r.well_name
    xguide --> r.time_unit
    yguide --> r.value_unit
    framestyle --> :zerolines ## :origin is tighter
    ## size --> (200,200)
    ## titlefontsize --> 8
    r.kinetic_time, r.reader_value
end


