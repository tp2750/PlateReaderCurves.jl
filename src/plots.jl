"""
    Plot a readercurve
    plot(::ReaderCurve; marker_size=6)    
"""
@recipe function f(r::ReaderCurve; markersize=6)
    seriestype := :scatter
    label --> ""
    marker --> :circle
    markersize --> markersize
    markerstroke --> 2
    markercolor --> :black
    title --> r.well_name
    xguide --> r.time_unit
    yguide --> r.value_unit
    framestyle --> :zerolines ## :origin is tighter
    ## size --> (200,200)
    ## titlefontsize --> 8
    r.kinetic_time, r.reader_value
end




"""
    Plot a readercurve-fit
    plot(::ReaderCurveFit; marker_size=6)    
"""
@recipe function f(r::ReaderCurveFit; markersize=6, parameters=true)
    title --> r.readercurve.well_name
    if parameters
        @series begin
            label --> ""
            series_annotations := ["α = $(round(r.slope, digits=3))", "y0 = $(round(r.intercept,digits=3))"]
            x0 = r.readercurve.kinetic_time[1]
            y0 = maximum(r.readercurve.reader_value)
            [x0,x0], [y0,y0*.9]
        end
    end
    @series begin
        r.readercurve
    end
    
    @series begin
        seriestype := :scatter
        label --> ""
        markershape --> :xcross
        markercolor --> :grey
        r.readercurve.kinetic_time, r.predict(r.readercurve.kinetic_time)
    end

    @series begin
        seriestype := :line
        label --> ""
        seriescolor --> :blue
        r.readercurve.kinetic_time, r.intercept .+ (r.slope .* r.readercurve.kinetic_time)
    end
end


