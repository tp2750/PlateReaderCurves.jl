# Lambda: effect of scaling

In this section we look more at the effect of rescaling and smoothing.



## Normalization

We use the scale_fwd function to map the first range to the second range.
Normally, the first range will be the range of the given varibale.
We need this as a parameter, as we want to be able to apply this function to a single point, not just a range.


```{julia}
julia> PlateReaderCurves.scale_fwd(collect(0.:10.),[0,10],[0,1])
11-element Array{Float64,1}:
 0.0
 0.1
 0.2
 0.30000000000000004
 0.4
 0.5
 0.6000000000000001
 0.7000000000000001
 0.8
 0.9
 1.0

julia> PlateReaderCurves.scale_fwd(collect(0.:10.),[0,10],[0,10])
11-element Array{Float64,1}:
  0.0
  1.0
  2.0
  3.0
  4.0
  5.0
  6.0
  7.0
  8.0
  9.0
 10.0
```

## Scaling to [0,1]

Sample 100 points. 
We see, that by normalizing x and y to be in [0,1], we can use the same lambda independently of the original axes.


```@example
using PlateReaderCurves, Plots
plot(
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=1, sd=.1, seed=123, well= "A01"), "smooth_spline";lambda = 1E-3, x_range = [0,1], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=1, sd=.1, seed=123, well= "A01"), "smooth_spline";lambda = 1E-3, x_range = [0,1], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=100, sd=.1, seed=123, well= "A02"), "smooth_spline";lambda = 1E-3, x_range = [0,1], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=100, sd=.1, seed=123, well= "A02"), "smooth_spline";lambda = 1E-3, x_range = [0,1], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=10000, sd=.1, seed=123, well= "A03"), "smooth_spline";lambda = 1E-3, x_range = [0,1], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=10000, sd=.1, seed=123, well= "A03"), "smooth_spline";lambda = 1E-3, x_range = [0,1], y_range = [0,1])),
  )
```

This would not work without scaling

```@example
using PlateReaderCurves, Plots
plot(
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=1, sd=.1, seed=123, well= "A01"), "smooth_spline";lambda = 1E-3, x_range = missing, y_range = missing),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=1, sd=.1, seed=123, well= "A01"), "smooth_spline";lambda = 1E-3, x_range = missing, y_range = missing)),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=100, sd=.1, seed=123, well= "A02"), "smooth_spline";lambda = 1E-3, x_range = missing, y_range = missing),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=100, sd=.1, seed=123, well= "A02"), "smooth_spline";lambda = 1E-3, x_range = missing, y_range = missing)), 
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=10000, sd=.1, seed=123, well= "A03"), "smooth_spline";lambda = 1E-3, x_range = missing, y_range = missing),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=10000, sd=.1, seed=123, well= "A03"), "smooth_spline";lambda = 1E-3, x_range = missing, y_range = missing)),
  )
```

What happens if we sample more or less points:


```@example
using PlateReaderCurves, Plots
x_max = 1E6
l_val = 1E-3
plot(
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 10, xmax=x_max, sd=.1, seed=123, well= "A01"), "smooth_spline";lambda = l_val, x_range = [0,1], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 10, xmax=x_max, sd=.1, seed=123, well= "A01"), "smooth_spline";lambda = l_val, x_range = [0,1], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=x_max, sd=.1, seed=123, well= "A02"), "smooth_spline";lambda = l_val, x_range = [0,1], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=x_max, sd=.1, seed=123, well= "A02"), "smooth_spline";lambda = l_val, x_range = [0,1], y_range = [0,1])), 
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=x_max, sd=.1, seed=123, well= "A03"), "smooth_spline";lambda = l_val, x_range = [0,1], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=x_max, sd=.1, seed=123, well= "A03"), "smooth_spline";lambda = l_val, x_range = [0,1], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=x_max, sd=0, seed=123, well= "clean"), "smooth_spline";lambda = l_val, x_range = [0,1], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=x_max, sd=0, seed=123, well= "clean"), "smooth_spline";lambda = l_val, x_range = [0,1], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=x_max, sd=0, seed=123, well= "true"), "smooth_spline";lambda = 0, x_range = [0,1], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=x_max, sd=0, seed=123, well= "true"), "smooth_spline";lambda = 0, x_range = [0,1], y_range = [0,1])),
  )
```

In the plot above, we have kept the underlying model the same (hill curve over [0,1E6]), and varied the number of points sampled.
The "clean" case is without noice. We see that in that case, we get over smoothing.

Otherwise, normalizing to [0,1] and keepin lambda at 1E-3 looks good.

What if we change lambda?

```@example
using PlateReaderCurves, Plots
x_max = 1E6
l_val = 1E-6
plot(
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 10, xmax=x_max, sd=.1, seed=123, well= "A01"), "smooth_spline";lambda = l_val, x_range = [0,1], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 10, xmax=x_max, sd=.1, seed=123, well= "A01"), "smooth_spline";lambda = l_val, x_range = [0,1], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=x_max, sd=.1, seed=123, well= "A02"), "smooth_spline";lambda = l_val, x_range = [0,1], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=x_max, sd=.1, seed=123, well= "A02"), "smooth_spline";lambda = l_val, x_range = [0,1], y_range = [0,1])), 
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=x_max, sd=.1, seed=123, well= "A03"), "smooth_spline";lambda = l_val, x_range = [0,1], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=x_max, sd=.1, seed=123, well= "A03"), "smooth_spline";lambda = l_val, x_range = [0,1], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=x_max, sd=0, seed=123, well= "clean"), "smooth_spline";lambda = l_val, x_range = [0,1], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=x_max, sd=0, seed=123, well= "clean"), "smooth_spline";lambda = l_val, x_range = [0,1], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=x_max, sd=0, seed=123, well= "true"), "smooth_spline";lambda = 0, x_range = [0,1], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=x_max, sd=0, seed=123, well= "true"), "smooth_spline";lambda = 0, x_range = [0,1], y_range = [0,1])),
  )
```
Then we overestimate the slope if we have many samples close together.

What does it mean to be close?

That means that the increase in y between samples is not significantly larger than the noice.
We need to set up our experiment, so that the increase in y is larger than the noice. 
We can always get this by subsampling, unless there is no actual activity!



## Scaling to x-step = 1

How does it look if we scale all x-stept to 1?


```@example
using PlateReaderCurves, Plots
l_val = 1E3	
plot(
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=1, sd=.1, seed=123, well= "A01"), "smooth_spline";lambda = l_val, x_range = [0,100], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=1, sd=.1, seed=123, well= "A01"), "smooth_spline";lambda = l_val, x_range = [0,100], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=100, sd=.1, seed=123, well= "A02"), "smooth_spline";lambda = l_val, x_range = [0,100], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=100, sd=.1, seed=123, well= "A02"), "smooth_spline";lambda = l_val, x_range = [0,100], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=10000, sd=.1, seed=123, well= "A03"), "smooth_spline";lambda = l_val, x_range = [0,100], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=10000, sd=.1, seed=123, well= "A03"), "smooth_spline";lambda = l_val, x_range = [0,100], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=x_max, sd=0, seed=123, well= "clean"), "smooth_spline";lambda = l_val, x_range = [0,100], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=x_max, sd=0, seed=123, well= "clean"), "smooth_spline";lambda = l_val, x_range = [0,100], y_range = [0,1])),
  )
```
This has same effect as scaling to [0,1] but for different lambda.

How about sub-sampling?


```@example
using PlateReaderCurves, Plots
x_max = 1E6
l_val = 1E3
plot(
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 10, xmax=x_max, sd=.1, seed=123, well= "A01"), "smooth_spline";lambda = l_val, x_range = [0,10], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 10, xmax=x_max, sd=.1, seed=123, well= "A01"), "smooth_spline";lambda = l_val, x_range = [0,10], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=x_max, sd=.1, seed=123, well= "A02"), "smooth_spline";lambda = l_val, x_range = [0,100], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=x_max, sd=.1, seed=123, well= "A02"), "smooth_spline";lambda = l_val, x_range = [0,100], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=x_max, sd=.1, seed=123, well= "A03"), "smooth_spline";lambda = l_val, x_range = [0,1000], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=x_max, sd=.1, seed=123, well= "A03"), "smooth_spline";lambda = l_val, x_range = [0,1000], y_range = [0,1])),
  plot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=x_max, sd=0, seed=123, well= "clean"), "smooth_spline";lambda = l_val, x_range = [0,1000], y_range = [0,1]),markersize=1),
  phaseplot(rc_fit(PlateReaderCurves.sim_hill(;points = 1000, xmax=x_max, sd=0, seed=123, well= "clean"), "smooth_spline";lambda = l_val, x_range = [0,1000], y_range = [0,1])),
  )
```

Then we get too little smoothing with few points.

## Compare to theory

We normalize to [0,1] and look at the effect of sample number and lambda on slope and residuals.
The theoretical slope is 13.5 and the expected average residul is 0.08 (0.798 * std-dev).

We vary number of samples and smoothing.

```@example
using PlateReaderCurves, Plots,DataFrames, DataFramesMeta
my_fitter(points, lambda; xmax = 1, sd=.1,seed = 123) = rc_fit(PlateReaderCurves.sim_hill(;points = points, xmax=xmax, sd=sd, seed=seed, well= ""), "smooth_spline";lambda = lambda, x_range = [0,1], y_range = [0,1])

experiment = rename(DataFrame(Base.Iterators.product([10,100,1000,10000], [1E-3,1E-4, 1E-5,1E-6, 0])), ["points","lambda"])

@eachrow experiment begin 
  @newcol slope::Vector{Float64} 
  @newcol resid::Vector{Float64} 
  my_e = my_fitter(:points, :lambda) 
  :slope = my_e.slope 
  :resid = my_e.fit_mean_absolute_residual 
end
```

lambda in 1E-3 to 1E-4 looks reasonable.

Can we estimate how much we under-estimate with few samples?


## Getting the sample rate right

Suppose the noice is 0.1, and we sample so often, that the true development in y is less than 0.1.
Then our slopes between samples will be dominated by the noice.

We can reduce this noice by smoothing.


## Evaluate on area under curve

We look at the ratio of the fit curve relative to the actual curve.

```@example
using PlateReaderCurves
print(area_under_curve_ratio(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=1, sd=.1, seed=123, well= "A01"), "smooth_spline";lambda = 1E-3, x_range = [0,1], y_range = [0,1])))
print(area_under_curve_ratio(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=1, sd=.1, seed=123, well= "A01"), "smooth_spline";lambda = 1E-3, x_range = [0,1], y_range = [0,1])))
print(area_under_curve_ratio(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=100, sd=.1, seed=123, well= "A02"), "smooth_spline";lambda = 1E-3, x_range = [0,1], y_range = [0,1])))
print(area_under_curve_ratio(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=100, sd=.1, seed=123, well= "A02"), "smooth_spline";lambda = 1E-3, x_range = [0,1], y_range = [0,1])))
print(area_under_curve_ratio(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=10000, sd=.1, seed=123, well= "A03"), "smooth_spline";lambda = 1E-3, x_range = [0,1], y_range = [0,1])))
print(area_under_curve_ratio(rc_fit(PlateReaderCurves.sim_hill(;points = 100, xmax=10000, sd=.1, seed=123, well= "A03"), "smooth_spline";lambda = 1E-3, x_range = [0,1], y_range = [0,1])))
  )
```
