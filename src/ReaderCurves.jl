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


Base.@kwdef struct ReaderFile
    readerfile_name::String 
    equipment::String
    software::String
    run_starttime::DateTime
    readerplates::Array{ReaderPlate} ## assert that readerplate_number matches position in array, and readerfile_name matches outer
end


function Base.length(p::AbstractPlate)
    length(p.readercurves)
end

