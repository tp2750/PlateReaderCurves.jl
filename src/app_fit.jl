## Main function for fitting app

if false
    args = Dict(
        "input_xlsxfile" => "dat_ex.xlsx",
        "fit_file" => "/tmp/TAPO_TEST/dat_ex_fit.xlsx",
        "plot_folder" => "/tmp/TAPO_TEST/",
        "lambda_smoothing" => 1,
    )
end


function app_fit(args)
    println("Input parameters:")
    for (arg,val) in args
        println("  $arg  =>  $val")
    end
    
    @info "Read input file"
    dat_df = PlateReaderCurves.xlsx(args["input_xlsxfile"]; sheet = 1)
    @info "Convert to data frame"
    dat = ReaderRun(dat_df)
    @info "Fit smoothing spline"
    dat_fit = rc_fit(dat, "smooth_spline", lambda = args["lambda_smoothing"])
    @info "Convert back to data frame"
    fit_df = DataFrame(dat_fit)
    @info "Save fit"
    mkpath(dirname(args["fit_file"]))
    XLSX.writetable(args["fit_file"], collect(DataFrames.eachcol(fit_df)), DataFrames.names(fit_df); overwrite=true, sheetname = "Fits")
    @info "Plot plates"
    mkpath(dirname(args["plot_folder"]))
    fit_filenames = String[]
    phase_filenames = String[]
    Qs = dat.readerplate_geometry == 96 ? ["Q0"] : ["Q1","Q2","Q3","Q4"]
    for nPlate in 1:length(dat)
        for sQ in Qs 
            sPlate = "$(lpad(nPlate,3,'0'))_$(sQ)"
            @info sPlate
            push!(fit_filenames, joinpath(args["plot_folder"], "plate_$(sPlate)_fit.png"))
            plotObj = plateplot(Q(dat_fit.readerplates[nPlate], sQ))
            png(plotObj, fit_filenames[end])
            @info "did $(fit_filenames[end])"
            push!(phase_filenames, joinpath(args["plot_folder"], "plate_$(sPlate)_phase.png"))
            plotObj = plateplot(Q(dat_fit.readerplates[nPlate], sQ); type = "phase")
            png(plotObj, phase_filenames[end])
            @info "did $(phase_filenames[end])"
        end
    end
    htmlfile = joinpath(args["plot_folder"],"index.html")
    @info "Write $htmlfile"
    ## Use Hyperscript
    h_fitplot_names = [m("h2", basename(x)) for x in fit_filenames]
    h_fitplot = [m("img", src = x) for x in fit_filenames]
    h_pahseplot_names = [m("h2", basename(x)) for x in phase_filenames]
    h_phaseplot = [m("img", src = x) for x in phase_filenames]
    h_page = m("html",
               m("h1", "Plate plots")
               )(m("div").(zip(h_fitplot_names,h_fitplot,h_pahseplot_names,h_phaseplot)))
    savehtml(htmlfile, h_page)
end
