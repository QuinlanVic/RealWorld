module Tests exposing (..)

import Expect
import Fuzz exposing (Fuzzer)
import Html.Attributes exposing (type_, value)
import Index exposing (Msg(..), initialModel)
import Profile exposing (formatDate, monthName)
import Random
import Settings exposing (Model, Msg(..), update)
import Test exposing (..)
import Test.Html.Event as Event
import Test.Html.Query as Query
import Test.Html.Selector exposing (attribute, class, id, tag, text)


exampleDate : String
exampleDate =
    "2022-12-09T13:46:24.263Z"


exampleDate2 : String
exampleDate2 =
    "2019-01-29T13:46:24.263Z"


isLeapYear : Int -> Int
isLeapYear year_ =
    let
        isDivisibleBy n =
            remainderBy n year_ == 0
    in
    if isDivisibleBy 4 && not (isDivisibleBy 100) || isDivisibleBy 400 then
        1

    else
        0


daysInMonth : Int -> Int -> Int
daysInMonth year_ month_ =
    case month_ of
        2 ->
            if isLeapYear year_ == 1 then
                29

            else
                28

        4 ->
            30

        6 ->
            30

        9 ->
            30

        11 ->
            30

        _ ->
            31


dateFuzzer : Fuzzer ( Int, Int, Int )
dateFuzzer =
    -- returns a random valid date (year, month, day)
    let
        randomYear =
            Random.int Random.minInt Random.maxInt

        randomMonth =
            Random.int 1 12

        generator =
            Random.pair randomYear randomMonth |> Random.andThen (\( year, month ) -> Random.int 1 (daysInMonth year month) |> Random.map (\day -> ( year, month, day )))

        -- shrinker dateTuple = Shrink.tuple3 ( Shrink.int, Shrink.int, Shrink.int ) dateTuple
    in
    Fuzz.fromGenerator generator


type
    Date
    --Date custom type (opaque so users can't access its fields so if you change it later on they don't have to change their whole codebases too)
    = Date { year : Int, month : Int, day : Int } --Date value accepts a record argument with 3 Int fields (year, month, day)



--have to offer functions for using the opaque type and returning its fields, just make sure the functions type annotation stays the same and if you change the field's name you'll be gucci


formatDigString : Int -> String
formatDigString day =
    if day < 10 then
        "0" ++ String.fromInt day

    else
        String.fromInt day


create : Int -> Int -> Int -> String
create year_ month_ day_ =
    --create Date
    String.fromInt
        (if year_ < 0 then
            year_ * -1

         else
            year_
        )
        ++ "-"
        ++ formatDigString month_
        ++ "-"
        ++ formatDigString day_
        ++ "T13:46:24.263Z"


testMultipleDates : Test
testMultipleDates =
    -- eg) '2022-12-09T13:46:24.263Z' -> 'December 09, 2022'
    describe "formatDate with multiple dates"
        [ fuzz dateFuzzer "formats the date properly" <|
            \( year, month, day ) ->
                create year month day
                    |> formatDate
                    |> Expect.equal
                        (monthName (formatDigString month)
                            ++ " "
                            ++ formatDigString day
                            ++ ", "
                            ++ String.fromInt
                                (if year < 0 then
                                    year * -1

                                 else
                                    year
                                )
                        )
        ]


suite : Test
suite =
    -- eg) '2022-12-09T13:46:24.263Z' -> 'December 09, 2022'
    -- describe function to add a description string to the list of tests
    describe "formatDate"
        -- test function with a description of the test to write unit test
        [ test "formats the date from 'year-month-dayThour:min:sec.msZ' to 'month-name day-num, year-num'"
            (\_ ->
                -- give the "formatDate" function an exampleDate and feed its output into Expect.equal function
                formatDate exampleDate
                    -- Expect.equal function checks if the output from formatDate is the same as what is expected
                    |> Expect.equal "December 09, 2022"
            )
        , test "formats the date from 'year-month-dayThour:min:sec.msZ' to 'month-name day-num, year-num' 2"
            (\_ ->
                -- give the "formatDate" function an exampleDate and feed its output into Expect.equal function
                formatDate exampleDate2
                    -- Expect.equal function checks if the output from formatDate is the same as what is expected
                    |> Expect.equal "January 29, 2019"
            )
        , testMultipleDates
        ]


defaultUser : Settings.User
defaultUser =
    { email = ""
    , token = ""
    , username = ""
    , bio = Just ""
    , image = Just ""
    }


testModel : Settings.Model
testModel =
    { user = defaultUser
    , password = ""
    , updated = False
    , errmsg = ""
    , usernameError = Just ""
    , emailError = Just ""
    , passwordError = Just ""
    }



-- application testing?


suite2 : Test
suite2 =
    -- describe function to add a description string to the list of tests
    describe "update"
        -- test function with a description of the test to write unit test
        [ test "updates the password field of the model"
            (\_ ->
                -- give the "update" function a message and model and pass its output through the Tuple.first function
                Settings.update (SavePassword "Quinlan") testModel
                    -- extract only the model (first element in the tuple)
                    |> Tuple.first
                    -- Expect.equal function checks if the new model is as expected
                    |> Expect.equal { testModel | password = "Quinlan" }
            )
        , test "Change the username of the user"
            (\_ ->
                -- give the "update" function a message and model and pass its output through the Tuple.first function
                Settings.update (SaveName "Quinlan") testModel
                    -- extract only the model (first element in the tuple)
                    |> Tuple.first
                    -- Expect.equal function checks if the new model is as expected
                    |> Expect.equal { testModel | user = Settings.updateUsername testModel.user "Quinlan" }
            )
        ]



-- initialModel : Index.Model
-- initialModel =
--     { globalfeed = Just [ articlePreview1, articlePreview2 ]
--     , yourfeed = Just []
--     , tags = Just [ " programming", " javascript", " angularjs", " react", " mean", " node", " rails" ]
--     , user = defaultUser
--     , showGF = True
--     , showTag = False
--     , tagfeed = Just []
--     , tag = ""
--     }


suite3 : Test
suite3 =
    -- describe function to add a description string to the list of tests
    describe "view"
        -- test function with a description of the test to write unit test
        [ test "displays the selected tag"
            (\_ ->
                let
                    initialModel2 =
                        { initialModel | showGF = False, showTag = True, tag = "welcome" }
                in
                -- pass initialModel with some updated characters into viewThreeFeeds
                Index.viewThreeFeeds initialModel2
                    -- query Elm's virtual DOM with this next function
                    |> Query.fromHtml
                    -- find the element you are searching for (id with string called "tag")
                    |> Query.find [ id "tag" ]
                    -- Query.has function checks if the element is as expected
                    |> Query.has [ text " welcome " ]
            )
        ]


suite4 : Test
suite4 =
    -- describe function to add a description string to the list of tests
    describe "events"
        -- test function with a description of the test to write unit test
        [ test "receives selected tag to change to tagfeed"
            (\_ ->
                -- pass list of tags into viewTags
                Index.viewTags ( Just [ "welcome", "implementations", "introduction", "codebaseShow", "ipsum", "qui", "cupiditate", "et", "quia", "deserunt" ] )
                    -- query Elm's virtual DOM with this next function
                    |> Query.fromHtml
                    -- find the element you are searching for (tag is button with id with string called "welcome")
                    |> Query.find [ tag "button", id "welcome" ]
                    -- Event.simulate function mimics an event on an element (onClick)
                    |> Event.simulate (Event.click)
                    -- Query.has function checks if the message from the event is as expected
                    |> Event.expect (Index.LoadTF "welcome")
            )
        ]
