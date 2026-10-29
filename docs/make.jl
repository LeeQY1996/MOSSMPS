using Documenter
using MOSSQuantum
using MOSSQuantumMPS

makedocs(
    sitename = "MOSSQuantumMPS.jl",
    authors = "Guo Chu",
    pages = ["Home" => "index.md",
             "Getting started" => "gettingstarted.md",
             "States" => "states.md",
             "Core operations" => "coreops.md",
             "Observables and readout" => "observables.md",
             "Noise" => "noise.md",
             "Backend" => "backend.md"],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
)
