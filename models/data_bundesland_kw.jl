include("models/data.jl")

mordat = [ population_deaths(popdatbl; bundesland = bl, alter=a, geschlecht=g, jahr=j, deaths=(kw=kw,) )
           # or switch to interpolate deaths for kw:
           # population_deaths(alter=a, geschlecht=g, jahr=j, kw=kw )
           for bl in DeutschlandDaten.Bundesländer,
               a in DeutschlandDaten.Altersgruppen_Bundesländer,
               g in ["Männlich", "Weiblich"],
               j in 2000:2021,
               kw in 1:52 ] |> DataFrame;
filter!(x-> x.D !==missing && x.D>0, mordat)

@transform! mordat :date = endofweek.(:jahr,:kw)
dataprep!(mordat)

rowgroup=[:bundesland, :alter, :geschlecht]
@transform!(groupby(mordat, rowgroup),
            :PD_12months = gliding_mean(:PD, div(52, 2)),
            # :PD_rel2000 = :PD ./ first(skipmissing(:PD_12months)),
            :PD_relmean = :PD ./ mean(skipmissing(:PD))
#            :PD_rel_12months = :PD_12months ./ first(skipmissing(:PD_12months)),
#            :PD_relmean_12months = :PD_12months ./ mean(skipmissing(:PD_12months)),
            )



########################################
title = "Rythmen der Übersterblichkeit in %\nBundesländer Deutschland"
imagefile = "relative_Übersterblichkeit_Bundesländer"

## sortiere Bundesländer nach durchschnittlicher Übersterblichkeit 2020.6-2021.6
@transform!(groupby(mordat, :bundesland),
            :PDrelmean2021 = mean(:PD_relmean[(:date .< Date(2021,06,01)) .& (:date .> Date(2020,06,01))])
            )
sort!(mordat, [:PDrelmean2021, rowgroup..., :date])


@transform!(mordat, 
            :row = map(x->tuple(x...), eachrow(mordat[:,rowgroup])),
            :col = :date,
            :value = 100 .* :PD_relmean
            )

function plot_bl_PDrel(mordat)
    rs = unique(mordat.date)
    xticks = (1:52:length(rs), string.(year(minimum(mordat.date)):1:year(maximum(mordat.date))))
    p = plot_unstacked_heatmap(
        mordat,
        title = title,
        labelf = x -> let (b, a, g) = x; (a.start == 75 && g!="Weiblich" ? (b*"") : ""); end, # * (g!="Männlich" ? alterstring(a) : "") * label_geschlecht[g]; end,
        ylabel = "Bundesländer (Alter   ♂♀)",
        xticks = xticks,
        xrotation = -90,
        xmirror=true,
        c = tot_cgrad,
        top_margin = 20px,
        bottom_margin = 20px,
        w=1024px,
        h=1500px
        ##kw...
    ) do p, m
        @show blstarts = [ i-.5 for i in 1:size(m)[1] if i == 1 || m[i,1][1] != m[i-1,1][1] ]
        #@show m[blstarts,1]
        plot!(p,blstarts, seriestype = :hline, color = :black, legend=nothing)
        plot!(p, [findfirst(e -> e > Date(2021,1,1), rs)], alpha=.9, width=.5,
              seriestype=:vline)
        p
    end
end

p = plot_bl_PDrel(mordat)
   
DeutschlandDaten.savefigs(p,imagefile)

p = plot_bl_PDrel(filter(x -> x.date>Date(2016,1,1), mordat ))
DeutschlandDaten.savefigs(p,imagefile*"2016_2022")

