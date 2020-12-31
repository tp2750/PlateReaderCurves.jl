"""
    ReaderCurve: Datastructure for holding reader curves
    Fields:
    well_name::String = "well"
    kinetic_time::Array
    reader_value::Array{Union{Missing, Real}}
    reader_temperature::Array{Union{Missing, Real}} = [missing]
    time_unit::String
    value_unit::String
    temperature_unit::String = "C"    
"""
Base.@kwdef struct ReaderCurve
    well_name::String = "well"
    kinetic_time::Array{Real}
    reader_value::Array{Real} ## Use Inf, -Inf, NaN rather than Union{Missing, Real}}
    reader_temperature::Array{Union{Missing, Real}} = [missing]
    time_unit::String
    value_unit::String
    temperature_unit::String = "C"
end

function ReaderCurve(df::DataFrame)
    cols_needed(df, string.(fieldnames(ReaderCurve)), "ReaderCurve(::DataFrame)")
    @assert all(.!nonunique(df, :kinetic_time))
    @assert length(unique(df.well_name)) == 1
    @assert length(unique(df.time_unit)) == 1
    @assert length(unique(df.value_unit)) == 1
    @assert length(unique(df.temperature_unit)) == 1
    ReaderCurve(well_name = first(unique(df.well_name)),
                kinetic_time = df.kinetic_time,
                reader_value = df.reader_value,
                reader_temperature = df.reader_temperature,
                time_unit = first(unique(df.time_unit)),
                value_unit = first(unique(df.value_unit)),
                temperature_unit = first(unique(df.temperature_unit))
                )
end


function cols_needed(df, cols, caller)
    missed_cols = setdiff(cols, names(df))
    if length(missed_cols) > 0
        error("""$caller is missing $(length(missed_cols)): $(join(missed_cols, ", "))""")
    end
    true
end

"""
    ReaderCurveFit: Datastructure for holding reader curves and corresponding fits
    Fields:
    readercurve::ReaderCurve the input readercurve
    fit_method::String name of method to fit (linreg_trim, )
    fit_input_parameters::NamedTuple parameters given to fit method
    predict::Function fitted function. Can be used to predict new fitted values
    slope::Real max slope
    intercept::Real intercept of max slope curve
    fit_mean_residual::Real average absolute residuals of fit and read
"""
Base.@kwdef struct ReaderCurveFit
    readercurve::ReaderCurve
    fit_method::String
    fit_input_parameters::NamedTuple
    predict::Function
    slope::Real
    intercept::Real
    fit_mean_residual::Real
end

abstract type AbstractPlate end

"""
    ReaderPlate: Structure representing a readerplate
    readerplate_id::String  globally unique eg from UUIDs.uuid4()
    readerplate_barcode::String  can be ""
    readerfile_name::String
    readerplate_number::Int  number in readerfile
    readerplate_geometry::Int  96, 384
    readercurves::Array{ReaderCurve} array of reader curves
"""
Base.@kwdef struct ReaderPlate <: AbstractPlate
    readerplate_id::String ## globally unique eg from UUIDs.uuid4()
    readerplate_barcode::String ## can be ""
    readerfile_name::String
    readerplate_number::Int ## number in readerfile
    readerplate_geometry::Int ## 96, 384
    readercurves::Array{ReaderCurve}
end

"""
    ReaderPlateFit: Structure representing a fit of curves on a readerplate
        Very similar to ReaderPlate
    readerplate_id::String   globally unique eg from UUIDs.uuid4()
    readerplate_barcode::String   can be ""
    readerfile_name::String
    readerplate_number::Int   number in readerfile
    readerplate_geometry::Int  96, 384
    readercurves::Array{ReaderCurveFit}
"""
Base.@kwdef struct ReaderPlateFit <: AbstractPlate
    readerplate_id::String ## globally unique eg from UUIDs.uuid4()
    readerplate_barcode::String ## can be ""
    readerfile_name::String
    readerplate_number::Int ## number in readerfile
    readerplate_geometry::Int ## 96, 384
    readercurves::Array{ReaderCurveFit}
end

function ReaderPlate(df::DataFrame)
    cols_needed(df, setdiff(string.(fieldnames(ReaderPlate)), ["readercurves"]), "ReaderPlate(::DataFrame)")
    @assert length(unique(df.readerplate_id)) == 1
    @assert length(unique(df.readerplate_barcode)) == 1
    @assert length(unique(df.readerfile_name)) == 1
    @assert length(unique(df.readerplate_geometry)) == 1
    curves = ReaderCurve[]
    for w in unique(df.well_name)
        # push!(curves, ReaderCurve(df[df.well_name .== w,:]))
        push!(curves, ReaderCurve(@where(df, :well_name .== w)))
    end
    ReaderPlate(readerplate_id = first(unique(df.readerplate_id)),
                readerplate_barcode = first(unique(df.readerplate_barcode)),
                readerfile_name = first(unique(df.readerfile_name)),
                readerplate_number = 1,
                readerplate_geometry = first(unique(df.readerplate_geometry)),
                readercurves= curves)
end

Base.@kwdef struct ReaderRun
    equipment::String
    software::String
    run_starttime::Union{DateTime, Missing}
    readerplates::Array{ReaderPlate} ## assert that readerplate_number matches position in array, and readerfile_name matches outer
end

function ReaderPlates(df::DataFrame)::Array{ReaderPlate}
    mycols = setdiff(string.(fieldnames(ReaderPlate)), ["readercurves"])
    cols_needed(df, mycols, "ReaderPlates(::DataFrame)")
    plates = ReaderPlate[]
    for p in unique(df.readerplate_id)
        push!(plates, ReaderPlate(@where(df, :readerplate_id .== p)))
    end
    plates
end

function ReaderRun(df::DataFrame)
    cols_needed(df, setdiff(string.(fieldnames(ReaderRun)), ["readerplates"]), "ReaderRnu(::DataFrame)")
    @assert length(unique(df.equipment)) == 1
    @assert length(unique(df.software)) == 1
    @assert length(unique(df.run_starttime)) == 1
    plates = ReaderPlates(df)
    ReaderRun(equipment = first(unique(df.equipment)),
              software = first(unique(df.software)),
              run_starttime = first(unique(df.run_starttime)),
              readerplates = plates)
end
    
function Base.length(p::AbstractPlate)
    length(p.readercurves)
end

Base.length(r::ReaderRun) = length(r.readerplates)
