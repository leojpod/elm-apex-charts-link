module Apex exposing
    ( ChartDefinition(..)
    , Point
    , encodeChart
    )

import Json.Encode



{--|
  NOTE: we need to have 2 set of types underneeth it: one to help build the stuff from an end-user point of view 
  and one to build something we'll easily encode

--}


type alias Point =
    { x : Float
    , y : Float
    }


type ChartDefinition subject
    = LineChart (List Point)


encodeChart : ChartDefinition subject -> Json.Encode.Value
encodeChart definition =
    case definition of
        LineChart points ->
            Json.Encode.object
                [ ( "series"
                  , Json.Encode.list
                        (\serie ->
                            Json.Encode.object
                                [ ( "data"
                                  , Json.Encode.list
                                        (\{ x, y } ->
                                            Json.Encode.object
                                                [ ( "x", Json.Encode.float x )
                                                , ( "y", Json.Encode.float y )
                                                ]
                                        )
                                        serie
                                  )
                                ]
                        )
                        [ points ]
                  )
                ]
