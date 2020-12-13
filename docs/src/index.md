```@meta
CurrentModule = PlateReaderCurves
```

# PlateReaderCurves

## Purpose

This package is for working with the output from optical platereaders.

## Status

This is very early development.

## Plans

* [X] Data structure to hold reader curve
* [X] Plots recipe to plot a reader curve
* [X] Functions to fit a model to the reader curve and extract the maximal slope
* [X] Data structure to hold a fit to the reader curve
* [X] Plots recipe to plot a creader curve together with the fit and derived slope
* [X] Data structure to hold a plate of reader curves, fits and slopes
* [ ] Plots Recipe to plot a plate of reader curves (and fits and slopes)
* [ ] Data structure to hold relative activity of 2 wells
* [ ] Plots recipe to plot relative activity of 2 wells
* [ ] Parsers for output files from readers I use
* [ ] Fit functions:
  - [X] Trimed linear regression
  - [X] Splite fit
  - [ ] B-spline fit
  - [ ] Exponential asymptote
  - [ ] 5 parameter logistic


# Tutorial

Create a reader curve and plot it:

```@example
using PlateReaderCurves, Plots
s1 = collect(0:10:100)
y1 = PlateReaderCurves.rc_exp(s1, 4, 100, 0.05)
A01 = ReaderCurve(well_name = "A01",
                      kinetic_time = s1,
                      reader_value = y1,
                      time_unit = "sec",
                      value_unit = "OD405nm",
                      )
plot(A01)
```

# Fitting a readercurve

Fitting a reader curve returns a ReaderCurveFit.
This contains the original reader curve, and the fitted function, which can be used for prediction.
It also contains the "slope" and "intercept" of the maximal slope of he fitted function in the observed x-range.

```@example
A01_fit = PlateReaderCurves.fit(A01,"linreg_trim")

collect(A01_fit.predict(1:10))

plot(A01_fit)
```

## Fitting methods

We implement different fitting methods:

* max_slope: maximal observed slope between adjacent measurements
* linreg_trim: linear regression. Optionally trimmed on fraction of y-range
* smooth_spline: smoothing spline fit

```@example
using SmoothingSplines
A01_fit = fit(A01,"linreg_trim");
A01_fit2 = fit(A01,"max_slope");
A01_fit3 = fit(A01,"smooth_spline"; lambda = 250);

plot(plot(A01), plot(A01_fit), plot(A01_fit2), plot(A01_fit3))
```

# API

```@index
```

```@autodocs
Modules = [PlateReaderCurves]
```

