module Charts.RoundCharts exposing (..)

import Charts.Options exposing (Options)


type RoundChartType
    = Pie
    | Radial


type alias RoundChartOptions =
    { type_ : RoundChartType }


defaultChartOptions : RoundChartOptions
defaultChartOptions =
    { type_ = Pie }


type alias RoundChartData =
    { name : String
    , series : List ( String, Float )
    , chartOptions : RoundChartOptions
    , options : Options
    }


type RoundChart
    = RoundChart RoundChartData


pieChart : String -> List ( String, Float ) -> RoundChart
pieChart name series =
    RoundChart
        { name = name
        , series = series
        , chartOptions = { defaultChartOptions | type_ = Pie }
        , options = Charts.Options.default
        }


radialBar : String -> List ( String, Float ) -> RoundChart
radialBar name series =
    RoundChart
        { name = name
        , series = series
        , chartOptions = { defaultChartOptions | type_ = Radial }
        , options = Charts.Options.default
        }
