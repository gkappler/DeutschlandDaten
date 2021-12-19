using CSV, DataFrames, StringEncodings
# Let's encode age ranges with UnitRange, and transform conveniently with CombinedParsers
using CombinedParsers
jahrp = Either("unter 1 Jahr" => 0:1,
               map(a -> a:a, 
                   Sequence(1, CombinedParsers.Numeric(Int),"-Jährige")),
               map(a -> a:(MAX-1), Sequence(1, CombinedParsers.Numeric(Int)," Jahre und mehr")),
               "Insgesamt" => 0:MAX-1)

@deprecate popdat() population()
function population()
    pdat = CSV.File(
        open(read, joinpath(datadep"Bevölkerung Deutschland","12411-0006.csv"), enc"ISO-8859-1");
        skipto=9, footerskip=4,
        delim=';', decimal=',',
        dateformat="dd.mm.yyy", 
        header=["Stichtag", "Altersgruppe","Männlich","Weiblich","Insgesamt" ]) |> DataFrame
    pdat = pdat[pdat.Altersgruppe .!= "Insgesamt",:]

    pdat[!,"Altersgruppe"] = [ parse(jahrp, v)
                               for v in pdat[!,2] ]
    sort!(pdat, [2, 1])
    pdat
end

@deprecate popdat_bundesländer() population_bundesländer()
function population_bundesländer()
    pdat = vcat([ CSV.File(
        open(read, joinpath(datadep"Bevölkerung Deutschland Bundesländer","12411-0013$suffix.csv"),
             enc"ISO-8859-1");
        skipto=7, footerskip=4,
        delim=';', decimal=',',
        dateformat="dd.mm.yyy",
        header=5:6)  |> DataFrame for suffix in ["", "(1)", "(2)", "(3)", "(4)" ]]...)

    pdat = pdat[pdat[:,2] .!= "Insgesamt",:]

    pdat[!,"Altersgruppe"] = [
        parse(jahrp, v)
        for v in pdat[!,2]
            ];
    sort!(pdat, [1,:Altersgruppe])
    pdat
end

using Dates
"better idea with Intervals?"
iseq(x,y) = [ e.start >= y.start && ( e.stop < y.stop || e.stop == MAX)
              for e in x ]

export population
function population(popdat, deathdat=missing; jahr, geschlecht="Insgesamt", bundesland=missing, alter, monat = missing, kw=missing)
    if monat === missing && kw === missing
        if bundesland===missing
            # @assert geschlecht in geschlechter
            ## todo: boundary checks!
            rows = (popdat[:,1] .== Date(jahr-1,12,31)) .&
                iseq(popdat[:,:Altersgruppe], alter)
            sum(popdat[rows, geschlecht])
        else
            rows = (popdat[:,1] .== Date(jahr-1,12,31)) .&
                iseq(popdat[:,"Altersgruppe"], alter)
            ##print(popdat[rows, end])
            sum(popdat[rows, "$(bundesland)_$(lowercase(geschlecht))"])
        end
    elseif kw !== missing
        p1 = population(popdat,deathdat; alter=alter, geschlecht=geschlecht, bundesland = bundesland, jahr=jahr)
        p2 = population(popdat,deathdat; alter=alter, geschlecht=geschlecht, bundesland = bundesland, jahr=jahr+1)
        d = [ deaths(deathdat;bundesland = bundesland, alter=alter, geschlecht=geschlecht, jahr=jahr, kw=w) for w in 1:53 ]
        diedbefore = sum( d[1:(kw)] )
        adjust_kw = p2 == 0 ? 0 : (kw) * (p2-(p1-sum( d ))) / 52.0
        p1 - diedbefore + adjust_kw
    else
        p1 = population(popdat,deathdat; alter=alter, geschlecht=geschlecht, bundesland = bundesland, jahr=jahr)
        p2 = population(popdat,deathdat; alter=alter, geschlecht=geschlecht, bundesland = bundesland, jahr=jahr+1)
        d = [ deaths(deathdat;bundesland = bundesland, alter=alter, geschlecht=geschlecht, jahr=jahr, monat=m) for m in 1:12 ]
        diedbefore = sum( d[1:(monat)] )
        adjust_month = p2 == 0 ? 0 : (monat) * (p2-(p1-sum( d ))) / 12.0
        p1 - diedbefore + adjust_month
    end
end


