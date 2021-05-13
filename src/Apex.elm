module Apex exposing
    ( chart
    , Point
    , addLineSeries
    , addColumnSeries
    , withLegends
    , withXAxisType
    , XAxisType(..)
    , encodeChart
    , apexChart
    )

{-| This package provide a (WIP) integration between elm and [Apex charts](https://apexcharts.com/) via either custom-element or ports.

The main thing this package does is provide a simple and declarative way to describe a chart and encode it so that it can directly be picked up by Apex Charts.

Note, this package comes with an "already made" custom component which you can install and use via the node package version of `elm-apex-charts-link` (see the README).

Here is how you would describe a simple chart with some options (checkout the example project for more use-cases):

        import Apex

        myChart : Html Msg
        myChart =
            Apex.apexChart
                (Apex.chart
                    |> Apex.addLineSeries "Connections by week" (connectionsByWeek logins)
                    |> Apex.addColumnSeries "Connections within office hour for that week" (dayTimeConnectionByWeek logins)
                    |> Apex.addColumnSeries "Connections outside office hour for that week" (outsideOfficeHourConnectionByWeek logins)
                    |> Apex.withXAxisType Apex.DateTime
                )
                []
                []


# When should I use this package?

For that please refer to the [README](./) page


# Creating charts


# Entry point

@docs chart


## Adding data

@docs Point

@docs addLineSeries

@docs addColumnSeries


## Configuring the display

@docs withLegends

@docs withXAxisType

@docs XAxisType

NOTE: A lot more support for options and type of series needs to be added


# Rendering charts

To render your chart you have 2 options:

  - encode it to JSON and send it to via a port to be rendered via JavaScript/TypeScript.

```elm
update : Msg -> Model -> ( Model, Cmd Msg )
update msg _ =
    case msg of
        LoadFakeLogins now ->
            let
                logins =
                    fictiveLogins Time.utc now
            in
            ( logins
            , updateChart <|
                Apex.encodeChart <|
                    (Apex.chart
                        |> Apex.addLineSeries "Connections by week" (connectionsByWeek logins)
                        |> Apex.addColumnSeries "Connections within office hour for that week" (dayTimeConnectionByWeek logins)
                        |> Apex.addColumnSeries "Connections outside office hour for that week" (outsideOfficeHourConnectionByWeek logins)
                        |> Apex.withXAxisType Apex.DateTime
                    )
            )
```

```js
app.ports.updateChart.subscribe((chartDescription) => {
  const chart = new ApexCharts(
    document.querySelector('#chart1'),
    chartDescription
  )
  chart.render()
})
```

@docs encodeChart

  - use `npm install elm-apex-charts-link` to gain access to the custom element and then use:

         import Apex

         myChart : Html Msg
         myChart =
             Apex.apexChart
                 (Apex.chart
                     |> Apex.addLineSeries "Connections by week" (connectionsByWeek logins)
                     |> Apex.addColumnSeries "Connections within office hour for that week" (dayTimeConnectionByWeek logins)
                     |> Apex.addColumnSeries "Connections outside office hour for that week" (outsideOfficeHourConnectionByWeek logins)
                     |> Apex.withXAxisType Apex.DateTime
                 )
                 []
                 []

@docs apexChart

-}

import Html exposing (Html)
import Html.Attributes
import Json.Encode


{-| this is the custom element wrapper.
Make sure that you have installed the javascript companion package (`npm i elm-apex-charts-link`) before using this function!
-}
apexChart : Chart -> List (Html.Attribute msg) -> List (Html msg) -> Html msg
apexChart aChart extraAttributes =
    Html.node "apex-chart"
        ((Html.Attributes.property "data" <|
            encodeChart aChart
         )
            :: extraAttributes
        )


{-| A simple record type to make things a bit clearer when writing series
-}
type alias Point =
    { x : Float
    , y : Float
    }


{-| This is an internal type to make sure we're keeping the definitions and list handling coherent and free from outside manipulation
-}
type Chart
    = Chart ChartSeries Options


{-| might be over zealous on the alias type but well...
-}
type alias ChartSeries =
    List Series


{-| there are 2 main types of series:

  - single point: for pie charts, radar charts and the like of them
  - paired point: for column, line, area, anything else really

-}
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


type ChartType
    = Unset
    | Infered String
    | Set String


setInferedType : String -> ChartType -> ChartType
setInferedType inferedType chartType =
    case chartType of
        Unset ->
            Infered inferedType

        Infered _ ->
            Infered inferedType

        _ ->
            chartType


chartTypeWithDefault : String -> ChartType -> String
chartTypeWithDefault default chartType =
    case chartType of
        Unset ->
            default

        Infered type_ ->
            type_

        Set type_ ->
            type_


type alias ChartOptions =
    { type_ : ChartType
    , toolbar : Bool
    , zoom : Bool
    }


defaultChartOptions : ChartOptions
defaultChartOptions =
    { type_ = Unset
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


{-| Describe how the x-axis of your graph should be labelled.

It can be either a Category, a DateTime or a Numeric value

NOTE: for the DateTime to properly work I suggest that the x-values in your series should be turned into miliseconds via `Time.posixToMillis`. I hope to find something better in due time but that's the best option until then.

-}
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


{-| this is the entry point of any chart: it gives you an empty chart with some default options
-}
chart : Chart
chart =
    Chart []
        defaultOptions


{-| as the name suggest, this add a line to your chart by creating a series with the given name and by linking the given points together.
-}
addLineSeries : String -> List Point -> Chart -> Chart
addLineSeries name series (Chart allSeries options) =
    let
        chartOptions =
            options.chart
    in
    Chart (Paired name Lines series :: allSeries)
        { options
            | chart =
                { chartOptions
                    | type_ = setInferedType "line" chartOptions.type_
                }
        }


{-| as the name suggest, this add a new column series to your chart using the given name and by adding a bar for each of the given points.
-}
addColumnSeries : String -> List Point -> Chart -> Chart
addColumnSeries name series (Chart allSeries options) =
    let
        chartOptions =
            options.chart
    in
    Chart (Paired name Columns series :: allSeries)
        { options
            | chart =
                { chartOptions
                    | type_ = setInferedType "bar" chartOptions.type_
                }
        }


{-| Allow to turn on or off the legend for the graph
-}
withLegends : Bool -> Chart -> Chart
withLegends bool (Chart allSeries options) =
    Chart allSeries { options | legend = bool }


{-| change the type of x-axis used in you graph
-}
withXAxisType : XAxisType -> Chart -> Chart
withXAxisType type_ (Chart allSeries options) =
    Chart allSeries { options | xAxis = type_ }


{-| this function takes a chart and turns it into JSON data that Apex Charts can understand

NOTE: if you are using the custom-element version you should not need to use this function

-}
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
        , ( "type", type_ |> chartTypeWithDefault "line" |> Json.Encode.string )
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
