module Apex exposing
    ( Point
    , XAxisType(..)
    , addColumnSeries
    , addLineSeries
    , chart
    , encodeChart
    , withLegends
    , withXAxisType
    )

import Json.Encode


type alias Point =
    { x : Float
    , y : Float
    }


type Chart
    = Chart ChartSeries Options


type alias ChartSeries =
    List Series


type Series
    = Single String SingleSeriesData
    | Paired String PairedSeriesType PairedSeriesData


type alias SingleSeriesData =
    List Float


type alias PairedSeriesData =
    List Point


type PairedSeriesType
    = Lines
    | Columns


type alias Options =
    { --| note this will change to a real type
      noData : String
    , chart : ChartOptions

    --| note this will change to a real type
    , dataLabels : Bool
    , stroke : StokeOptions
    , grid : GridOptions
    , legend : LegendOptions
    , xAxis : XAxisOptions
    }


defaultOptions : Options
defaultOptions =
    { noData = "loading ..."
    , chart = defaultChartOptions
    , dataLabels = False
    , stroke = defaultStrokeOptions
    , grid = defaultGridOptions
    , legend = defaultLegendOptions
    , xAxis = defaultXAxisOptions
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


defaultGridOptions : GridOptions
defaultGridOptions =
    False


type alias LegendOptions =
    Bool


defaultLegendOptions : GridOptions
defaultLegendOptions =
    False


type alias XAxisOptions =
    XAxisType


type XAxisType
    = Category
    | DateTime
    | Numeric


defaultXAxisOptions : XAxisOptions
defaultXAxisOptions =
    defaultXAxisType


defaultXAxisType : XAxisType
defaultXAxisType =
    Numeric


chart : Chart
chart =
    Chart []
        defaultOptions


addLineSeries : String -> PairedSeriesData -> Chart -> Chart
addLineSeries name series (Chart allSeries options) =
    Chart (Paired name Lines series :: allSeries) options


addColumnSeries : String -> PairedSeriesData -> Chart -> Chart
addColumnSeries name series (Chart allSeries options) =
    Chart (Paired name Columns series :: allSeries) options


withLegends : Bool -> Chart -> Chart
withLegends bool (Chart allSeries options) =
    Chart allSeries { options | legend = bool }


withXAxisType : XAxisType -> Chart -> Chart
withXAxisType type_ (Chart allSeries options) =
    Chart allSeries { options | xAxis = type_ }


encodeChart : Chart -> Json.Encode.Value
encodeChart (Chart allSeries options) =
    Json.Encode.object
        [ ( "series"
          , Json.Encode.list encodeSeries allSeries
          )
        , ( "noData", Json.Encode.object [ ( "text", Json.Encode.string options.noData ) ] )
        , ( "chart"
          , encodeChartOptions options.chart
          )
        , ( "dataLabels", Json.Encode.object [ ( "enabled", Json.Encode.bool options.dataLabels ) ] )
        , ( "stroke", encodeStrokeOptions options.stroke )
        , ( "grid", encodeGridOptions options.grid )
        , ( "legend", encodeLegendOptions options.legend )
        , ( "xaxis", encodeXAxisOptions options.xAxis )
        ]


encodeSeries : Series -> Json.Encode.Value
encodeSeries series =
    case series of
        Single name data ->
            Json.Encode.object
                [ ( "name", Json.Encode.string name )
                , ( "data"
                  , Json.Encode.list Json.Encode.float data
                  )
                ]

        Paired name type_ dataPoints ->
            Json.Encode.object
                [ ( "name", Json.Encode.string name )
                , ( "type"
                  , case type_ of
                        Lines ->
                            Json.Encode.string "line"

                        Columns ->
                            Json.Encode.string "column"
                  )
                , ( "data"
                  , Json.Encode.list encodePoint dataPoints
                  )
                ]


encodePoint : Point -> Json.Encode.Value
encodePoint { x, y } =
    Json.Encode.object [ ( "x", Json.Encode.float x ), ( "y", Json.Encode.float y ) ]


encodeStrokeOptions : StokeOptions -> Json.Encode.Value
encodeStrokeOptions { curve, show, width } =
    Json.Encode.object
        [ ( "curve", Json.Encode.string curve )
        , ( "show", Json.Encode.bool show )
        , ( "width", Json.Encode.int width )
        ]


encodeGridOptions : GridOptions -> Json.Encode.Value
encodeGridOptions show =
    if show then
        Json.Encode.object []

    else
        Json.Encode.object
            [ ( "show", Json.Encode.bool False )
            , ( "padding"
              , Json.Encode.object
                    [ ( "left", Json.Encode.int 0 )
                    , ( "right", Json.Encode.int 0 )
                    , ( "top", Json.Encode.int 0 )
                    ]
              )
            ]


encodeLegendOptions : LegendOptions -> Json.Encode.Value
encodeLegendOptions show =
    Json.Encode.object [ ( "show", Json.Encode.bool show ) ]


encodeChartOptions : ChartOptions -> Json.Encode.Value
encodeChartOptions { type_, toolbar, zoom } =
    Json.Encode.object
        [ ( "width", Json.Encode.string "100%" )
        , ( "type", type_ |> Maybe.withDefault "line" |> Json.Encode.string )
        , ( "toolbar", Json.Encode.object [ ( "show", Json.Encode.bool toolbar ) ] )
        , ( "zoom", Json.Encode.object [ ( "enabled", Json.Encode.bool zoom ) ] )
        ]


encodeXAxisOptions : XAxisOptions -> Json.Encode.Value
encodeXAxisOptions type_ =
    Json.Encode.object
        [ ( "type"
          , Json.Encode.string <|
                case type_ of
                    Category ->
                        "category"

                    DateTime ->
                        "datetime"

                    Numeric ->
                        "numeric"
          )
        ]
