using Pkg
Pkg.activate(".")
using DeutschlandDaten
using Dates
using DataFrames
using DataFramesMeta
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
        monat = monat,
        N=convert(Int, round(population(popdat; alter=a, geschlecht=g, jahr=j))),
        D=deaths(deathdat, alter=a, geschlecht=g, jahr=j, monat=monat)
    )
        for a in DeutschlandDaten.Altersgruppen_Monate
            for g in ["Männlich", "Weiblich"]
                for j in 2000:2021
                    for monat in 1:12
                        ] |> DataFrame;

mordat[:,:PD] = 10000 * mordat.D ./ mordat.N
mordat[:,:col] = collect(zip(mordat.jahr, mordat.geschlecht))
mordat[:,:row] = mordat.monat

function gliding_mean(x, window=12)
    y = Vector{Union{Missing,Float64}}(missing, length(x))
    for i in 1:length(x)
        y[i] = mean(skipmissing(x[max(1,i-div(window, 2)):min(end,i+window-div(window,2))]))
    end
    y
end
gliding_mean(mordat.PD)

@transform!(groupby(mordat, [:alter, :geschlecht]),
            :PD_12months = gliding_mean(:PD),
            :date = Date.(:jahr, :monat, 1)
            )

using StatsPlots
using Plots.PlotMeasures

savefig(plotyears(mordat), "images/Sterberaten.svg")

savefig(plotyears(filter(x-> x.date>=Date(2016,1,1), mordat)), "images/Sterberaten_2016_2021.svg")
for alter=DeutschlandDaten.Altersgruppen_Monate
    d = filter(x->x.alter==alter, mordat)
    us = unstack(d[:,[:row,:col,:PD]], :col, :PD)
    p = heatmap((Matrix(us[:,2:end]));
                title = "DE: Monatliche Sterberate, $alter alt, von 10'000",
                yticks = 1:12,
                xticks = (vcat(1:5:22, 23:5:44), repeat(collect(string.(2000:5:2021)),2)),
                xrotation = -90,
                c = :reds )
    plot!([22.5]; seriestype=:vline, color=:black, legend=nothing, width=2)
    annotate!([(12,10,"Männlich"), (23+12,10,"Weiblich")])
    savefig(p, "images/Sterberate_Monat_$(alter).svg")
end



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






mordat = ([ 
    (
        bundesland = bl,
        alter = a,
        geschlecht=g, 
        jahr=j,
        monat = m,
        date = Date(j, m, 28),
        N = convert(Int, round(population(popdatbl, deathdat; bundesland = bl, alter=a, geschlecht=g, jahr=j))),
        D = deaths(deathdat; bundesland = bl, alter=a, geschlecht=g, jahr=j, monat=m)
    )
    for bl in DeutschlandDaten.Bundesländer
        for a in DeutschlandDaten.Altersgruppen_Bundesländer
            for g in ["Männlich", "Weiblich"]
                for j in 2000:2021
                    for m in 1:12
                        ]) |> DataFrame;

@transform!(mordat,
            :PD = :D ./ :N,
            :col = collect(zip(:jahr, :geschlecht)),
            :row = collect(zip(:bundesland, :monat)))

function partifact(x, fact=10)
    sp = sortperm(x)
    r = Vector{Int}[[sp[1]]]
    for i in sp[2:end]
        if x[i] > x[r[end][1]] * fact
            push!(r,[i])
        else
            push!(r[end],i)
        end
    end
    r
end
    
alter = first(DeutschlandDaten.Altersgruppen_Bundesländer)
for (alter) = (DeutschlandDaten.Altersgruppen_Bundesländer)
    mean_PD = combine(groupby(filter(x->x.alter ==  alter, mordat), :bundesland),
                      :PD => x->mean(skipmissing(x)))
    for (i, bli) = enumerate(partifact(mean_PD[:,2],2))
        bls = mean_PD.bundesland[bli]
        d = filter(x->x.alter ==  alter && x.bundesland in bls, mordat)
        us = unstack(d[:,[:row,:col,:PD]], :col, :PD)
        p = heatmap((Matrix(us[:,2:end]));
                    yticks = splitticks([ (i, x[1]) for (i,x) in enumerate(us[:,1]) if x[2]==6 ]),
                    xticks = (1:5:22, collect(string.(2000:5:2021))),
                    c = :reds
                    )
        savefig(p, "images/Sterberate_$(alter)_$i.svg")
        println("$(alter)_$i: ", bls)
    end
end
