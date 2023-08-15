module Routes exposing (FeedType(..), ProfileDestination(..), Route(..), href, match)

-- import Browser

import Html
import Html.Attributes
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)

 
type ProfileDestination
    = Favorited
    | WholeProfile

type FeedType
    = Global
    | Yours 

type
    Route
    -- URL parsing = extract information from the url
    -- Going to add strings and stuff that they input to know what specific page to go to :)
    = Index FeedType
    | Auth
    | Editor String
    | Login
    | Article String
    | Profile String ProfileDestination
    | Settings


routes : Parser (Route -> a) a
routes =
    -- Parser.s "#" </> 
    Parser.oneOf
        [ Parser.map (Index Global) Parser.top --#/ ? 
        , Parser.map (Index Yours) (Parser.s "Y") --hmm how do I fix
        , Parser.map Auth (Parser.s "register")
        , Parser.map Editor (Parser.s "createpost" </> Parser.string)
        , Parser.map Login (Parser.s "login")
        , Parser.map Article (Parser.s "article" </> Parser.string) --article slug
        , Parser.map (\s -> Profile s Favorited) (Parser.s "profile" </> Parser.string </> Parser.s "favorites") -- profile username
        , Parser.map (\s -> Profile s WholeProfile) (Parser.s "profile" </> Parser.string) --profile username
        , Parser.map Settings (Parser.s "settings")
        ]


routeToUrl : Route -> String
routeToUrl route =
    --accept route and convert it to a string path via pattern matching
    case route of
        Index Global ->
            "/#/"
        
        Index Yours -> -- want this to be the same
            "/#/Y"

        Auth ->
            "/#/register"

        Editor slug ->
            "/#/createpost/" ++ slug

        Login ->
            "/#/login"

        Article slug ->
            "/article/" ++ slug

        Profile username WholeProfile ->
            "/#/profile/" ++ username

        Profile username Favorited ->
            "/#/profile/" ++ username ++ "/favorites"

        Settings ->
            "/#/settings"


href : Route -> Html.Attribute msg
href route =
    -- convert route into a string using routeToUrl then pipe result -> Html.Attributes.href
    -- which allows you to build links to pages via Route constructors
    Html.Attributes.href (routeToUrl route)


match : Url -> Maybe Route
match url =
    -- match function that uses the routes parser to convert URLs
    Parser.parse routes url


-- Parser.parse tries to parse the url’s path field with the provided parser. It returns
-- a Maybe because the parser may not match the current path. In this case, if
-- the parser matches, then Parser.parse will return a Route constructor inside Just.
-- Otherwise, it will return Nothing.
