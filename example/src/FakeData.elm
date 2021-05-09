module FakeData exposing (fakeYearlyUsage)

import Random  exposing (Generator)
import Time
import Time.Extra 


type alias Usage = Time.Posix

fakeYearlyUsage: Time.Zone -> Time.Posix -> (List Usage -> msg) -> Cmd msg
fakeYearlyUsage zone now toMsg= 
    Random.generate toMsg (generateYearlyUsage zone now)


generateYearlyUsage: Time.Zone -> Time.Posix -> Generator (List Usage)
generateYearlyUsage zone now = 
    let
        startOfCurrentMonth = Time.Extra.floor Time.Extra.Month zone now
        startOfLastYear = Time.Extra.add Time.Extra.Year -1 zone now
    in
    List.range 0 11 
    |> List.map (\offset -> 
        { min = Time.Extra.add Time.Extra.Month offset zone startOfLastYear
        , max = startOfLastYear |> Time.Extra.add Time.Extra.Month offset zone  |> Time.Extra.ceil Time.Extra.Month offset zone})
    |> Debug.todo ""


usageLogGenerator: { min: Time.Posix, max: Time.Posix} ->  Generator Usage
usageLogGenerator { min, max } = 
    Random.int (Time.posixToMillis min) (Time.posixToMillis max) |> Time.millisToPosix


