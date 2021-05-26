module Apex.RoundChart exposing (encode)

import Charts.RoundCharts exposing (RoundChart(..))
import Json.Encode


encode: RoundChart -> Json.Encode.Value
encode (roundChart ) = 
    let 
    {name, series, chartOptions, options} = Charts.RoundCharts.chartData 
    Json.Encode.object <|
        [ ("labels", Json.Encode.list Json.Encode.string <| Tuple.first <| List.unzip series)
        , ("series", Json.Encode.list Json.Encode.float <| Tuple.second <| List.unzip series)
        ]
        ++ Apex.Options.encode options
