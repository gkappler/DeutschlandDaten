using StatsBase
using Plots.PlotMeasures

include("models/data.jl")
include("models/data_kw.jl")

sort!(mordat, [:alter, :geschlecht, :date])

@transform! mordat :PD = 10000 * :D ./ :N

@transform!(mordat,
            :col = collect(zip(:jahr, :geschlecht)),
            :row = :kw
            )

tot_cgrad = cgrad([:white, :black],[-.1,1]) # :reds
for alter=DeutschlandDaten.Altersgruppen_KW
    title = "Sterberate Deutschland im Alter $alter von 10'000"
    d = filter(x -> x.alter==alter, mordat)
    us = unstack(d[:,[:row,:col,:PD]], :col, :PD)
    p = heatmap((Matrix(us[:,2:end]));
                title = title,
                yticks = 1:5:52,
                xticks = (vcat(1:5:22, 23:5:44), repeat(collect(string.(2000:5:2021)),2)),
                xrotation = -90,
                c = tot_cgrad )
    plot!([22.5]; seriestype=:vline, color=:black, legend=nothing, width=2)
    annotate!([(12,45,"Männlich"), (23+12,45,"Weiblich")])
    savefig(p, "images/Sterberate_$(alter).svg")
end



@transform!(groupby(mordat, [:alter, :geschlecht]),
            :PD_rel = :PD ./ mean(skipmissing(:PD)),
            :PD_12months = gliding_mean(:PD),
            )

@transform!(groupby(mordat, [:alter, :geschlecht]),
            :PD_rel = :PD ./ first(skipmissing(:PD_12months)),
            :PD_relmean = :PD ./ mean(skipmissing(:PD)),
            :PD_rel_12months = :PD_12months ./ first(skipmissing(:PD_12months)),
            :PD_relmean_12months = :PD_12months ./ mean(skipmissing(:PD_12months)),
            )


# filter(x -> x.date>Date(2016,1,1), mordat)
function plot_sterbenszeiten(d; labelf, kw...)
    rs = unique(d.col)
    us = unstack(d[:,Symbol[:row,:col,:value]], :col, :value)
    @show names(us)
    yt = map(labelf, us[:,1])
    heatmap(Matrix(us[:,2:end]);
            yticks = (1:length(yt), yt),
            kw...)
end


plot_sterbenszeiten(
    @transform(mordat, 
               :row = collect(zip(:geschlecht, :alter)),
               :col = :date,
               :value = 100 .* :PD_relmean
               ),
    title = "Rythmen der Übersterblichkeit in %\nBundesrepublik Deutschland",
    labelf = x -> let (g,a) = x; (g!="Männlich" ? (alterstring(a)*"    ") : "") * label_geschlecht[g]; end,
    ylabel = "Alter   ♂♀",
    xticks = (1:52:length(rs), string.(2000:1:2021)),
    xrotation = -90,
    xmirror=true,
    c = tot_cgrad,
    top_margin = 20px,
    bottom_margin = 20px,
)
plotquelle!(; subplot = 2)

savefig("images/relative_Übersterblichkeit.svg")
savefig("images/relative_Übersterblichkeit.png")


# Kohorten-Linien
kohdat = filter(x-> rem(x.geburt,10)==0 ,
                DataFrame([ (geburt = j - x.start, woche = 1+52*(j-2000), alter_von = i*2-1.5)
                            for (i,x) in enumerate(DeutschlandDaten.Altersgruppen_KW)
                                for j in 2000:2021 ]))
@df kohdat plot!(:woche, :alter_von, group=:geburt, c=:white, legend=nothing)
annotate!([ ( x[end,:woche], x[end,:alter_von], ("* $(x[end,:geburt])", 7, :left, :bottom, :white)) for x in groupby(kohdat, :geburt)
               if size(x)[1]>1])

savefig("images/relative_Übersterblichkeit_kohorten.svg")
savefig("images/relative_Übersterblichkeit_kohorten.png")
