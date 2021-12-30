mordat = [ population_deaths(popdata;alter=a, geschlecht=g, jahr=j, deaths=(kw=kw,) )
           # or switch to interpolate deaths for kw:
           # population_deaths(alter=a, geschlecht=g, jahr=j, kw=kw )
           for a in DeutschlandDaten.Altersgruppen_KW,
               g in ["Männlich", "Weiblich"],
               j in 2000:2021,
               kw in 1:52 ] |> DataFrame;
filter!(x-> x.D !==missing && x.D>0, mordat)

@transform! mordat :date = endofweek.(:jahr,:kw)
dataprep!(mordat)

sort!(mordat, [:alter, :geschlecht, :date])
@transform! mordat :PD_12months = gliding_mean(:PD, div(52, 2))
@transform! mordat :PD_quarter = gliding_mean(:PD, div(52, 4))
