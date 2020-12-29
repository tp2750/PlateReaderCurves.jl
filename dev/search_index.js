var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = PlateReaderCurves","category":"page"},{"location":"#PlateReaderCurves","page":"Home","title":"PlateReaderCurves","text":"","category":"section"},{"location":"#Purpose","page":"Home","title":"Purpose","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package is for working with the output from optical platereaders.","category":"page"},{"location":"#Status","page":"Home","title":"Status","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This is very early development.","category":"page"},{"location":"#Plans","page":"Home","title":"Plans","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"[X] Data structure to hold reader curve\n[X] Plots recipe to plot a reader curve\n[X] Functions to fit a model to the reader curve and extract the maximal slope\n[X] Data structure to hold a fit to the reader curve\n[X] Plots recipe to plot a creader curve together with the fit and derived slope\n[X] Data structure to hold a plate of reader curves, fits and slopes\n[ ] Plots Recipe to plot a plate of reader curves (and fits and slopes)\n[ ] Data structure to hold relative activity of 2 wells\n[ ] Plots recipe to plot relative activity of 2 wells\n[ ] Parsers for output files from readers I use\n[ ] Fit functions:\n[X] Trimed linear regression\n[X] Splite fit\n[ ] B-spline fit\n[ ] Exponential asymptote\n[ ] 5 parameter logistic","category":"page"},{"location":"#Tutorial","page":"Home","title":"Tutorial","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Create a reader curve and plot it:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using PlateReaderCurves, Plots\ns1 = collect(0:10:100)\ny1 = PlateReaderCurves.rc_exp(s1, 4, 100, 0.05)\nA01 = ReaderCurve(well_name = \"A01\",\n                      kinetic_time = s1,\n                      reader_value = y1,\n                      time_unit = \"sec\",\n                      value_unit = \"OD405nm\",\n                      )\nplot(A01)","category":"page"},{"location":"#Fitting-a-readercurve","page":"Home","title":"Fitting a readercurve","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Fitting a reader curve returns a ReaderCurveFit. This contains the original reader curve, and the fitted function, which can be used for prediction. It also contains the \"slope\" and \"intercept\" of the maximal slope of he fitted function in the observed x-range.","category":"page"},{"location":"","page":"Home","title":"Home","text":"A01_fit = PlateReaderCurves.rc_fit(A01,\"linreg_trim\")\n\ncollect(A01_fit.predict.(1:10))\n\nplot(A01_fit)","category":"page"},{"location":"#Fitting-methods","page":"Home","title":"Fitting methods","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"We implement different fitting methods:","category":"page"},{"location":"","page":"Home","title":"Home","text":"max_slope: maximal observed slope between adjacent measurements\nlinreg_trim: linear regression. Optionally trimmed on fraction of y-range\nsmooth_spline: smoothing spline fit","category":"page"},{"location":"","page":"Home","title":"Home","text":"using SmoothingSplines\nA01_fit = rc_fit(A01,\"linreg_trim\");\nA01_fit2 = rc_fit(A01,\"max_slope\");\nA01_fit3 = rc_fit(A01,\"smooth_spline\"; lambda = 250);\n\nplot(plot(A01), plot(A01_fit), plot(A01_fit2), plot(A01_fit3))","category":"page"},{"location":"#Missing-values","page":"Home","title":"Missing values","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"For some types of experiments, the reader can not report a value, but only that the value is OVERFLOW or UNDERFLOW. There are represented as Inf and -Inf respectively. Values missing for other reasons are encoded as NaN. In this way, we stay within the floating point types.","category":"page"},{"location":"","page":"Home","title":"Home","text":"Non-finite values are ignored in fitting and plotted at the max (Inf) or min (-Inf) of the other values or 0 for NaN. All Inf curves are plotted at 1 and all -Inf curves are plotted at 0.","category":"page"},{"location":"","page":"Home","title":"Home","text":"using PlateReaderCurves, Plots\ns1 = collect(0:.1:2)\nA02 = ReaderCurve(well_name = \"A02\",\n\tkinetic_time = s1,\n\treader_value = replace( 2 .* s1, .6 => NaN, 1.2 => Inf, 1.4=> -Inf),\n\ttime_unit = \"sec\",\n\tvalue_unit = \"OD405nm\",\n)\nA02_fit1 = rc_fit(A02, \"linreg_trim\")\nplot(plot(A02), plot(A02_fit1))","category":"page"},{"location":"","page":"Home","title":"Home","text":"using PlateReaderCurves, Plots\ns1 = collect(0:.1:2)\nA03 = ReaderCurve(well_name = \"A03\",\n\tkinetic_time = s1,\n\treader_value = repeat([NaN], length(s1)),\n\ttime_unit = \"sec\",\n\tvalue_unit = \"OD405nm\",\n)\nA04 = ReaderCurve(well_name = \"A04\",\n\tkinetic_time = s1,\n\treader_value = repeat([Inf], length(s1)),\n\ttime_unit = \"sec\",\n\tvalue_unit = \"OD405nm\",\n)\nA05 = ReaderCurve(well_name = \"A05\",\n\tkinetic_time = s1,\n\treader_value = repeat([-Inf], length(s1)),\n\ttime_unit = \"sec\",\n\tvalue_unit = \"OD405nm\",\n)\nplot(plot(A03), plot(A04), plot(A05))","category":"page"},{"location":"#API","page":"Home","title":"API","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [PlateReaderCurves]","category":"page"},{"location":"#PlateReaderCurves.ReaderCurve","page":"Home","title":"PlateReaderCurves.ReaderCurve","text":"ReaderCurve: Datastructure for holding reader curves\nFields:\nwell_name::String = \"well\"\nkinetic_time::Array\nreader_value::Array{Union{Missing, Real}}\nreader_temperature::Array{Union{Missing, Real}} = [missing]\ntime_unit::String\nvalue_unit::String\ntemperature_unit::String = \"C\"\n\n\n\n\n\n","category":"type"},{"location":"#PlateReaderCurves.ReaderCurveFit","page":"Home","title":"PlateReaderCurves.ReaderCurveFit","text":"ReaderCurveFit: Datastructure for holding reader curves and corresponding fits\nFields:\nreadercurve::ReaderCurve the input readercurve\nfit_method::String name of method to fit (linreg_trim, )\nfit_input_parameters::NamedTuple parameters given to fit method\npredict::Function fitted function. Can be used to predict new fitted values\nslope::Real max slope\nintercept::Real intercept of max slope curve\nfit_mean_residual::Real average absolute residuals of fit and read\n\n\n\n\n\n","category":"type"},{"location":"#PlateReaderCurves.ReaderPlate","page":"Home","title":"PlateReaderCurves.ReaderPlate","text":"ReaderPlate: Structure representing a readerplate\nreaderplate_id::String  globally unique eg from UUIDs.uuid4()\nreaderplate_barcode::String  can be \"\"\nreaderfile_name::String\nreaderplate_number::Int  number in readerfile\nreaderplate_geometry::Int  96, 384\nreadercurves::Array{ReaderCurve} array of reader curves\n\n\n\n\n\n","category":"type"},{"location":"#PlateReaderCurves.ReaderPlateFit","page":"Home","title":"PlateReaderCurves.ReaderPlateFit","text":"ReaderPlateFit: Structure representing a fit of curves on a readerplate\n    Very similar to ReaderPlate\nreaderplate_id::String   globally unique eg from UUIDs.uuid4()\nreaderplate_barcode::String   can be \"\"\nreaderfile_name::String\nreaderplate_number::Int   number in readerfile\nreaderplate_geometry::Int  96, 384\nreadercurves::Array{ReaderCurveFit}\n\n\n\n\n\n","category":"type"},{"location":"#PlateReaderCurves.linreg-Tuple{Any,Any}","page":"Home","title":"PlateReaderCurves.linreg","text":"linreg(x, y): Linear regression\nOutput: (intercept, slope)\n\n\n\n\n\n","category":"method"},{"location":"#PlateReaderCurves.linreg_trim-Tuple{Any,Any}","page":"Home","title":"PlateReaderCurves.linreg_trim","text":"linreg_trim(ReaderCurve; y_low_pct=0, y_high_pct): trimmed linear regression\nlinreg_trim(x,y; y_low_pct=0, y_high_pct)\nSkip the y_low_pct %, and y_high_pct % of the y-range.\nEg linreg_trim(x,y; 5,95) will use the central 90% of the y-range.\nNote it is using the range of the y-values. Not the number of values, as a quantile would do.\nOutput: (intercept, slope) or ReaderCurveFit object\n\n\n\n\n\n","category":"method"},{"location":"#PlateReaderCurves.rc_exp-NTuple{4,Any}","page":"Home","title":"PlateReaderCurves.rc_exp","text":"Exponentially asymptotic readercurve\nrc_exp(t,A,k,y0) = y0 + A(1 - exp(-t/k))\n\n\n\n\n\n","category":"method"},{"location":"#PlateReaderCurves.rc_fit-Tuple{ReaderCurve,String}","page":"Home","title":"PlateReaderCurves.rc_fit","text":"rc_fit(::ReaderCurve, method::String)\nFit a readercurve.\nReturns a ReaderCurveFit containing the original readercurve and a predict function that can be used to predict new values. It also contains Slope, intercept and mean residual.\nSee @ref ReaderCurveFit\nMethods:\n- linreg_trim: linear regression omitting y_low_pct and y_high_pct of y range.\n- max_slope:\n\n\n\n\n\n","category":"method"},{"location":"#RecipesBase.apply_recipe-Tuple{AbstractDict{Symbol,Any},ReaderCurveFit}","page":"Home","title":"RecipesBase.apply_recipe","text":"Plot a readercurve-fit\nplot(::ReaderCurveFit; marker_size=6)\n\n\n\n\n\n","category":"method"},{"location":"#RecipesBase.apply_recipe-Tuple{AbstractDict{Symbol,Any},ReaderCurve}","page":"Home","title":"RecipesBase.apply_recipe","text":"Plot a readercurve\nplot(::ReaderCurve; marker_size=6)\n\n\n\n\n\n","category":"method"}]
}
