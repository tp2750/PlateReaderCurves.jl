using PlateReaderCurves
using Test

@testset "ReaderCurves.jl" begin
    s1 = collect(0:10:100)
    y1 = PlateReaderCurves.rc_exp(s1, 4, 100, 0.05) ## 0.05 .+ 4 .* (1 .- exp.(-s1 ./100)),
    A01 = ReaderCurve(well_name = "A01",
                      kinetic_time = s1,
                      reader_value = y1,
                      time_unit = "sec",
                      value_unit = "OD405nm",
                      )
    @test A01.reader_value[11] == 0.05 + 4 * (1 - exp(-1))
    @testset "Fit" begin
        A01_fit = fit(A01,"linreg_trim")
        @test  A01_fit.slope == 0.02590045506642908
    end
end
