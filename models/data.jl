using Pkg
Pkg.activate(".")
using DeutschlandDaten
using Dates
using DataFrames
using DataFramesMeta
using StatsBase
using Distributions
using StatsFuns

using StatsPlots
using Plots.PlotMeasures
    
deathdat = DeutschlandDaten.deaths_data()
popdata  = DeutschlandDaten.population()
popdatbl = DeutschlandDaten.population_bundesländer()

population_deaths(p, d=deathdat; deaths=tuple(), population=tuple(), kw...) =
    ( kw...,
      deaths...,
      population...,
      N=DeutschlandDaten.population(p,d; population..., kw...),
      D=DeutschlandDaten.deaths(d; deaths..., kw...)
      )


function dataprep!(mordat)
    @transform! mordat :geburt_start = :jahr .- rangestart.(:alter)
    @transform! mordat :kohorte = div.(:geburt_start, 10) * 10
    @transform! mordat :PD = :D ./ :N
    @transform! mordat :logitPD = logit.(:PD)
end

