using PlateReaderCurves
using Documenter

makedocs(;
    modules=[PlateReaderCurves],
    authors="Thomas Poulsen",
    repo="https://github.com/tp2750/PlateReaderCurves.jl/blob/{commit}{path}#L{line}",
    sitename="PlateReaderCurves.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://tp2750.github.io/PlateReaderCurves.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/tp2750/PlateReaderCurves.jl",
)
