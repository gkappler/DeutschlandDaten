include("models/data_month.jl")

function referenceP_AG(mordat)
    @combine(groupby(mordat,:group),
             :referenceP_AG = mean(:P_AG)
             )
end

function referenceP_AG(mordat,date)
    @select(filter(x->x.date==date, mordat),
            :group,
            :referenceP_AG = :P_AG
            )
end

# (@transform referenceP_AG(mordat, Date(2000,1,1)) :marginalN = 80e6 .* :referenceP_AG)[:,end] |> sum
function adjustierte_sterbefälle(mordat, rP, Ntotal = @combine(groupby(mordat,[:jahr,:monat]), :Ntotal=sum(:N)))
    margmordat = leftjoin(mordat[:,[:jahr, :monat, :group, :P_AG, :PD, :D]], rP, on=:group)
    margmordat = leftjoin(margmordat, Ntotal, on=[:jahr,:monat])
    @transform! margmordat :PDreferenceP_AG = :PD .* :referenceP_AG

    perMonat = @combine(groupby(margmordat, [:jahr,:monat]),
                        :adjD = sum(:PD .* :referenceP_AG) * :Ntotal[1],
                        :D = sum(:D),
                        :adjPD = sum(:PD .* :referenceP_AG))
    #)
end

Ntotal = @combine(groupby(mordat,[:jahr,:monat]), :Ntotal=sum(:N))
@transform! groupby(mordat, :date) :P_AG = :N ./ sum(:N)

#@transform! groupby(mordat,:date) :stackedN = cumsum(:N)


ag_col=let na = length(DeutschlandDaten.Altersgruppen_Monate)
    m = cgrad([:lightblue, :gray],na+5; scale=:log)
    w = cgrad([:lightpink, :gray],na+5; scale=:log)
    vcat([ [ m[x], w[x] ] for x in 1:na ]...)' 
end

let title="Demographische Anteile (kumulative %)\nder Bundesrepublik Deutschland der Jahre",
    file = "Demographie_Deutschland_Prozent",
    p = @df mordat yearsareaplot(:date,  100 * :P_AG, :group;
                                 title=title,
                                 seriescolor=ag_col,
                                 ylim=(00,100), yticks=0:10:100, linecolor=:black, rightmargin=40px, bottommargin=20px)
    plot!(twinx(),yticks = 0:10:100,
          ylim=(00,100), xlim=(Date(2000,1,1),Date(2021,12,1)),
          ymirror=true, xticks=nothing,
          rightmargin=100px
          )
    DeutschlandDaten.savefigs(p, file, data = "Datenquelle: Statistisches Bundesamt Code: 12411-0006")
end

let title="Demographie (Bevölkerungszahl)\nder Bundesrepublik Deutschland der Jahre",
    file = "Demographie_Deutschland_interpoliert",
    yt = 0:8,
    yl=(00,85e6),
    plotattrs = (yticks = (1e7*yt, convert.(Int,10*yt)), ylim=yl, rightmargin=40px, bottommargin=20px)
    p = @df filter(x->x.date <= Date(2020,1,1), mordat) yearsareaplot(:date, :N, :group;
                                                                      title=title,
                                                                      seriescolor=ag_col,
                                                                      ylabel="Millionen",
                                                                      linecolor=:black,
                                                                      plotattrs...)
    plot!(twinx(); xlim=(Date(2000,1,1),Date(2021,1,1)),
          ymirror=true, xticks=nothing,
          plotattrs...
              )
    DeutschlandDaten.savefigs(p, file, data = "Datenquelle: Statistisches Bundesamt Code: 12411-0006")
end


let title="Sterbezahlen\n Bundesrepublik Deutschland",
    file = "Sterbezahlen_Deutschland_monatlich"
    p = @df mordat yearsareaplot(:date, :D, :group; legend=nothing, seriescolor=ag_col, linecolor=:black, yticks=(0000:10000:100000, 0:10:100),
                             title=title,
                             ylabel="Tausend / Monat",
                             annotation_margin =-500, xlim=(Date(1998,5,1),Date(2023,7,1)))
    DeutschlandDaten.savefigs(p, file)
    p
end

if false
    @df @combine(groupby(mordat,:date), :D = sum(:D)) plot(:date, :D, seriestype=:bar, legend=nothing, fillcolor=:black, linecolor=:darkgray, linewidth=.001)
end

let title = "Verstorbenenzahl, Demographie-adjustiert\nBundesrepublik Deutschland",
    file = "adjustierte_Sterbezahlen_Deutschland_monatlich"
    p= @df @combine(groupby(mordat,:date), :D = sum(:D)) plot(; legend=nothing, fillcolor=:black, linecolor=:black, linewidth=2, ylim=(0,130000/1000),
                                                              title =title,
                                                              ylabel="Tausend / Monat",
                                                              xticks=([Date(y,1,1) for y in 2000:2021], 2000:2021),
                                                              xrotation=90, xmirror=true,
                                                              topmargin=30px)
    for j in (2021,2000)
        rP = referenceP_AG(filter(x->x.jahr == j,mordat))
        sp = filter(x->x.jahr in 2000:2021, adjustierte_sterbefälle(mordat, rP, Ntotal))
        faktor = mean(filter(x->x.jahr==j, Ntotal).Ntotal)#lastD/sp.adjPD[end]
        @df sp plot!(p, Date.(:jahr,:monat,1), :adjPD .* faktor/1000, label="auf Demographie $j adjustiert", width=1)
    end
    @df @combine(groupby(mordat,:date), :D = sum(:D)) plot!(p,:date, :D/1000, legend=:bottomright, label="offizielle Sterbefallzahl", fillcolor=:black, linecolor=:black, linewidth=2)
    DeutschlandDaten.savefigs(p, file)
    p
end
@df @combine(groupby(mordat,:date), :D = sum(:D)) plot!(p,:date, :D/1000, legend=:bottomright, label="offizielle Sterbefallzahl", fillcolor=:black, linecolor=:black, linewidth=2)
p
DeutschlandDaten.savefigs(p, "adjustierte_Sterbezahlen_Deutschland_monatlich")

if false
j=2021
d = adjustierte_sterbefälle(mordat, referenceP_AG(filter(x->x.jahr == j,mordat)), Ntotal)
@transform! d :adjD_24m = gliding_mean(:adjD,12,0)

@df d plot(Date.(:jahr,:monat,1), :adjD )

@df d plot(Date.(:jahr,:monat,1), :adjD ./ :adjD_24m )

@df d plot(:monat, :adjD; group=:jahr, linecolor=[ getindex(cgrad(:reds,22),j-2000+1) for j in :jahr], legend=nothing )

p = @df filter(x->x.jahr in 2010:2019,d) boxplot(:monat, :adjD, :jahr, alpha=.25, label="2010-2019",
                                             title="Adjustierte Sterbezahlen\nBundesrepublik Deutschland",
                                             topmargin=10px,
                                             ylabel="Tausend",
                                             xticks=(1:12,DeutschlandDaten.monattick),
                                             ylim=10000 .* (7,13),
                                             yticks=let tsd=7:13; (10000*tsd, 10*tsd); end)                                              
@df filter(x->x.jahr in 2000:2009,d) boxplot!(:monat, :adjD, :jahr, alpha=.1, label="2000-2009",
                                              xticks=(1:12,DeutschlandDaten.monattick),
                                              ylim=10000 .* (7,13),
                                              yticks=let tsd=7:13; (10000*tsd, 10*tsd); end)                                              
@df filter(x->x.jahr in 2020:2021,d) plot!(:monat, :adjD; group=:jahr, legend=:topright, width=2)
    # @df filter(x->x.jahr in 2020:2021,d) plot!(:monat, :D; group=:jahr, legend=:topright, width=2)
DeutschlandDaten.savefigs(p, "adjustierte_Sterbezahlen_2020_2021_monatlich")
    

@df filter(x->x.jahr in 2010:2019,mordat) plot(; title="Adjustierte Sterbezahlen\nBundesrepublik Deutschland",
                                               topmargin=10px,
                                               ylim=(-10,1),
                                               xlim=(1,12),
                                               xticks=(1:12,DeutschlandDaten.monattick))

for a in DeutschlandDaten.Altersgruppen_Monate
    d = filter(x->x.alter==a && x.geschlecht=="Männlich",mordat)
    p = @df filter(x -> x.jahr in 2010:2019,d) boxplot(:monat, :PD; group=:group, alpha=.25, label="2010-2019", bar_width=[1,1],
                                                   title="Sterbewahrscheinlichkeit $(alterstring(a))",
                                                   xlim=(0,13),
                                                   xticks=(1:12,DeutschlandDaten.monattick))
    @df filter(x -> x.jahr in 2000:2009,d) boxplot!(:monat, :PD; group=:group, alpha=.25, label="2000-2009", bar_width=[1,1],
                                                    xlim=(0,13),
                                                    xticks=(1:12,DeutschlandDaten.monattick))
    @df filter(x -> x.jahr in 2020:2021,d) plot!(:monat, :PD; group=:jahr, width=1)
    DeutschlandDaten.savefigs(p, "Sterbewahrscheinlichkeit_$a")
end

    
@df filter(x->x.geschlecht=="Männlich" && x.jahr in 2000:2019,mordat) groupedboxplot(:monat, :logitPD; group=:group, alpha=.25, label="2010-2019", bar_width=[1,1],
                                               xlim=(0,13),
                                               xticks=(1:12,DeutschlandDaten.monattick))

plot([
begin
    p = @df filter(x->x.geschlecht==g && x.jahr in 2000:2019,mordat) boxplot(:monat, :logitPD; group=:group, alpha=.25, label="2010-2019", bar_width=[1,1],
                                                                             xrotation=90,
                                                                             color=:gray, linecolor=:darkgray,
                                                                             markersize=.5,
                                                                             xlim=(0,13),
                                                                             xticks=(1:12,DeutschlandDaten.monattick))
    # p = @df filter(x->x.geschlecht==g && x.jahr in 2000:2009,mordat) boxplot!(:monat, :logitPD; group=:group, alpha=.15, label="2010-2019", bar_width=[1,1],
    #                                                                          xrotation=90,
    #                                                                          color=:green, linecolor=:darkgreen,
    #                                                                          markersize=.5,
    #                                                                          xlim=(0,13),
    #                                                                          xticks=(1:12,DeutschlandDaten.monattick))
    @df filter(x->x.geschlecht==g && x.jahr in 2020:2021,mordat) plot!(:monat, :logitPD; group=(:group,:jahr), color=:jahr, legend=nothing, width=2)
    p
end
    for g in ["Männlich", "Weiblich"]
]...)

