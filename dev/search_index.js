var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = PlateReaderCurves","category":"page"},{"location":"#PlateReaderCurves","page":"Home","title":"PlateReaderCurves","text":"","category":"section"},{"location":"#Purpose","page":"Home","title":"Purpose","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This package is for working with the output from optical platereaders.","category":"page"},{"location":"#Status","page":"Home","title":"Status","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This is very early development.","category":"page"},{"location":"#Plans","page":"Home","title":"Plans","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"[X] Data structure to hold reader curve\n[X] Plots recipe to plot a reader curve\n[ ] Functions to fit a model to the reader curve and extract the maximal slope\n[ ] Data structure to hold a fit to the reader curve\n[ ] Plots recipe to plot a creader curve together with the fit and derived slope\n[ ] Data structure to hold a plate of reader curves, fits and slopes\n[ ] Plots Recipe to plot a plate of reader curves (and fits and slopes)\n[ ] Data structure to hold relative activity of 2 wells\n[ ] Plots recipe to plot relative activity of 2 wells\n[ ] Parsers for output files from readers I use","category":"page"},{"location":"#Tutorial","page":"Home","title":"Tutorial","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Create a reader curve and plot it:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using PlateReaderCurves, Plots\ns1 = collect(0:10:100)\ny1 = PlateReaderCurves.rc_exp(s1, 4, 100, 0.05)\nA01 = ReaderCurve(well_name = \"A01\",\n                      kinetic_time = s1,\n                      reader_value = y1,\n                      time_unit = \"sec\",\n                      value_unit = \"OD405nm\",\n                      )\nplot(A01)","category":"page"},{"location":"#API","page":"Home","title":"API","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [PlateReaderCurves]","category":"page"},{"location":"#PlateReaderCurves.ReaderCurve","page":"Home","title":"PlateReaderCurves.ReaderCurve","text":"ReaderCurve: Datastructure for holding reader curves\nFields:\nwell_name::String = \"well\"\nkinetic_time::Array\nreader_value::Array{Union{Missing, Real}}\nreader_temperature::Array{Union{Missing, Real}} = [missing]\ntime_unit::String\nvalue_unit::String\ntemperature_unit::String = \"C\"\n\n\n\n\n\n","category":"type"},{"location":"#PlateReaderCurves.rc_exp-NTuple{4,Any}","page":"Home","title":"PlateReaderCurves.rc_exp","text":"Exponentially asymptotic readercurve\nrc_exp(t,A,k,y0) = y0 + A(1 - exp(-t/k))\n\n\n\n\n\n","category":"method"},{"location":"#RecipesBase.apply_recipe-Tuple{AbstractDict{Symbol,Any},ReaderCurve}","page":"Home","title":"RecipesBase.apply_recipe","text":"Plot a readercurve\nplot(::ReaderCurve; marker_size=6)\n\n\n\n\n\n","category":"method"}]
}
