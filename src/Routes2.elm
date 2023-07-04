module Routes2 exposing (Route(..), match)

-- import Browser
-- import Html exposing (Html, a, div, h1, i, text)
-- import Html.Attributes exposing (class)
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser)


type Route
    = Index
    | Auth 
    | Editor
    | Login
    | Article
    | Profile
    | Settings


routes : Parser (Route -> a) a
routes =
    Parser.oneOf
        [ Parser.map Index Parser.top --#/ ?
        , Parser.map Auth (Parser.s "signup")
        , Parser.map Editor (Parser.s "createpost") 
        , Parser.map Login (Parser.s "login")
        , Parser.map Article (Parser.s "article") --article name
        , Parser.map Profile (Parser.s "profile") --profile username
        , Parser.map Settings (Parser.s "settings")
        ]



-- match function that uses the routes parser to convert URLs


match : Url -> Maybe Route
match url =
    Parser.parse routes url



-- Parser.parse tries to parse the url’s path field with the provided parser. It returns
-- a Maybe because the parser may not match the current path. In this case, if
-- the parser matches, then Parser.parse will return a Route constructor inside Just.
-- Otherwise, it will return Nothing.
