# Non-linear fit

A smoothing Spline is a robust way to fit a general non-linear curve.
Below we test on a Hill-type curve with a slight initial convexity.

A nonlinear method is sensitive to scaling (ie units used fo measurement).
To avoid this, we re-scale before and after fitting.

We re-scale y to [0;1], and x to [0,N], where N is number of points.

Then numerical experimentation shows that a `lambda` of `1E-3` gives a good smoothing.

We see below (by plotting), that we can keep this value of `lambda` over a wide range of x-values and number of points.

This makes good sense: The lambda parameter penalizes the "total amount of acceleration" [wikipedia](https://en.wikipedia.org/wiki/Smoothing_spline):

$$
\minimize \sum_{i=1}^n \left(Y_i - \hat{f}(x_i) \right)^2 + \lambda \int \hat{f}^{''}(x)^2 dx
$$

By re-normalizing such that the x-difference between all points are about 1, and the total y-range is 1, the second derivative is on the same scale as the residuals.
If we rescale the x-range to be [0, 1], the "acceleration" will increase with the number of points.

So for the user interface, we should expose lambda and renormalization method, and default to "1-step" as renormalization, and lambda about 1E-3.
We should call `lambda` smoothing parameter, as it is `lambda` in the re-scaled case.


We are re-scaling the x and y values to [0,1] in a given range (or the observed values, if no ranges are given).
It is good practice to give the x- and y-range explicitly.
For absorbance, `y_range` = [0,4] and `x_range` = [0,1000] will be good, if x is measured in seconds.
Then a lambda value of 1E-6 is good.

```@example nnfit1
using PlateReaderCurves, Plots

A05_100 = PlateReaderCurves.sim_hill(;points = 5, well= "A0005_100");
A10_100 = PlateReaderCurves.sim_hill(;points = 10, well= "A0010_100");
A100_100 = PlateReaderCurves.sim_hill(;points = 100, well= "A0100_100");
A1000_100 = PlateReaderCurves.sim_hill(;points = 1000, well= "A1000_100");

plot(plot(A05_100), plot(A10_100),plot(A100_100),plot(A1000_100))

A05_100_fit_1 = rc_fit(A05_100, "smooth_spline";lambda = 1E-6, x_range = [0,1], y_range = [0,1]);
A05_100_fit_100 = rc_fit(A05_100, "smooth_spline";lambda = 1E-6, x_range = [0,100], y_range = [0,1]);

plot(plot(A05_100_fit_1),plot(A05_100_fit_100))

```
## Finding Lambda parameter

If we scale the normalization parameter `x_range` together with the range of x-values, we can keep `lambda = 1E-3` to get similar smoothing. 

```@example
using PlateReaderCurves, Plots
plot(
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 10, xmax=1, sd=.1, seed=123), "smooth_spline";lambda = 1E-3, x_range = [0,1], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 10, xmax=100, sd=.1, seed=123), "smooth_spline";lambda = 1E-3, x_range = [0,100], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 10, xmax=10000, sd=.1, seed=123), "smooth_spline";lambda = 1E-3, x_range = [0,10000], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=10000, sd=.1, seed=123), "smooth_spline";lambda = 1E-3, x_range = [0,10000], y_range = [0,1])),
  )
```

Check the phase-plots:

```@example
using PlateReaderCurves, Plots
plot(
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 10, xmax=1, sd=.1, seed=123), "smooth_spline";lambda = 1E-3, x_range = [0,1], y_range = [0,1])),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 10, xmax=100, sd=.1, seed=123), "smooth_spline";lambda = 1E-3, x_range = [0,100], y_range = [0,1])),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 10, xmax=10000, sd=.1, seed=123), "smooth_spline";lambda = 1E-3, x_range = [0,10000], y_range = [0,1])),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=10000, sd=.1, seed=123), "smooth_spline";lambda = 1E-3, x_range = [0,10000], y_range = [0,1])),
  )
```

Do the same with `lambda 1E-6`:


```@example
using PlateReaderCurves, Plots
plot(
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 10, xmax=1, sd=.1, seed=123), "smooth_spline";lambda = 1E-6, x_range = [0,1], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 10, xmax=100, sd=.1, seed=123), "smooth_spline";lambda = 1E-6, x_range = [0,100], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 10, xmax=10000, sd=.1, seed=123), "smooth_spline";lambda = 1E-6, x_range = [0,10000], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=10000, sd=.1, seed=123), "smooth_spline";lambda = 1E-6, x_range = [0,10000], y_range = [0,1])),
  )
```

Check the phase-plots:

```@example
using PlateReaderCurves, Plots
plot(
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 10, xmax=1, sd=.1, seed=123), "smooth_spline";lambda = 1E-6, x_range = [0,1], y_range = [0,1])),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 10, xmax=100, sd=.1, seed=123), "smooth_spline";lambda = 1E-6, x_range = [0,100], y_range = [0,1])),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 10, xmax=10000, sd=.1, seed=123), "smooth_spline";lambda = 1E-6, x_range = [0,10000], y_range = [0,1])),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=10000, sd=.1, seed=123), "smooth_spline";lambda = 1E-6, x_range = [0,10000], y_range = [0,1])),
  )
```


## Plot

We see below how well they fit.


The panels below are: 
* A07: no noise values
* A08: 1% noice added
* A09: subsampled every 10th read of A08

```@example nnfit3
using PlateReaderCurves, Plots
A07 = PlateReaderCurves.sim_hill(;points = 100, xmax = 1000, well= "A07", sd = 0.0, seed = 123);
A08 = PlateReaderCurves.sim_hill(;points = 100, xmax = 1000, well= "A08", sd = 0.01, seed = 123);
A09 = PlateReaderCurves.sim_hill(;points = 10, xmax = 1000, well= "A09", sd = 0.01, seed = 123);
A07_fit = rc_fit(A07, "smooth_spline";lambda = 1E-6, x_range = [0,1000], y_range = [0,1]);
A08_fit = rc_fit(A08, "smooth_spline";lambda = 1E-6, x_range = [0,1000], y_range = [0,1]);
A09_fit = rc_fit(A09, "smooth_spline";lambda = 1E-6, x_range = [0,100], y_range = [0,1]);

```

```@example nnfit3
plot(plot(A07_fit), plot(A08_fit), plot(A09_fit), link=:both, layout=(1,3), markersize = 2)
```

## Phase plot

The "phase plot" (slope vs y) shows more clearly how well the slope is fitted.


```@example nnfit3
plot(phaseplot(A07_fit), phaseplot(A08_fit), phaseplot(A09_fit), link=:both, layout=(1,3), markersize = 2)
```

## Residuals 
The mean absolute residual is similar to the noice we added.
We also get similar value from standard deviation:

```@example nnfit3
println(A08_fit.fit_mean_residual)

println(std(A08_fit.predict.(A08_fit.readercurve.kinetic_time) .- A08_fit.readercurve.reader_value))
```

# Slopeplot

We can also plot the slopes:

```@example
using PlateReaderCurves, Plots	
 PlateReaderCurves.slopeplot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=10000, sd=.1, seed=123), "smooth_spline";lambda = 1E-6, x_range = [0,10000], y_range = [0,1]))
```
