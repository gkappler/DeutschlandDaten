module DeutschlandDaten
using DataDeps
using CSV
using DataFrames

end


# data sources
include("metadata.jl")
include("deaths.jl")
include("vaccines.jl")
include("population.jl")

using Plots
using StatsPlots
using Plots.PlotMeasures
using Printf
export plotyears


using Printf
function plotyears(mordat, from_date = minimum(mordat[:,:date]); kw...)
    p1 = plotyears(mordat,"Männlich", from_date; title = "männlich ♂", kw...)
    p2 = plotyears(mordat,"Weiblich", from_date; title ="weiblich ♀", ylabel="", yaxis=(formatter = p -> ""), kw...)
    plot(plot(title = "Sterbekurve Deutschland $(year(from_date))-2021",framestyle=nothing,showaxis=false,xticks=false,yticks=false,margin=0mm), p1,p2, layout=@layout [a{0.01h}; grid(1,2)])
end

function plotyears(mordat, geschlecht::String, from_date = minimum(mordat[:,:date]);
                   title = geschlecht,
                   ydata = :PD,
                   ylabel = "Sterberate pro 10'000 / Monat (log)",
                   yticks = 10000 .* [.00001, .00002, .00005, .0001, .0002,.0005,.001,.002,.005,.01,.02],
                   ylim =  10000 .* (0.00001,0.023),
                   yaxis=(formatter = p -> @sprintf("%.2f",p)),
                   yearticks = (2021-year(from_date) > 10) ? ((year(from_date)):5:2021) : ((year(from_date)):1:2021))
    d = mordat[( mordat[:,:geschlecht] .== geschlecht ) .& (mordat[:,:date] .>= from_date ),:]
    date,maxdate=minimum(d[:,:date]),maximum(d[:,:date])
    @info "background"
    plot([Date(2020,06,1), maxdate],
         color=:yellow, opacity = .25,
         seriestype=:vspan,
         xlim = (date,maxdate), ylim =ylim,
         xticks = yearticks, yticks = yticks,
         yaxis=:log10, title=title, legend=nothing)

    plot!([Date(2020,12,27), maxdate],
         color=:gray, opacity = .25,
         seriestype=:vspan)
    plot!([Date(year,1,1) for year in (year(from_date)+1):2021];
          seriestype=:vline, color=:lightgray)
    @info "PD"
    @df d plot!(:date, :PD; series=:alter, c=:gray, legend=nothing)
    @info "PD_12months"
    p1 = @df d plot!(:date, :PD_12months; group=:alter, width=3,
                     xticks=([Date(y,01,01) for y in yearticks], [y for y in yearticks]),
                     xrotation = -90,
                     # xlabel=nothing,
                     yticks=yticks,
                     ylabel=ylabel,
                     yaxis=yaxis,
                     ylim=ylim,
                     )
    g = first(unique(mordat.alter))
    annotate!([(maxdate,
                d[map(x-> x == g,d.alter),:PD_12months][end],
                text("$(g.start)", 6, halign=:left, valign=:vcenter))
               for g in unique(mordat.alter)])
    p1
end

export endofweek
function endofweek(y, w)
    d = Dates.firstdayofweek(Date(y)) + Dates.Day(2)
    d + Dates.Week(w - (year(d)<y ? 0 : 1)) + Dates.Day(4)
end

end
