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
        A01_fit1 = fit(A01,"linreg_trim")
        @test A01_fit1.predict.([0,1]) == [A01_fit1.intercept, A01_fit1.intercept + A01_fit1.slope]
        A01_fit2 = fit(A01,"max_slope")
        @test A01_fit2.predict.([0,1]) == [A01_fit2.intercept, A01_fit2.intercept + A01_fit2.slope]
        A01_fit3 = fit(A01,"smooth_spline"; lambda = 250)
        @test A01_fit3.predict.([0,1]) == [0.05655762222793344, 0.09394291903679455]
        A01_fit4 = fit(A01,"L4P"; lambda = 250)
        @test A01_fit4.predict.([0, 1]) == [0.05138458324982054, 0.09088904053992053]
    end
    @testset "fit with missing" begin
        s1 = collect(0:10:100)
        A02 = ReaderCurve(well_name = "A02",
                          kinetic_time = s1,
                          reader_value = replace( 2 .* s1, 60 => NaN, 20 => Inf, 40=> -Inf),
                          time_unit = "sec",
                          value_unit = "OD405nm",
                          )
        A03 = ReaderCurve(well_name = "A03",
                          kinetic_time = s1,
                          reader_value = repeat([NaN], length(s1)),
                          time_unit = "sec",
                          value_unit = "OD405nm",
                          )
        A04 = ReaderCurve(well_name = "A04",
                          kinetic_time = s1,
                          reader_value = repeat([Inf], length(s1)),
                          time_unit = "sec",
                          value_unit = "OD405nm",
                          )
        A05 = ReaderCurve(well_name = "A05",
                          kinetic_time = s1,
                          reader_value = repeat([-Inf], length(s1)),
                          time_unit = "sec",
                          value_unit = "OD405nm",
                          )
        A02_fit1 = fit(A02,"linreg_trim")
        A03_fit1 = fit(A03,"linreg_trim")
        A04_fit1 = fit(A04,"linreg_trim")
        A05_fit1 = fit(A05,"linreg_trim")

        A02_fit2 = fit(A02,"max_slope")
        A03_fit2 = fit(A03,"max_slope")
        A04_fit2 = fit(A04,"max_slope")
        A05_fit2 = fit(A05,"max_slope")

        A02_fit3 = fit(A02,"smooth_spline")
        A03_fit3 = fit(A03,"smooth_spline")
        A04_fit3 = fit(A04,"smooth_spline")
        A05_fit3 = fit(A05,"smooth_spline")

        A02_fit4 = fit(A02,"L4P") ## Terrible fit!
        A03_fit4 = fit(A03,"L4P")
        A04_fit4 = fit(A04,"L4P")
        A05_fit4 = fit(A05,"L4P")

 
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
@testset "Plate" begin
    s1 = collect(0:10:100)
    y1 = PlateReaderCurves.rc_exp(s1, 4, 100, 0.05) ## 0.05 .+ 4 .* (1 .- exp.(-s1 ./100)),
    A01 = ReaderCurve(well_name = "A01",
                      kinetic_time = s1,
                      reader_value = y1,
                      time_unit = "sec",
                      value_unit = "OD405nm",
                      )
    A02 = ReaderCurve(well_name = "A01",
                      kinetic_time = s1,
                      reader_value = y1 .+ 0.1,
                      time_unit = "sec",
                      value_unit = "OD405nm",
                      )
    A03 = ReaderCurve(well_name = "A01",
                      kinetic_time = s1,
                      reader_value = y1 .- 0.1,
                      time_unit = "sec",
                      value_unit = "OD405nm",
                      )
    Plate_1 = ReaderPlate(
        readerplate_id = "1117389a-9abe-4cf9-9feb-ec7fa1aa0933",
        readerplate_barcode = "",
        readerfile_name = "testFile",
        readerplate_number = 1,
        readerplate_geometry = 96,
        readercurves = [A01, A02, A03]
    )
    @test length(Plate_1) == 3
end
