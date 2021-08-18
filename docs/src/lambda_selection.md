# Lambda: Find the "optimal" value

Can we automatically find the best `lambda` parameter?

What should "best" mean?

One way is to simulate data with noice, and see how well we filter out the noice depending on the lambda.
With a bit of luck, we can find an automatic way to do this.

## Algorithm:

* Sample a cureve
* Add noice
* fit smooth curve
* Evaluate residual of predicted values to known curve.

```@example ex1
using PlateReaderCore, PlateReaderCurves, DataFrames, DataFramesMeta

A1 =  PlateReaderCore.sim_hill(;points = 10, xmax=1, sd=0.0, seed=123, well= "A01", convex=.25, concave=.75)
A1_fit = rc_fit(A1, "smooth_spline")
lambdas = 0:1E-3:0.025
method = "smooth_spline"
samples = 100
sd = .2
keep_fraction = 1.0

res = DataFrame()
for l in lambdas
	push!(res, PlateReaderCore.cross_validate(A1, method, samples, sd, keep_fraction; lambda = l))
end
@with(res, plot(:lambda, :mean_residual_mean, title="Validation error, sd = $sd, dx = 0.1"))

```

* From the curve it looks like a curve with an x-difference of 0.1 and y-difference .2 has an optimal lambda of 0.01.
* I expect lambda to depend on the noice variation relative to the true variation between points.
