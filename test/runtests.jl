using PlateReaderCurves
using Test
using DataFrames, CSV

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
        @test A01_fit.predict.([0,1]) == [A01_fit.intercept, A01_fit.intercept + A01_fit.slope]
        A01_fit2 = fit(A01,"max_slope")
        @test A01_fit2.predict.([0,1]) == [A01_fit2.intercept, A01_fit2.intercept + A01_fit2.slope]
        A01_fit3 = fit(A01,"smooth_spline"; lambda = 250)
        @test A01_fit3.predict.([0,1]) == [0.05655762222793344, 0.09394291903679455]
    end
end
@testset "Bubble" begin
    B01_df = CSV.File("b01.csv") |> DataFrame
    B01 = ReaderCurve(well_name = "B01",
                      kinetic_time = B01_df.kinetic_sec,
                      reader_value = B01_df.absorbance_value,
                      time_unit = "sec",
                      value_unit = "OD405"
                      )
    B01_fit = fit(B01,"linreg_trim")
    @test B01_fit.predict.([0,1]) == [B01_fit.intercept, B01_fit.intercept + B01_fit.slope]
    B01_fit2 = fit(B01,"max_slope")
    @test B01_fit2.predict.([0,1]) == [B01_fit2.intercept, B01_fit2.intercept + B01_fit2.slope]
    B01_fit3 = fit(B01,"smooth_spline"; lambda = 250)
    @test B01_fit3.predict.([0,1]) == [0.08762157518257128, 0.08767650822148132]
end

