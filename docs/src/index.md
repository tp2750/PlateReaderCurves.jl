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
* [X] Plots Recipe to plot a plate of reader curves (and fits and slopes)
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

```@example 1
using PlateReaderCurves, Plots
s1 = collect(0:10:100)
y1 = PlateReaderCurves.rc_exp(s1, 4, 100, 0.05)
A01 = ReaderCurve(readerplate_well = "A01",
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

```@example 1
A01_fit = PlateReaderCurves.rc_fit(A01,"linreg_trim")

collect(A01_fit.predict.(1:10))

plot(A01_fit)
```

## Fitting methods

We implement different fitting methods:

* max_slope: maximal observed slope between adjacent measurements
* linreg_trim: linear regression. Optionally trimmed on fraction of y-range
* smooth_spline: smoothing spline fit

```@example 1
using SmoothingSplines
A01_fit = rc_fit(A01,"linreg_trim");
A01_fit2 = rc_fit(A01,"max_slope");
A01_fit3 = rc_fit(A01,"smooth_spline"; lambda = 250);

plot(plot(A01), plot(A01_fit), plot(A01_fit2), plot(A01_fit3))
```

# Missing values

For some types of experiments, the reader can not report a value, but only that the value is OVERFLOW or UNDERFLOW.
There are represented as `Inf` and `-Inf` respectively.
Values missing for other reasons are encoded as `NaN`.
In this way, we stay within the floating point types.

Non-finite values are ignored in fitting and plotted at the max (`Inf`) or min (`-Inf`) of the other values or 0 for `NaN`.
All `Inf` curves are plotted at 1 and all `-Inf` curves are plotted at 0.

```@example 
using PlateReaderCurves, Plots
s1 = collect(0:.1:2)
A02 = ReaderCurve(readerplate_well = "A02",
	kinetic_time = s1,
	reader_value = replace( 2 .* s1, .6 => NaN, 1.2 => Inf, 1.4=> -Inf),
	time_unit = "sec",
	value_unit = "OD405nm",
)
A02_fit1 = rc_fit(A02, "linreg_trim")
plot(plot(A02), plot(A02_fit1))
```

```@example 
using PlateReaderCurves, Plots
s1 = collect(0:.1:2)
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
plot(plot(A03), plot(A04), plot(A05))
```

# Plotting plates

Often we have an xlsx file describing a run as a table.
This can be imported using the convenience function `xlsx`.
Then standard `DataFrames` and `DataFramesMeta` functions are used to give it ned proper column names:

```@example 2
using PlateReaderCurves, Plots, DataFrames, DataFramesMeta
dat1_df = xlsx("../../test/dat1.xlsx"; sheet=1)
dat1 = ReaderRun(
	@transform(
		rename(dat1_df, :well_name => :readerplate_well, 
			:geometry => :readerplate_geometry, 
			:kinetic_sec => :kinetic_time, 
			:absorbance_value => :reader_value, 
			:reader_temperature_C => :reader_temperature), 
	equipment = "Neo2", 
	software="Gen5", 
	run_starttime = missing,
	time_unit = "sec", 
	value_unit = "OD405nm", 
	temperature_unit="C",
	readerplate_id = :readerfile_name, 
));
# plateplot(dat1.readerplates[1])
length(dat1)
```

We can fit slopes to all plates in a run:

```@example 2
dat1_fit1 = rc_fit(dat1, "linreg_trim")
# plateplot(dat1_fit1.readerplates[1])
```

We can filter a plate (or a fitted plate), to only show a single quadrant (See [MTP.jl](https://tp2750.github.io/MTP.jl/dev/) for the quardant concept):

```@example 2
dat1_fit1_Q3 = Q(dat1_fit1.readerplates[1], "Q3")
plateplot(dat1_fit1_Q3)
```

Setting the `well96` keyword to `true` in the `Q` function renames the wells to the corresponding well names on a 96 well plate (see  [MTP.jl](https://tp2750.github.io/MTP.jl/dev/) if this sounds strange):

```@example 2
dat1_fit1_Q3 = Q(dat1_fit1.readerplates[1], "Q3"; well96 = true)
plateplot(dat1_fit1_Q3)
```

# Phase space plot

A good way to look at reader curves is in "phase space": slope vs reader_value.
Often smoothing is essential for a good result.

The blue curve are the raw pointwise slopes, the green curve are the slope from the fitted model, and the red horizontal line is the reported "slope".

```@example 2
dat1_fit2 = rc_fit(dat1, "smooth_spline"; lambda = 1.0E6)
dat1_fit2_Q2 = Q(dat1_fit2, "Q2")
plateplot(dat1_fit2_Q2, type = "phase", y_fixed=false)	
```

```@example 2
plateplot(dat1_fit2_Q2, type = "phase", y_fixed=true)	
```
## Comparing fitting

The plots below compares the linear fir and the smoothing spline fit.

### Smoothing Spline:

```@example 2
plot(
  plot(phaseplot(well(dat1_fit2.readerplates[1], "A13")),phaseplot(well(dat1_fit2.readerplates[1], "A15")), link = :all), 
  plot(plot(well(dat1_fit2.readerplates[1], "A13")),plot(well(dat1_fit2.readerplates[1], "A15")), link=:all), 
layout = (2,1))
```

### Linear regression

```@example 2
plot(
  plot(phaseplot(well(dat1_fit1.readerplates[1], "A13")),phaseplot(well(dat1_fit1.readerplates[1], "A15")), link = :all), 
  plot(plot(well(dat1_fit1.readerplates[1], "A13")),plot(well(dat1_fit1.readerplates[1], "A15")), link=:all), 
layout = (2,1))
```

# Relative Activity




# API

```@index
```

```@autodocs
Modules = [PlateReaderCurves]
```

