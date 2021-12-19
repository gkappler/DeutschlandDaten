module DeutschlandDaten

using DataDeps
using CSV
using DataFrames

## für Bundesländer
Bundesländer = ["Schleswig-Holstein",
                "Hamburg",
                "Niedersachsen",
                "Bremen",
                "Nordrhein-Westfalen",
                "Hessen",
                "Rheinland-Pfalz",
                "Baden-Württemberg",
                "Bayern",
                "Saarland",
                "Berlin",
                "Brandenburg",
                "Mecklenburg-Vorpommern",
                "Sachsen",
                "Sachsen-Anhalt",
                "Thüringen"]

# Write your package code here.
function __init__()
# begin
    register(DataDep("Sterbestatistik 2016-2021","""
    Autor: Statistisches Bundesamt
    Dataset: Sterbefälle - Fallzahlen nach Tagen, Wochen, Monaten, Altersgruppen, Geschlecht und Bundesländern für Deutschland 2016 - 2021
    Website: https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Bevoelkerung/Sterbefaelle-Lebenserwartung/Tabellen/sonderauswertung-sterbefaelle.html

    Diese Sonderauswertung enthält Sterbefallzahlen nach Tagen, Wochen und Monaten seit dem 1. Januar 2016. 
    Die Auswertung für die Jahre 2016 bis 2020 basiert dabei auf den endgültigen plausibilisierten Daten dieser Berichtsjahre. 
    Daten ab dem 1. Januar 2021 sind vorläufig – hierbei handelt es sich zunächst um eine reine Fallzahlauszählung der eingegangenen Sterbefallmeldungen aus den Standesämtern – ohne die übliche statistische Aufbereitung. 
    Die Daten wurden nicht plausibilisiert und es wurde keine Vollständigkeitskontrolle durchgeführt. 
    Um dennoch möglichst genaue, schnelle und vergleichbare Daten bereitzustellen, wird ein Schätzverfahren zur Hochrechnung unvollständiger Sterbefallmeldungen für die jeweils aktuellsten Daten eingesetzt. 
    Im Vergleich zu den endgültigen Daten liegt zudem nur ein begrenzter Merkmalsumfang vor (Rohdaten).
    """,
                     "https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Bevoelkerung/Sterbefaelle-Lebenserwartung/Tabellen/sonderauswertung-sterbefaelle.xlsx?__blob=publicationFile"
                     ))

    register(DataDep("Sterbestatistik 2000-2015","""
    Autor: Statistisches Bundesamt
    Dataset: Sterbefälle - Fallzahlen nach Tagen, Wochen, Monaten, Altersgruppen, Geschlecht und Bundesländern für Deutschland 2000 - 2015
    Website: https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Bevoelkerung/Sterbefaelle-Lebenserwartung/Tabellen/sonderauswertung-sterbefaelle-endgueltige-daten.html;jsessionid=8C5CBDB9DF2D7285D72634AAF9834457.live711?nn=209016

    Diese Sonderauswertung enthält Sterbefallzahlen nach Tagen, Kalenderwochen, Monaten, Altersgruppen, Geschlecht und Bundesländern der Jahre 2000 bis 2015. Für diese Sonderauswertung stand teilweise das Originalmaterial nicht mehr zur Verfügung. Deshalb gibt es in den Jahren 2000, 2002, 2003, 2005, 2006 und 2008 geringfügige Abweichungen gegenüber den an anderer Stelle veröffentlichten endgültigen Ergebnissen. Die Aussagekraft der hier präsentierten Daten wird dadurch nicht eingeschränkt.
    """,
                     "https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Bevoelkerung/Sterbefaelle-Lebenserwartung/Tabellen/sonderauswertung-sterbefaelle-endgueltige-daten.xlsx?__blob=publicationFile"
                     ))

    register(DataDep("COVID-19-Impfungen","""
    Autor: Robert-Koch-Institut
    Dataset: Robert Koch-Institut (2021): COVID-19-Impfungen in Deutschland, Berlin: Zenodo. DOI:10.5281/zenodo.5126652.
    Website: https://github.com/robert-koch-institut/COVID-19-Impfungen_in_Deutschland

Die Impfdaten bilden einen tagesaktuellen Stand (8:30 Uhr) aller an das RKI gemeldeten Impfungen in Deutschland ab. Im Dateinamen repräsentiert die Sequenz "JJJJ-MM-TT" das Erstellungsdatum der Datei und gleichzeitig das Datum des enthaltenen Datenstands. "JJJJ" steht dabei für das Jahr, "MM" für den Monat und "TT" für den Tag der Erstellung bzw. des enthaltenen Datenstands. Die "Aktuell_Deutschland_Bundeslaender_COVID-19-Impfungen.csv" ist identisch mit dem neusten Datenstand des Archivs.
Variablen

Die Impfdaten differenzieren nach verschiedenen Merkmalen einer Impfgruppe. Pro Eintrag bzw. Zeile ist eine eineindeutige Impfgruppe abgebildet. Eine Impfgruppe umfasst in der Regel keine Einzelfälle. Jedoch ist es möglich, dass in einer Impfgruppe nur ein Fall enthalten ist. Eine Impfgruppe wird grundlegend durch folgende Merkmale charakterisiert (in den Klammern finden sich die Variablen dieser Merkmale):

    Ort der Impfung (BundeslandId_Impfort)
    Impfung (Impfstoff, Impfserie)

Zusätzlich werden folgende Variablen angegeben:

    Datum der Impfung (Impfdatum)
    Anzahl der Impfungen in der Gruppe (Anzahl)

Eine Impfgruppe nimmt eine eineindeutige Ausprägung hinsichtlich der Anzahl der Impfungen in einem Bundesland, des Impfstoffes und der Impfserie an. Für jede Impfgruppe wird die tägliche Anzahl neuer Impfungen ausgewiesen, sofern diese größer null sind. Für jedes Datum ist angegeben, wie viele Personen, differenziert nach den oben aufgeführten Variablen, geimpft wurden.
Variablenausprägungen

Die Impfdaten enthalten die in der folgenden Tabelle abgebildeten Variablen und deren Ausprägungen:

Impfdatum JJJJ-MM-TT 	
Datum der Impfungen

BundeslandId_Impfort 
01 bis 16 : Bundesland ID
17 : Bundesressorts 	
Identifikationsnummer des Bundeslandes basierend auf dem Amtlichen Gemeindeschlüssel (AGS). 
Impfungen des Bundesressorts werden separat ausgewiesen, da die Impfstellen des Bundes ohne exakte Angabe des Impfortes melden

Impfstoff 	
AstraZeneca: AstraZeneca, Moderna: Moderna, Comirnaty: BioNTech/Pfizer, Janssen: Janssen‑Cilag/Johnson & Johnson
Verabreichter Impfstoff

Impfserie
1: Erstimpfung
2: Zweitimpfung
3: Auffrischungsimpfung 	
Angabe zur Erst-, Zweit- oder Auffrischungsimpfung

Anzahl 	Natürliche Zahl 	≥1 	
Anzahl der Impfungen in der Impfgruppe
    """,
                     "https://github.com/robert-koch-institut/COVID-19-Impfungen_in_Deutschland/raw/master/Aktuell_Deutschland_Bundeslaender_COVID-19-Impfungen.csv"
                     ))
    
    register(ManualDataDep("Bevölkerung Deutschland", """
    Autor: Statistisches Bundesamt
    Data: Bevölkerung: Deutschland, Stichtag, Altersjahre, Nationalität/Geschlecht/Familienstand
    Code: 12411-0006

    Website: https://www-genesis.destatis.de/genesis//online?operation=table&code=12411-0006&bypass=true&levelindex=1&levelid=1639608813890#abreadcrumb
    """))
    
    register(ManualDataDep("Bevölkerung Deutschland Bundesländer", """
    Autor: Statistisches Bundesamt
    Data: Bevölkerung: Bundesländer, Stichtag, Geschlecht, Altersjahre
    Code: 12411-0013

    Website: https://www-genesis.destatis.de/genesis//online?operation=table&code=12411-0013&bypass=true&levelindex=1&levelid=1639608813890#abreadcrumb
    """))
end


# https://www.orte-in-deutschland.de/amtlicher-gemeindeschluessel-ags.html
AGS = Dict(
    17 => "Bundesressorts",
    1 => "Schleswig-Holstein",
    2 => "Hamburg",
    3 => "Niedersachsen",
    4 => "Bremen",
    5 => "Nordrhein-Westfalen",
    6 => "Hessen",
    7 => "Rheinland-Pfalz",
    8 => "Baden-Württemberg",
    9 => "Bayern",
    10 => "Saarland",
    11 => "Berlin",
    12 => "Brandenburg",
    13 => "Mecklenburg-Vorpommern",
    14 => "Sachsen",
    15 => "Sachsen-Anhalt",
    16 => "Thüringen",
)

include("deaths.jl")
include("vaccines.jl")
include("population.jl")




using Plots
using StatsPlots
using Plots.PlotMeasures
using Printf
export plotyears
function plotyears(mordat, from_date = minimum(mordat[:,:date]); region = "Deutschland", kw...)
    p1 = plotyears(mordat,"Männlich", from_date; title = "männlich ♂", kw...)
    p2 = plotyears(mordat,"Weiblich", from_date; title ="weiblich ♀", ylabel="", yaxis=(formatter = p -> ""), kw...)
    plot(plot(title = "Sterbekurve $region $(year(from_date))-2021",framestyle=nothing,showaxis=false,xticks=false,yticks=false,margin=0mm),
         p1, p2,
         layout=@layout [a{0.01h}; grid(1,2)])
end

function plotyears(
    mordat, geschlecht::String, from_date = minimum(mordat[:,:date]);
    title = geschlecht,
    ydata = :Pdeath,
    ylabel = "Sterbe-Wahrscheinlichkeit / Monat (log)",
    yticks=[.00001, .00002, .00005, .0001, .0002,.0005,.001,.002,.005,.01,.02],
    ylim = extrema(yticks) .* (.95, 1.05),
    yaxis=(formatter = p -> @sprintf("%0.3f%%", p*100)),
    yearticks = (2021-year(from_date) > 10) ? ((year(from_date)+1):5:2021) : ((year(from_date)+1):1:2021),
    kw...)
    d = mordat[( mordat[:,:geschlecht] .== geschlecht ) .& (mordat[:,:date] .>= from_date ),:]
    @show date,maxdate=minimum(d[:,:date]),maximum(d[:,:date])
    plot([Date(2020,06,1), maxdate],
         color=:yellow, opacity = .25,
         seriestype=:vspan,
         yaxis=:log, title=title, legend=nothing)
    plot!([Date(2020,12,27), maxdate],
          color=:gray, opacity = .25,
          seriestype=:vspan)
    plot!([Date(year,1,1) for year in (year(from_date)+1):2021];
          seriestype=:vline, color=:lightgray)
    p1 = @df d plot!(:date, :Pdeath; group=:alter,
                     xticks=([Date(y,01,01) for y in yearticks], [y for y in yearticks]),
                     xlabel="Jahr",
                     yticks=yticks,
                     ylabel=ylabel,
                     yaxis=yaxis,
                     ylim=ylim,
                     kw...
                     )
    g = first(unique(mordat.alter))
    annotate!([(maxdate,
                d[map(x-> x == g,d.alter),:Pdeath][end],
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
