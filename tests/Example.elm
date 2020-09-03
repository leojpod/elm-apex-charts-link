module Example exposing (suite)

-- exposing (Expectation)
-- import Fuzz exposing (Fuzzer, int, list, string)
-- import Expect

import Test exposing (Test, describe, test)


suite : Test
suite =
    describe "Basic examples"
        [ test "simple points" <| \_ -> Test.todo "not done yet" ]
