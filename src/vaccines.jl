using Dates

export vaccination_data_bundesländer
function vaccination_data_bundesländer(windows=[14])
    vdata = CSV.read(joinpath(datadep"COVID-19-Impfungen","Aktuell_Deutschland_Bundeslaender_COVID-19-Impfungen.csv"), DataFrame)
    vdata[:,:Bundesland] = [ AGS[id] for id in vdata[:,:BundeslandId_Impfort] ]
    vdata[(vdata[:,:Impfstoff] .== "Janssen") .& (vdata[:,:Impfserie] .== 1),:Impfserie] .= 2
    sort!(vdata, [:Bundesland, :Impfstoff, :Impfserie, :Impfdatum])

    mini,maxi=extrema(vdata[:,:Impfdatum])
    Ndays = (maxi-mini).value+1

    function aggregate_before(impfdatum, anzahl; span=nothing)
        agg = Vector{Int}(undef, Ndays)
        for i in 1:Ndays
            start = span === nothing ? 1 : searchsortedfirst(impfdatum, mini+Day(i)-span)
            idx = searchsortedfirst(impfdatum, mini+Day(i))
            agg[i] = sum(anzahl[max(1,start):min(max(1,idx),length(anzahl))])
        end
        agg
    end

    vdata
    
    # groupby(
    #     transform(dg, [:Impfdatum, :Anzahl] => ( (i,n) -> aggregate_before(i,n;span=Day(14)) ) => :Anzahl_kumulativ),
    #     [:BundeslandId_Impfort, :Impfserie])[1]
    dg = groupby(sort!(vdata, :Impfdatum), [:Bundesland, :Impfserie])
    # impfdatum, anzahl = dg[1][:,:Impfdatum], dg[1][:,:Anzahl]

    d2 = combine(dg,
                 [:Impfdatum, :Anzahl] => aggregate_before => :Anzahl_kumulativ,
                 [:Impfdatum, :Anzahl] => ((x,y) -> collect(mini:Day(1):maxi)) => :Datum_bis,
                 ( [:Impfdatum, :Anzahl] => ( (i,n) -> aggregate_before(i,n;span=Day(w)) ) => Symbol("Anzahl_kumulativ_$w")
                   for w in windows )...
                       )

    # transform!(d2, [:Bundesland, :Anzahl_kumulativ] => ( (b,n) -> n ./ [population[n] for n in b]) => :Anzahl_kumulativ_prop)
    # transform!(d2, [:Bundesland, :Anzahl_kumulativ_14] => ( (b,n) -> n ./ [population[n] for n in b]) => :Anzahl_kumulativ_14_prop)

    vdata_aggregated = select(groupby(d2, [:Datum_bis, :Bundesland, :Impfserie]),
                              :Anzahl_kumulativ => sum => :Anzahl_kumulativ,
                              (Symbol("Anzahl_kumulativ_$w") => sum => Symbol("Anzahl_kumulativ_$w")
                               for w in windows)...
                                   )
    # :Anzahl_kumulativ_14_prop => sum => :Anzahl_kumulativ_14_prop,
    # :Anzahl_kumulativ_prop => sum => :Anzahl_kumulativ_prop)

    # for x in groupby(vdata_aggregated, [:Bundesland])
    #     x[1,:Bundesland] == "Bundesressorts" && print(x)
    # end

    sort!(vdata_aggregated, :Datum_bis)
    vdata_aggregated[:,:year] = year.(vdata_aggregated[:,:Datum_bis])
    vdata_aggregated[:,:kw] = week.(vdata_aggregated[:,:Datum_bis])
    vdata_aggregated
end

#vaccination_data = select(groupby(vaccination_data, [:Impfdatum, :Bundesland, :Impfstoff, :Impfserie]), :Anzahl => sum => :Anzahl)

# vaccination_data[:,:Impfdatum]

#mini+Day(19)

# aggregate_before(impfdatum, anzahl; span=nothing)

# function aggregate_before(impfdatum, anzahl; span=nothing)
#     agg = Vector{Int}(undef, size(impfdatum,1))
#     if span === nothing
#         for (i,n) in enumerate(anzahl)
#             agg[i] = (i == 1 ? 0 : agg[i-1]) + n
#         end
#     else
#         for (i,(vaccination_data,n)) in enumerate(zip(impfdatum,anzahl))
#             nn = n 
#             i>1 && for j in (i-1):-1:1
#                 vaccination_data-impfdatum[j]>span && break
#                 nn += anzahl[j]
#                 # @show vaccination_data,impfdatum[j], n, anzahl[j]
#                 # readline()
#             end
#             agg[i] = nn
#         end
#     end
#     agg
# end

# bundesland, kw = "Bayern", 40

export vaccinations
function vaccinations(vaccination_data_aggregated; alter=missing, geschlecht=missing, jahr, kw=missing, monat=missing, bundesland, serie=2)
    vaccination_data_aggregated[
        (vaccination_data_aggregated[:,:Bundesland] .== bundesland) .&
            ( kw !== missing ? (vaccination_data_aggregated[:,:kw] .== kw) :
            ( monat !== missing ? (month.(vaccination_data_aggregated[:,:Datum_bis]) .== monat) : true)) .&
            ( year.(vaccination_data_aggregated[:,:Datum_bis]) .== jahr) .&
            (vaccination_data_aggregated[:,:Impfserie] .== serie),:]
end

