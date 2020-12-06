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
* [ ] Functions to fit a model to the reader curve and extract the maximal slope
* [ ] Data structure to hold a fit to the reader curve
* [ ] Plots recipe to plot a creader curve together with the fit and derived slope
* [ ] Data structure to hold a plate of reader curves, fits and slopes
* [ ] Plots Recipe to plot a plate of reader curves (and fits and slopes)
* [ ] Data structure to hold relative activity of 2 wells
* [ ] Plots recipe to plot relative activity of 2 wells
* [ ] Parsers for output files from readers I use


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

# API

```@index
```

```@autodocs
Modules = [PlateReaderCurves]
```

