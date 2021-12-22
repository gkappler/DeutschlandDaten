monattick = ["Jan", "Feb", "Mär", "Apr", "Mai", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dez" ]

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



# https://www.orte-in-deutschland.de/amtlicher-gemeindeschluessel-ags.html
"""
    AGS

Are used in vacc data.
"""
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
