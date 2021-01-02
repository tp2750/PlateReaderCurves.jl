using PlateReaderCurves
using Test
using DataFrames, CSV

@testset "ReaderCurves.jl" begin
    s1 = collect(0:10:100)
    y1 = PlateReaderCurves.rc_exp(s1, 4, 100, 0.05) ## 0.05 .+ 4 .* (1 .- exp.(-s1 ./100)),
    A01 = ReaderCurve(readerplate_well = "A01",
                      kinetic_time = s1,
                      reader_value = y1,
                      time_unit = "sec",
                      value_unit = "OD405nm",
                      )
    @test A01.reader_value[11] == 0.05 + 4 * (1 - exp(-1))
    @testset "Fit" begin
        A01_fit1 = rc_fit(A01,"linreg_trim")
        A01_fit2 = rc_fit(A01,"max_slope")
        A01_fit3 = rc_fit(A01,"smooth_spline"; lambda = 250)
        A01_fit4 = rc_fit(A01,"L4P"; lambda = 250)
        @test A01_fit1.predict.([0,1]) == [A01_fit1.intercept, A01_fit1.intercept + A01_fit1.slope]
        @test A01_fit2.predict.([0,1]) == [A01_fit2.intercept, A01_fit2.intercept + A01_fit2.slope]
        @test isapprox(A01_fit3.predict.([0,1]), [0.05655762222793344, 0.09394291903679455])
        @test isapprox(A01_fit4.predict.([0,1]), [0.05138458324982054, 0.09088904053992053])
    end
    @testset "fit with missing" begin
        s1 = collect(0:10:100)
        A02 = ReaderCurve(readerplate_well = "A02",
                          kinetic_time = s1,
                          reader_value = replace( 2 .* s1, 60 => NaN, 20 => Inf, 40=> -Inf),
                          time_unit = "sec",
                          value_unit = "OD405nm",
                          )
        A03 = ReaderCurve(readerplate_well = "A03",
                          kinetic_time = s1,
                          reader_value = repeat([NaN], length(s1)),
                          time_unit = "sec",
                          value_unit = "OD405nm",
                          )
        A04 = ReaderCurve(readerplate_well = "A04",
                          kinetic_time = s1,
                          reader_value = repeat([Inf], length(s1)),
                          time_unit = "sec",
                          value_unit = "OD405nm",
                          )
        A05 = ReaderCurve(readerplate_well = "A05",
                          kinetic_time = s1,
                          reader_value = repeat([-Inf], length(s1)),
                          time_unit = "sec",
                          value_unit = "OD405nm",
                          )
        A02_fit1 = rc_fit(A02,"linreg_trim")
        A03_fit1 = rc_fit(A03,"linreg_trim")
        A04_fit1 = rc_fit(A04,"linreg_trim")
        A05_fit1 = rc_fit(A05,"linreg_trim")

        A02_fit2 = rc_fit(A02,"max_slope")
        A03_fit2 = rc_fit(A03,"max_slope")
        A04_fit2 = rc_fit(A04,"max_slope")
        A05_fit2 = rc_fit(A05,"max_slope")

        A02_fit3 = rc_fit(A02,"smooth_spline")
        A03_fit3 = rc_fit(A03,"smooth_spline")
        A04_fit3 = rc_fit(A04,"smooth_spline")
        A05_fit3 = rc_fit(A05,"smooth_spline")

        A02_fit4 = rc_fit(A02,"L4P") ## Terrible fit!
        A03_fit4 = rc_fit(A03,"L4P")
        A04_fit4 = rc_fit(A04,"L4P")
        A05_fit4 = rc_fit(A05,"L4P")

        Plate_2 = ReaderPlate(
        readerplate_id = "1117389a-9abe-4cf9-9feb-ec7fa1aa0945",
        readerplate_barcode = "",
        readerfile_name = "testFile",
        readerplate_geometry = 96,
        readercurves = [A02,A03,A04,A05]
        )
        
        Plate_3 = ReaderPlateFit(
        readerplate_id = "1117389a-9abe-4cf9-9feb-ec7fa1aa0931",
        readerplate_barcode = "",
        readerfile_name = "testFile",
        readerplate_geometry = 96,
        readercurves = [A02_fit3,A03_fit3,A04_fit3,A05_fit3]
        )
        
    end    
end
@testset "Bubble" begin
    B01_df = CSV.File("b01.csv") |> DataFrame
    B01 = ReaderCurve(readerplate_well = "B01",
                      kinetic_time = B01_df.kinetic_sec,
                      reader_value = B01_df.absorbance_value,
                      time_unit = "sec",
                      value_unit = "OD405"
                      )
    B01_fit = rc_fit(B01,"linreg_trim")
    @test B01_fit.predict.([0,1]) == [B01_fit.intercept, B01_fit.intercept + B01_fit.slope]
    B01_fit2 = rc_fit(B01,"max_slope")
    @test B01_fit2.predict.([0,1]) == [B01_fit2.intercept, B01_fit2.intercept + B01_fit2.slope]
    B01_fit3 = rc_fit(B01,"smooth_spline"; lambda = 250)
    @test B01_fit3.predict.([0,1]) == [0.08762157518257128, 0.08767650822148132]
    B01_fit4 = rc_fit(B01,"L4P"; )
end
@testset "Plate" begin
    s1 = collect(0:10:100)
    y1 = PlateReaderCurves.rc_exp(s1, 4, 100, 0.05) ## 0.05 .+ 4 .* (1 .- exp.(-s1 ./100)),
    A01 = ReaderCurve(readerplate_well = "A01",
                      kinetic_time = s1,
                      reader_value = y1,
                      time_unit = "sec",
                      value_unit = "OD405nm",
                      )
    A02 = ReaderCurve(readerplate_well = "A02",
                      kinetic_time = s1,
                      reader_value = y1 .+ 0.1,
                      time_unit = "sec",
                      value_unit = "OD405nm",
                      )
    A03 = ReaderCurve(readerplate_well = "A03",
                      kinetic_time = s1,
                      reader_value = y1 .- 0.1,
                      time_unit = "sec",
                      value_unit = "OD405nm",
                      )
    Plate_1 = ReaderPlate(
        readerplate_id = "1117389a-9abe-4cf9-9feb-ec7fa1aa0933",
        readerplate_barcode = "Barcode",
        readerfile_name = "testFile",
        readerplate_geometry = 96,
        readercurves = [A01, A02, A03]
    )
    Plate_f1 = ReaderPlateFit(
        readerplate_id = "1117389a-9abe-4cf9-9feb-ec7fa1aa0932",
        readerplate_barcode = "Barcode",
        readerfile_name = "testFile",
        readerplate_geometry = 96,
        readercurves = [rc_fit(A01, "smooth_spline"), rc_fit(A02, "smooth_spline"), rc_fit(A03, "smooth_spline")]
    )
    
    @test length(Plate_1) == 3
    
end
