using DeutschlandDaten
using Test

@testset "DeutschlandDaten.jl" begin

    @test [deaths(deathdat; alter=a, jahr=2020, monat=1, geschlecht="Ins")
           for a in DeutschlandDaten.Altersgruppen_Monate] ==
               [ 272, 329, 248, 374, 486, 856, 1943, 3159, 4414, 5820, 6653, 11018,  16556, 15577+12282+ 4993]

    @test [deaths(deathdat; alter=a, jahr=2018, monat=6, geschlecht="Ins")
           for a in DeutschlandDaten.Altersgruppen_Monate] ==
        [ 322, 345, 210, 317, 418, 873, 1845, 2748, 3863, 4842, 5555, 10125, 12784, 12196+ 9168+ 3717 ]

    @test [deaths(deathdat; alter=a, jahr=2019, monat=3, geschlecht="Männlich")
           for a in DeutschlandDaten.Altersgruppen_Monate] ==
               [ 181, 228, 149, 217, 338, 585, 1295, 2045, 2877, 3640, 3991, 6926, 8337, 6668 + 3916 + 1037 ]


    @test [ deaths(deathdat; alter=a, jahr=2020, kw=3, geschlecht="Ins")
           for a in DeutschlandDaten.Altersgruppen_KW ] ==
               [ 130, 62, 79, 102, 190, 449, 723, 1003, 1259, 1459, 2424, 3701, 3526 + 2746 + 1100 ]

    @test [ deaths(deathdat; alter=a, jahr=2018, kw=6, geschlecht="Männlich")
           for a in DeutschlandDaten.Altersgruppen_KW ] ==
               [ 98, 44, 43, 77, 122, 273, 463, 617, 793, 992, 1738, 1874, 1511 + 862 + 259 ]


    @test [ deaths(deathdat; alter=a, jahr=2017, bundesland="Schleswig-Holstein", kw=1, geschlecht="Männlich")
            for a in DeutschlandDaten.Altersgruppen_Bundesländer ] ==
                [  61, 75, 101, 80  ]

    
    @test [ deaths(deathdat; alter=a, jahr=2018, bundesland="Bayern", kw=6, geschlecht="Männlich")
           for a in DeutschlandDaten.Altersgruppen_Bundesländer ] ==
               [ 250, 256, 487, 406  ]

    @test [ deaths(deathdat; alter=a, jahr=2021, bundesland="Niedersachsen", kw=6, geschlecht="Weiblich")
           for a in DeutschlandDaten.Altersgruppen_Bundesländer ] ==
               [ 97, 124, 324, 503 ]


    @test [ deaths(deathdat; alter=a, jahr=2016, bundesland="Baden-Württemberg", kw=52, geschlecht="Weiblich")
           for a in DeutschlandDaten.Altersgruppen_Bundesländer ] ==
               [ 94, 124, 350, 595 ]
                   
    
    # Write your tests here.
end
