# Non-linear fit

A smoothing Spline is a robust way to fit a general non-linear curve.
Below we test on a Hill-type curve with a slight initial convexity.

We are re-scaling the x and y values to [0,1] in a given range (or the observed values, if no ranges are given).
It is good practice to give the x- and y-range explicitly.
For absorbance, `y_range` = [0,4] and `x_range` = [0,1000] will be good, if x is measured in seconds.
Then a lambda value of 1E-6 is good.

```@example nnfit
using PlateReaderCurves, Plots, Distributions, Random
t7 = collect(0:10:1000);
y7_1 = PlateReaderCurves.rc_exp.(t7, 1,200,0.05) ;
y7_2 = PlateReaderCurves.rc_exp.(t7, 1,100,0.05) ;
y7 = y7_1.*y7_2 
A07 = ReaderCurve(readerplate_well = "A07",
                      kinetic_time = t7,
                      reader_value = y7,
                      time_unit = "sec",
                      value_unit = "OD405nm",
                      );

t8 = collect(0:10:1000);
y8_1 = PlateReaderCurves.rc_exp.(t8, 1,200,0.05) ;
y8_2 = PlateReaderCurves.rc_exp.(t8, 1,100,0.05) ;
y8 = y8_1.*y8_2 .+ rand.(Normal.(0, .01));
A08 = ReaderCurve(readerplate_well = "A08",
                      kinetic_time = t8,
                      reader_value = y8,
                      time_unit = "sec",
                      value_unit = "OD405nm",
                      );

t9 = t8[1:10:100];
y9 = y8[1:10:100];
A09 = ReaderCurve(readerplate_well = "A09",
                      kinetic_time = t9,
                      reader_value = y9,
                      time_unit = "sec",
                      value_unit = "OD405nm",
                      );

A07_fit = rc_fit(A07, "smooth_spline";lambda = 1E-6, x_range = [0,1000], y_range = [0,1]);
A08_fit = rc_fit(A08, "smooth_spline";lambda = 1E-6, x_range = [0,1000], y_range = [0,1]);
A09_fit = rc_fit(A09, "smooth_spline";lambda = 1E-6, x_range = [0,1000], y_range = [0,1]);
```

The panels below are: 
* A07: no noise values
* A08: 1% noice added
* A09: subsampled every 10th read of A08


## Plot

We see below how well they fit.

```@example nnfit
plot(plot(A07_fit), plot(A08_fit), plot(A09_fit), link=:both, layout=(1,3), markersize = 2)
```

## Phase plot

The "phase plot" (slope vs y) shows more clearly how well the slope is fitted.


```@example nnfit
plot(phaseplot(A07_fit), phaseplot(A08_fit), phaseplot(A09_fit), link=:both, layout=(1,3), markersize = 2)
```

The mean absolute residual is similar to the noice we added.
We also get similar value from standard deviation:

```@example nnfit
println(A08_fit.fit_mean_residual)

println(std(A08_fit.predict.(A08_fit.readercurve.kinetic_time) .- A08_fit.readercurve.reader_value))
```
