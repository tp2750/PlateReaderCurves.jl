"""
    Plot a readercurve
    plot(::ReaderCurve; marker_size=6)    
"""
@recipe function f(r::ReaderCurve; markersize=6)
    ## https://docs.juliaplots.org/latest/generated/attributes_series/
    seriestype := :scatter
    label --> ""
    markercolor --> :black
#    markersize --> markersize
    markerstroke --> 2
    title := r.readerplate_well
    xguide --> r.time_unit
    yguide --> r.value_unit
    framestyle --> :zerolines ## :origin is same
    @series begin ## Normal values
        markercolor --> :black
        markershape --> :circle
        r.kinetic_time, r.reader_value
    end
    if any(r.reader_value .== Inf)
        @series begin
            Yu = (r.reader_value .== Inf)
            Ymax = all(.!isfinite.(r.reader_value)) ? 1 : maximum(r.reader_value[isfinite.(r.reader_value)])
            X2 = r.kinetic_time[Yu]
            Y2 = repeat([Ymax], length(X2))
            markershape --> :utriangle
            markercolor --> :grey
            X2,Y2
        end
    end
    if any(r.reader_value .== -Inf)
        @series begin
            Yd = (r.reader_value .== -Inf)
            Ymin = all(.!isfinite.(r.reader_value)) ? 0 : minimum(r.reader_value[isfinite.(r.reader_value)])
            X2 = r.kinetic_time[Yd]
            Y2 = repeat([Ymin], length(X2))
            markershape --> :dtriangle
            markercolor --> :grey
            X2,Y2
        end
    end
    if any(isequal.(r.reader_value, NaN))
        @series begin
            Yn = isequal.(r.reader_value, NaN)
            X2 = r.kinetic_time[Yn]
            Y2 = repeat([0], length(X2))
            markershape --> :x
            markercolor --> :grey
            X2,Y2
        end
    end
end




"""
    Plot a readercurve-fit
    plot(::ReaderCurveFit; marker_size=6)    
"""
@recipe function f(r::ReaderCurveFit;  parameters=true)
    title --> r.readercurve.readerplate_well
    xguide --> r.readercurve.time_unit
    yguide --> r.readercurve.value_unit
    framestyle --> :zerolines ## :origin is tighter
    if parameters && any(isfinite.(r.readercurve.reader_value))
        ## alpha, y0 paramters
        @series begin
            label --> ""
            seriestype := :scatter
            markershape --> :none
            markeralpha --> 0
            series_annotations := ["µα = $(round(1E6*r.slope, digits=1))", "y0 = $(round(r.intercept,digits=3))"] ## OBS micro-slope!
            x0 = r.readercurve.kinetic_time[1]
            y0 = maximum(r.readercurve.reader_value[isfinite.(r.readercurve.reader_value)])
            [x0,x0], [y0,y0*.9]
        end
    end
    ## Predicted values
    @series begin
        seriestype := :scatter
        label --> ""
        markershape --> :xcross
        markercolor --> :grey
        markerstrokewidth--> 2 # no effect
        r.readercurve.kinetic_time, r.predict.(r.readercurve.kinetic_time)
    end
    ## Fitted slope
    @series begin
        seriestype := :line
        label --> ""
        seriescolor --> :blue
        r.readercurve.kinetic_time, r.intercept .+ (r.slope .* r.readercurve.kinetic_time)
    end
    ## Reader curve
    @series begin
        r.readercurve
    end
end


@recipe function f(p::AbstractPlate) ## This should work for both curves and fits, but only works for simple curves with no missing values
    layout --> (8,12)
    size --> (8*400,12*200)
    dpi --> 40
    title --> "$(p.readerfile_name): $p.readerplate_barcode"
    for s in 1:length(p)
        @series begin
            p.readercurves[s]
        end
    end
end

function plateplot(p::AbstractPlate; y_fixed = true, type="value") ## This should work for both curves and fits!    
    rows = sqrt(length(p)/1.5)
    size = rows .* (400,300)
    dpi = minimum([100,320/rows])
    cols = length(p) / rows
    if (floor(cols) == cols) && (floor(rows) == rows)
        layout = (Int(rows),Int(cols))
    else
        layout = length(p)
    end
    link = y_fixed ? :all : :none
    if type == "value"
        plot([plot(x) for x in p.readercurves]..., size = size, dpi = dpi, layout = layout, link = link)
    elseif type == "phase"
        plot([phaseplot(x) for x in p.readercurves]..., size = size, dpi = dpi, layout = layout, link = link)
    end
end


## phase space plot
function phaseplot(rc::ReaderCurve)
    x = rc.reader_value[1:(end-1)]
    y = diff(rc.reader_value) ./ diff(rc.kinetic_time)
    plot(x,y, label="", title = rc.readerplate_well)
end
function phaseplot(rcf::ReaderCurveFit)
    phaseplot(rcf.readercurve)
    t = rcf.readercurve.kinetic_time
    x = rcf.predict.(t)
    y = diff(x) ./ diff(t)
    x = x[1:(end-1)]
    plot!(x,y, color = "green", label="")
    plot!(x, repeat([rcf.slope], length(x)), color = "red", label="")
end

