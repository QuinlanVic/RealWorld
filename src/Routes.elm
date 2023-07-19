module Routes exposing (Route(..), href, match)

-- import Browser

import Html
import Html.Attributes
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser)


type Route
    = Index
    | Auth
    | Editor
    | Login
    | Post
    | Profile String 
    | Settings


routes : Parser (Route -> a) a
routes =
    Parser.oneOf
        [ Parser.map Index Parser.top --#/ ?
        , Parser.map Auth (Parser.s "register")
        , Parser.map Editor (Parser.s "createpost")
        , Parser.map Login (Parser.s "login")
        , Parser.map Post (Parser.s "article") --article name
        , Parser.map Profile (Parser.s "profile") --profile username 
        , Parser.map Settings (Parser.s "settings")
        ]


routeToUrl : Route -> String
routeToUrl route =
    --accept route and convert it to a string path via pattern matching
    case route of
        Index ->
            "/"

        Auth ->
            "/register"

        Editor ->
            "/createpost"

        Login ->
            "/login"

        Post ->
            "/article"

        Profile username ->
            "/profiles" ++ username 

        Settings ->
            "/settings"


href : Route -> Html.Attribute msg
href route =
    -- convert route into a string using routeToUrl then pipe result -> Html.Attributes.href
    -- which allows you to build links to pages via Route constructors
    Html.Attributes.href (routeToUrl route)


match : Url -> Maybe Route
match url =
    -- match function that uses the routes parser to convert URLs
    Parser.parse routes (Debug.log "TRYING TO MATCH URL" url)



-- Parser.parse tries to parse the url’s path field with the provided parser. It returns
-- a Maybe because the parser may not match the current path. In this case, if
-- the parser matches, then Parser.parse will return a Route constructor inside Just.
-- Otherwise, it will return Nothing.
