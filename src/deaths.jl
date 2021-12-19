using XLSX
export deaths
# function Sterbestatistik()

MAX = 200
export deaths_data

deaths_data() =
    (deaths2016_2021 = XLSX.readxlsx(joinpath(datadep"Sterbestatistik 2016-2021", "sonderauswertung-sterbefaelle.xlsx")), 
     deaths2000_2015 = XLSX.readxlsx(joinpath(datadep"Sterbestatistik 2000-2015", "sonderauswertung-sterbefaelle-endgueltige-daten.xlsx")))

gender_code = Dict("männlich" => "Männlich",
                   "Männlich" => "Männlich",
                   "weiblich" => "Weiblich",
                   "Weiblich" => "Weiblich",
                   "insgesamt" => "Ins",
                   "Insgesamt" => "Ins",
                   )



Bundesländer_index = Dict(r => i for (i,r) in enumerate(Bundesländer))

## für Bundesländer
Altersgruppen_Bundesländer = [0:65, 65:75, 75:85, 85:MAX]

Altersgruppen_KW = [ 0:30, [a:a+5 for a in 30:5:80]..., 85:MAX ];
Altersgruppen_Monate = [ 0:15, 15:30, [a:a+5 for a in 30:5:80]..., 85:MAX ];

geschlechter = ["Männlich", "Weiblich"] # , "Insgesamt"

alterzeile = Dict(missing=>1, [r => i+2 for (i,r) in enumerate(Altersgruppen_Bundesländer)]...)


"""
    deaths(data; jahr, kw=missing, monat=missing, alter=missing, geschlecht="Insgesamt", bundesland = missing)
"""
function deaths(data;
                jahr, kw=missing, monat=missing,
                alter::Union{UnitRange,Missing}, geschlecht,
                bundesland = missing)
    # @assert geschlecht in geschlechter
    geschlecht = get(gender_code, geschlecht, geschlecht)

    dset, dsheet, joffset = if 2016<=jahr
        data.deaths2016_2021, 2016, 2021
    else
        data.deaths2000_2015, 2000, 2015
    end

    r = if kw === missing
        if monat === missing 
	    return sum([ deaths(data; bundesland = bundesland, alter=alter, geschlecht=geschlecht, jahr=jahr, monat=i)
                         for i in 1:12
                             if deaths(data; bundesland = bundesland, alter=alter, geschlecht=geschlecht, jahr=jahr, kw=i) isa Number])
        else # monat !== missing
            
            if bundesland !== missing
                sheet = dset["BL_$(dsheet)_$(joffset)_Monate_AG_$geschlecht"]

                zeile = 5 + # skipping lines,
                    (joffset-jahr)*80 + # lines blocks for years,
                    5 * get(Bundesländer_index,"$bundesland") do  # lines blocks for Bundesländer
                        error("bundesland must be in  in $(Bundesländer)")
                    end +
                        get(alterzeile, alter) do # year steps
                            error("alter must be in $(keys(alterzeile))")
                        end - 1

                col = monat + 4
                sheet[zeile, col]
            else
                
                # skipping 11 lines,
                zeile = 11 +
                    # 16 lines blocks for years,
                    (joffset-jahr)*17 + 
                    # 5 year steps beginning age 30
                    if alter.start == 0
                        0
                    elseif alter.start == 15
                        1
                    else
                        1 + max(0, (alter.start-25)/5)
                    end
                ## look up gender tab
                tab = dset["D_$(dsheet)-$(joffset)_Monate_AG_$geschlecht"]
                # and check in cw column, skipping first 3
                # @info "deaths lookup" "$dsheet$geschlecht", zeile, monat
                tab[convert(Int,zeile), monat+3]
	    end
        end
    else  # kw !== missing
        if monat !== missing
            error("proveide either monat or kw, but not both")
        end

        if bundesland !== missing
            sheet = dset["BL_$(dsheet)_$(joffset)_KW_AG_$geschlecht"]
            zeile = 5 + # skipping lines,
                (joffset-jahr)*80 + # lines blocks for years,
                5 * get(Bundesländer_index,"$bundesland") do  # lines blocks for Bundesländer
                    error("bundesland must be in  in $(Bundesländer)")
                end +
                    get(alterzeile, alter) do # year steps
                        error("alter must be in $(keys(alterzeile))")
                    end - 1

            col = kw + 4
            sheet[zeile, col]
        else

            # @assert alter isa UnitRange && alter.stop-alter.start==5 && alter.start<=95
            if alter.start >= 95
	        #@warn "alter" alter
                alter = 95:MAX
            end    
            if alter.stop <= 30
	        #@warn "alter" alter
                alter = 0:30
            end
            # skipping 11 lines,
            zeile = 11 +
                # 16 lines blocks for years,
                (joffset-jahr)*16 + 
                # 5 year steps beginning age 30
                max(0, (alter.start-25)/5)
            ## look up gender tab
            tab = dset["D_$(dsheet)_$(joffset)_KW_AG_$geschlecht"]
            # @info "deaths lookup" "$dsheet$geschlecht", zeile, kw
            # and check in cw column, skipping first 3
            tab[convert(Int,zeile), kw+3]
        end
    end
    r isa Number ? r : missing
end

# end
