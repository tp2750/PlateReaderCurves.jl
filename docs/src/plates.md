# Plotting plates

Often we have an xlsx file describing a run as a table.
This can be imported using the convenience function `xlsx`.
Then standard `DataFrames` and `DataFramesMeta` functions are used to give it ned proper column names:

```@example 2
using PlateReaderCurves, PlateReaderCore, Plots, DataFrames, DataFramesMeta
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
dat1_fit2 = rc_fit(dat1, "smooth_spline"; lambda = 1.0E-6)
dat1_fit2_Q2 = Q(dat1_fit2.readerplates[1], "Q2")
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
