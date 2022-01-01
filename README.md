# DeutschlandDaten.jl
Schnittstelle zu offiziellen Daten des
- Statistischen Bundesamtes
- Robert-Koch-Instituts
als Julia [DataDeps.jl](https://www.oxinabox.net/DataDeps.jl/stable/) 
für Analysen 
mit der modernen Programmiersprache [Julia](https://julialang.org/) für statistische Berechnungen.

```julia
julia> using DeutschlandDaten
```
stellt Funktionen zur Datenabfrage zur Verfügung.
Beispiele finden Sie in den [unit tests](tests/runtests.jl).

Die aktuellen Analysen finden Sie in 
- [Sterberate](Sterberate.md).

Das Paket ermöglicht
- Aktualisierungen offizieller Daten für
- Generierung von SQL Tabellen


`DeutschlandDaten.jl` entstand auf Basis von 
1. https://github.com/gkappler/Sterbestatistik
2. Skripten für Analysen im Auftrag von Dr. Ute Bergner.


## Daten
### Sterbestatistik 

```julia
julia> deathdat = DeutschlandDaten.deaths_data()

julia> [ (alter = a,
          Männer = deaths(deathdat, jahr=2021, kw=44, alter=a, geschlecht="Männlich"),
          Frauen = deaths(deathdat, jahr=2021, kw=44, alter=a, geschlecht="Weiblich"))
         for a in DeutschlandDaten.Altersgruppen_KW ]  |> DataFrame
13×3 DataFrame
 Row │ alter      Männer   Frauen  
     │ UnitRang…  Float64  Float64 
─────┼─────────────────────────────
   1 │ 0:30          78.0     48.0
   2 │ 30:35         35.0     19.0
   3 │ 35:40         38.0      9.0
   4 │ 40:45         56.0     35.0
   5 │ 45:50        110.0     62.0
   6 │ 50:55        252.0    136.0
   7 │ 55:60        452.0    247.0
   8 │ 60:65        673.0    356.0
   9 │ 65:70        885.0    491.0
  10 │ 70:75       1051.0    604.0
  11 │ 75:80       1226.0    936.0
  12 │ 80:85       2130.0   1898.0
  13 │ 85:200      1804.0   2142.0

julia> DeutschlandDaten.deaths_data()
(deaths2016_2021 = XLSXFile("sonderauswertung-sterbefaelle.xlsx") containing 17 Worksheets
            sheetname size          range        
-------------------------------------------------
           Titelseite 63x8          A1:H63       
   Inhaltsverzeichnis 28x3          A1:C28       
             Hinweise 1x1           A1:A1        
     D_2016_2021_Tage 15x369        A1:NE15      
D_2016_2021_KW_AG_In… 105x56        A1:BD105     
D_2016_2021_KW_AG_Mä… 110x56        A1:BD110     
D_2016_2021_KW_AG_We… 110x56        A1:BD110     
D_2016-2021_Monate_A… 111x17        A1:Q111      
D_2016-2021_Monate_A… 111x17        A1:Q111      
D_2016-2021_Monate_A… 111x17        A1:Q111      
    BL_2016_2021_Tage 105x370       A1:NF105     
BL_2016_2021_KW_AG_I… 489x57        A1:BE489     
BL_2016_2021_KW_AG_M… 489x57        A1:BE489     
BL_2016_2021_KW_AG_W… 489x57        A1:BE489     
BL_2016_2021_Monate_… 489x17        A1:Q489      
BL_2016_2021_Monate_… 489x17        A1:Q489      
BL_2016_2021_Monate_… 489x17        A1:Q489      
, deaths2000_2015 = XLSXFile("sonderauswertung-sterbefaelle-endgueltige-daten.xlsx") containing 17 Worksheets
            sheetname size          range        
-------------------------------------------------
           Titelseite 63x8          A1:H63       
   Inhaltsverzeichnis 28x3          A1:C28       
             Hinweise 1x1           A1:A1        
     D_2000_2015_Tage 25x369        A1:NE25      
D_2000_2015_KW_AG_In… 265x56        A1:BD265     
D_2000_2015_KW_AG_Mä… 265x56        A1:BD265     
D_2000_2015_KW_AG_We… 265x56        A1:BD265     
D_2000-2015_Monate_A… 281x17        A1:Q281      
D_2000-2015_Monate_A… 281x17        A1:Q281      
D_2000-2015_Monate_A… 281x17        A1:Q281      
    BL_2000_2015_Tage 265x370       A1:NF265     
BL_2000_2015_KW_AG_I… 1289x58       A1:BF1289    
BL_2000_2015_KW_AG_M… 1289x57       A1:BE1289    
BL_2000_2015_KW_AG_W… 1289x57       A1:BE1289    
BL_2000_2015_Monate_… 1289x17       A1:Q1289     
BL_2000_2015_Monate_… 1289x17       A1:Q1289     
BL_2000_2015_Monate_… 1289x17       A1:Q1289     
)
```

#### 2016-2021
- Autor: Statistisches Bundesamt
- Datensatz: Sterbefälle - Fallzahlen nach Tagen, Wochen, Monaten, Altersgruppen, Geschlecht und Bundesländern für Deutschland 2016 - 2021
- Website: https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Bevoelkerung/Sterbefaelle-Lebenserwartung/Tabellen/sonderauswertung-sterbefaelle.html

>    Diese Sonderauswertung enthält Sterbefallzahlen nach Tagen, Wochen und Monaten seit dem 1. Januar 2016. 
>    Die Auswertung für die Jahre 2016 bis 2020 basiert dabei auf den endgültigen plausibilisierten Daten dieser Berichtsjahre. 
>    Daten ab dem 1. Januar 2021 sind vorläufig – hierbei handelt es sich zunächst um eine reine Fallzahlauszählung der eingegangenen Sterbefallmeldungen aus den Standesämtern – ohne die übliche statistische Aufbereitung. 
>    Die Daten wurden nicht plausibilisiert und es wurde keine Vollständigkeitskontrolle durchgeführt. 
>    Um dennoch möglichst genaue, schnelle und vergleichbare Daten bereitzustellen, wird ein Schätzverfahren zur Hochrechnung unvollständiger Sterbefallmeldungen für die jeweils aktuellsten Daten eingesetzt. 
>    Im Vergleich zu den endgültigen Daten liegt zudem nur ein begrenzter Merkmalsumfang vor (Rohdaten).

URL: https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Bevoelkerung/Sterbefaelle-Lebenserwartung/Tabellen/sonderauswertung-sterbefaelle.xlsx?__blob=publicationFile

### 2000-2015
- Autor: Statistisches Bundesamt
- Dataset: Sterbefälle - Fallzahlen nach Tagen, Wochen, Monaten, Altersgruppen, Geschlecht und Bundesländern für Deutschland 2000 - 2015
- Website: https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Bevoelkerung/Sterbefaelle-Lebenserwartung/Tabellen/sonderauswertung-sterbefaelle-endgueltige-daten.html;jsessionid=8C5CBDB9DF2D7285D72634AAF9834457.live711?nn=209016

>    Diese Sonderauswertung enthält Sterbefallzahlen nach Tagen, Kalenderwochen, Monaten, Altersgruppen, Geschlecht und Bundesländern der Jahre 2000 bis 2015. 
>	Für diese Sonderauswertung stand teilweise das Originalmaterial nicht mehr zur Verfügung. 
>	Deshalb gibt es in den Jahren 2000, 2002, 2003, 2005, 2006 und 2008 geringfügige Abweichungen gegenüber den an anderer Stelle veröffentlichten endgültigen Ergebnissen. 
>	Die Aussagekraft der hier präsentierten Daten wird dadurch nicht eingeschränkt.

URL: https://www.destatis.de/DE/Themen/Gesellschaft-Umwelt/Bevoelkerung/Sterbefaelle-Lebenserwartung/Tabellen/sonderauswertung-sterbefaelle-endgueltige-daten.xlsx?__blob=publicationFile

### COVID-19-Impfungen
```julia
julia> vdat = vaccination_data_bundesländer([1,14,28,36,48])
18105×11 DataFrame
   Row │ Datum_bis   Bundesland              Impfserie  Anzahl_kumulativ  Anzahl_kumulativ_1  Anzahl_kumulativ_14  Anzahl_kumulativ_28  Anzahl_kumulativ_36   ⋯
       │ Date        String                  Int64      Int64             Int64               Int64                Int64                Int64                 ⋯
───────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
     1 │ 2020-12-27  Baden-Württemberg               1              5655                5655                 5655                 5655                 5655   ⋯
     2 │ 2020-12-27  Bayern                          1              5769                5769                 5769                 5769                 5769
     3 │ 2020-12-27  Berlin                          1              3936                3936                 3936                 3936                 3936
     4 │ 2020-12-27  Brandenburg                     1               148                 148                  148                  148                  148
     5 │ 2020-12-27  Bremen                          1               758                 758                  758                  758                  758   ⋯
     6 │ 2020-12-27  Hamburg                         1              1077                1077                 1077                 1077                 1077
   ⋮   │     ⋮                 ⋮                 ⋮             ⋮                  ⋮                    ⋮                    ⋮                    ⋮            ⋱
 18100 │ 2021-12-16  Saarland                        3            335192               14730               167180               264565               293814
 18101 │ 2021-12-16  Bundesressorts                  3             73555                6011                47924                69588                72076
 18102 │ 2021-12-16  Thüringen                       3            553675               25921               235746               390193               453505   ⋯
 18103 │ 2021-12-16  Hamburg                         3            444073               24801               205420               330820               370729
 18104 │ 2021-12-16  Sachsen-Anhalt                  3            573387               26569               264089               445981               498725
 18105 │ 2021-12-16  Sachsen                         3            943189               44995               453741               750085               825615
```

- Autor: Robert-Koch-Institut
- Datensatz: Robert Koch-Institut (2021): COVID-19-Impfungen in Deutschland, Berlin: Zenodo. DOI:10.5281/zenodo.5126652.
- Website: https://github.com/robert-koch-institut/COVID-19-Impfungen_in_Deutschland

Die Impfdaten bilden einen tagesaktuellen Stand (8:30 Uhr) aller an das RKI gemeldeten Impfungen in Deutschland ab. 
[...]
Die "Aktuell_Deutschland_Bundeslaender_COVID-19-Impfungen.csv" ist identisch mit dem neusten Datenstand des Archivs.

#### Variablen

Die Impfdaten differenzieren nach verschiedenen Merkmalen einer Impfgruppe. 
Pro Eintrag bzw. Zeile ist eine eineindeutige Impfgruppe abgebildet. 
Eine Impfgruppe umfasst in der Regel keine Einzelfälle. 
Jedoch ist es möglich, dass in einer Impfgruppe nur ein Fall enthalten ist. 
Eine Impfgruppe wird grundlegend durch folgende Merkmale charakterisiert (in den Klammern finden sich die Variablen dieser Merkmale):

    Ort der Impfung (BundeslandId_Impfort)
    Impfung (Impfstoff, Impfserie)

Zusätzlich werden folgende Variablen angegeben:

    Datum der Impfung (Impfdatum)
    Anzahl der Impfungen in der Gruppe (Anzahl)

Eine Impfgruppe nimmt eine eineindeutige Ausprägung hinsichtlich der Anzahl der Impfungen in einem Bundesland, des Impfstoffes und der Impfserie an. 
Für jede Impfgruppe wird die tägliche Anzahl neuer Impfungen ausgewiesen, sofern diese größer null sind. 
Für jedes Datum ist angegeben, wie viele Personen, differenziert nach den oben aufgeführten Variablen, geimpft wurden.


URL: https://github.com/robert-koch-institut/COVID-19-Impfungen_in_Deutschland/raw/master/Aktuell_Deutschland_Bundeslaender_COVID-19-Impfungen.csv

### Bevölkerung 
```julia
julia> popdat = DeutschlandDaten.population();

julia> [ (alter = a,
          Männer = population(popdat, jahr=2021, alter=a, geschlecht="Männlich"),  
          Frauen = population(popdat, jahr=2021, alter=a, geschlecht="Weiblich"))  
         for a in DeutschlandDaten.Altersgruppen_Monate ]  |> DataFrame
14×3 DataFrame
 Row │ alter      Männer   Frauen  
     │ UnitRang…  Int64    Int64   
─────┼─────────────────────────────
   1 │ 0:15       5896365  5581435
   2 │ 15:30      6938514  6401690
   3 │ 30:35      2876938  2704150
   4 │ 35:40      2688873  2602003
   5 │ 40:45      2531208  2503680
   6 │ 45:50      2526278  2509582
   7 │ 50:55      3265131  3222093
   8 │ 55:60      3414124  3403194
   9 │ 60:65      2866561  2951576
  10 │ 65:70      2333788  2565316
  11 │ 70:75      1854514  2113556
  12 │ 75:80      1551030  1916998
  13 │ 80:85      1432318  1998184
  14 │ 85:200      850877  1655055
```

julia> [ (alter = a, N= population(popdat, jahr=2021, alter=a, monat=12, geschlecht=""))
         for a in DeutschlandDaten.Altersgruppen_Monate ]  |> DataFrame

#### Deutschland gesamt
Zur Nutzung sind das manuelle Herunterladen von Daten nötig.
```julia
julia> DeutschlandDaten.population()
1892×5 DataFrame
  Row │ Stichtag    Altersgruppe  Männlich  Weiblich  Insgesamt 
      │ Date        UnitRange…    Int64     Int64     Int64     
──────┼─────────────────────────────────────────────────────────
    1 │ 1999-12-31  0:1             396428    374795     771223
    2 │ 2000-12-31  0:1             392998    373556     766554
    3 │ 2001-12-31  0:1             378223    357532     735755
    4 │ 2002-12-31  0:1             369289    349961     719250
    5 │ 2003-12-31  0:1             362421    344028     706449
    6 │ 2004-12-31  0:1             361549    343439     704988
  ⋮   │     ⋮            ⋮           ⋮         ⋮          ⋮
 1887 │ 2015-12-31  85:199          668202   1536589    2204791
 1888 │ 2016-12-31  85:199          697500   1549439    2246939
 1889 │ 2017-12-31  85:199          718497   1546976    2265473
 1890 │ 2018-12-31  85:199          737893   1539616    2277509
 1891 │ 2019-12-31  85:199          793584   1593270    2386854
 1892 │ 2020-12-31  85:199          850877   1655055    2505932
                                               1880 rows omitted
```

- Autor: Statistisches Bundesamt
- Daten: Bevölkerung: Deutschland, Stichtag, Altersjahre, Nationalität/Geschlecht/Familienstand

   Code: 12411-0006

- Website: https://www-genesis.destatis.de/genesis//online?operation=table&code=12411-0006&bypass=true&levelindex=1&levelid=1639608813890#abreadcrumb
    
### Bevölkerung Bundesländer
Zur Nutzung sind das manuelle Herunterladen von Daten nötig.
```julia
julia> DeutschlandDaten.population_bundesländer()
2275×51 DataFrame
  Row │ Column1_Column1  Column2_Column2    Baden-Württemberg_männlich  Baden-Württemberg_weiblich  Baden-Württemberg_Insgesamt  Bayern_männlich  Bayern_weib ⋯
      │ Date             String31           Int64                       Int64                       Int64                        Int64            Int64       ⋯
──────┼────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
    1 │ 1996-12-31       unter 1 Jahr                            59065                       55919                       114984            66703            6 ⋯
    2 │ 1996-12-31       1-Jährige                               58204                       55041                       113245            65019            6
    3 │ 1996-12-31       2-Jährige                               58934                       55480                       114414            66547            6
    4 │ 1996-12-31       3-Jährige                               60910                       57787                       118697            69579            6
    5 │ 1996-12-31       4-Jährige                               61681                       58051                       119732            70007            6 ⋯
    6 │ 1996-12-31       5-Jährige                               62682                       59534                       122216            71848            6
  ⋮   │        ⋮                 ⋮                      ⋮                           ⋮                            ⋮                      ⋮                ⋮    ⋱
 2270 │ 2020-12-31       85-Jährige                              24680                       36591                        61271            26649            4
 2271 │ 2020-12-31       86-Jährige                              19934                       30810                        50744            22098            3
 2272 │ 2020-12-31       87-Jährige                              14682                       23630                        38312            16074            2 ⋯
 2273 │ 2020-12-31       88-Jährige                              12228                       21102                        33330            13663            2
 2274 │ 2020-12-31       89-Jährige                              10487                       19033                        29520            11393            2
 2275 │ 2020-12-31       90 Jahre und mehr                       31943                       76282                       108225            35557            8
```

- Autor: Statistisches Bundesamt
- Daten: Bevölkerung: Bundesländer, Stichtag, Geschlecht, Altersjahre

   Code: 12411-0013

- Website: https://www-genesis.destatis.de/genesis//online?operation=table&code=12411-0013&bypass=true&levelindex=1&levelid=1639608813890#abreadcrumb


## Einschränkungen
### Standardisierungen
Offizielle Datenquellen sind verschieden (wie Tiere im Zoo):
- Herunterladbare Excel Tabellen
- CSV Dateien 
   - aus voluminösen GitHub Archiven
   - manuell herunterladbare Datenausschnitte 


Ideal wären Automatisierungen über das Daten-API des Statistischen Bundesamtes und anderer Behörden.
(Konstruktive Unterstützung als fork?)

Die Performance kann an vielen Stellen verbessert werden.
(Unit tests auf Datenausschnitte sollten vorher ausgebaut werden.)

### Notaufnahme, Krankenhaus, Arztbesuche, Krankenkasse

### PCR-Inzidenzzahlen
inklusive der Zahl administrierter Tests.

### Metadaten
#### Regelungen zu Datum
bestimmen die Alters-Verteilung der 
- Injektionen
- Tests
- ?

### Landkreisdaten


