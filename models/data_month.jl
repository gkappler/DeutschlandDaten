include("data.jl")
# splitticks(x) = ( [ e[1] for e in x], [ e[2] for e in x])

mordat = [ (alter=a, jahr=j, monat=monat, geschlecht=g,
            # interpolate for monat:
            N=population(popdata; alter=a, jahr=j, monat=monat, geschlecht=g),
            # interpolate with deaths for monat:
            # N=population(popdata, deathdat; alter=a, jahr=j, monat=monat, geschlecht=g),
            D=deaths(deathdat; alter=a, jahr=j, monat=monat, geschlecht=g))
           # TODO: integrate as population_deaths(popdata; alter=a, geschlecht=g, jahr=j, deaths=(monat=monat,) )
           for a in DeutschlandDaten.Altersgruppen_Monate
               for g in ["Männlich", "Weiblich"]
                   for j in 2000:2021
                       for monat in 1:12
                           ] |> DataFrame;

filter!(x-> x.D !==missing && x.D>0, mordat)
@transform! mordat :date = Date.(:jahr, :monat, 1)
# @transform! mordat :Ndiff = :N .- :Ns

@transform! mordat :group = collect(zip(:geschlecht, :alter))

# us = unstack(d[:,Symbol[:row,:col,:value]], :col, :value)

# @transform! groupby(mordat, :date) :stackedP = cumsum(:P_AG)

# P_AG: Wahrscheinlichkeit P(A=alter, G=geschlecht | T=date)
# PD: Wahrscheinlichkeit P(D = 1 | A=alter, G=geschlecht, T=date)
dataprep!(mordat)

