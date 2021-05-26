module Apex.Options exposing (encode)

import Charts.Options exposing (Options)


encode : Options -> List ( String, Json.Encode.Value )
