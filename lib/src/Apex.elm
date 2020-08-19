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
    = LineChart String (List Point)


encodeChart : ChartDefinition subject -> Json.Encode.Value
encodeChart definition =
    case definition of
        LineChart serieName points ->
            Json.Encode.object
                [ ( "series"
                  , Json.Encode.list
                        (\serie ->
                            Json.Encode.object
                                [ ( "name", Json.Encode.string serieName )
                                , ( "data"
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



-- alternative approach that might be better


type Chart
    = Chart ChartSeries Options


type alias ChartSeries =
    List Series


type Series
    = SingleValue (List Float)
    | PairedValue (List Point)


type alias Options =
    { --| note this will change to a real type
      noData : String
    , chart : ChartOptions

    --| note this will change to a real type
    , dataLabels : Bool
    , stroke : StokeOptions
    , grid : GridOptions
    , legend : LegendOptions
    }


defaultOptions : Options
defaultOptions =
    { noData = "loading ..."
    , chart = defaultChartOptions
    , dataLabels = False
    , stroke = defaultStrokeOptions
    }


type alias ChartOptions =
    { type_ : Maybe String
    , toolbar : Bool
    , zoom : Bool
    }


defaultChartOptions : ChartOptions
defaultChartOptions =
    { type_ = Nothing
    , toolbar = False
    , zoom = False
    }


type alias StokeOptions =
    { curve : String
    , show : Bool
    , width : Int
    }


defaultStrokeOptions : StokeOptions
defaultStrokeOptions =
    { curve = "smooth"
    , show = True
    , width = 2
    }


type alias GridOptions =
    Bool


chart : Chart
chart =
    Chart []
        defaultOptions


type alias LegendOptions =
    Bool
