using Pkg
Pkg.activate(".")
using DeutschlandDaten
using Dates
using DataFrames
using StatsBase
    
deathdat = DeutschlandDaten.deaths_data()
popdat  = DeutschlandDaten.population()
popdatbl = DeutschlandDaten.population_bundesländer()

splitticks(x) = ( [ e[1] for e in x], [ e[2] for e in x])


mordat = [ 
    (
        alter = a,
        geschlecht=g, 
        jahr=j,
        kw = kw,
        # date = Date(j, monat, 1),
        # N=population(alter=a, geschlecht=g, jahr=j),
        N=convert(Int, round(population(popdat; alter=a, geschlecht=g, jahr=j))),
        D=deaths(deathdat, alter=a, geschlecht=g, jahr=j, kw=kw)
    )
        for a in DeutschlandDaten.Altersgruppen_KW
            for g in ["Männlich", "Weiblich"]
                for j in 2000:2021
                    for kw in 1:52
                        ] |> DataFrame;

mordat[:,:PD] = 10000 * mordat.D ./ mordat.N
mordat[:,:col] = collect(zip(mordat.jahr, mordat.geschlecht))
mordat[:,:row] = mordat.kw

alter=DeutschlandDaten.Altersgruppen_KW|>first
for alter=DeutschlandDaten.Altersgruppen_KW
    d = filter(x->x.alter==alter, mordat)
    us = unstack(d[:,[:row,:col,:PD]], :col, :PD)
    p = heatmap((Matrix(us[:,2:end]));
                title = "Sterberate Deutschland im Alter $alter von 10'000",
                yticks = 1:5:52,
                xticks = (vcat(1:5:22, 23:5:44), repeat(collect(string.(2000:5:2021)),2)),
                xrotation = -90,
                c = :reds )
    plot!([22.5]; seriestype=:vline, color=:black, legend=nothing, width=2)
    annotate!([(12,45,"Männlich"), (23+12,45,"Weiblich")])
    savefig(p, "images/Sterberate_$(alter).svg")
end

plotattr("extra_kwargs")
