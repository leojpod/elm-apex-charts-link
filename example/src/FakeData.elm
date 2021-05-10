module FakeData exposing
    ( Usage
    , fakeYearlyUsage
    )

import Random exposing (Generator)
import Random.Extra
import Time
import Time.Extra


type alias Usage =
    Time.Posix


fakeYearlyUsage : Time.Zone -> Time.Posix -> (List Usage -> msg) -> Cmd msg
fakeYearlyUsage zone now toMsg =
    Random.generate toMsg (generateYearlyUsage zone now)


generateYearlyUsage : Time.Zone -> Time.Posix -> Generator (List Usage)
generateYearlyUsage zone now =
    let
        startOfCurrentMonth =
            Time.Extra.floor Time.Extra.Month zone now

        startOfLastYear =
            Time.Extra.add Time.Extra.Year -1 zone startOfCurrentMonth
    in
    List.range 0 11
        |> List.map
            (\offset ->
                Time.Extra.add Time.Extra.Month offset zone startOfLastYear
            )
        |> List.map (monthlyUsageGenerator zone)
        |> Random.Extra.sequence
        |> Random.map List.concat


usageLogGenerator : { min : Time.Posix, max : Time.Posix } -> Generator Usage
usageLogGenerator { min, max } =
    Random.int (Time.posixToMillis min) (Time.posixToMillis max) |> Random.map Time.millisToPosix


monthlyUsageGenerator : Time.Zone -> Time.Posix -> Generator (List Usage)
monthlyUsageGenerator zone start =
    Random.int 1 50
        |> Random.andThen
            (\timesUsed ->
                Random.list timesUsed
                    (usageLogGenerator { min = start, max = Time.Extra.ceiling Time.Extra.Month zone start })
            )
