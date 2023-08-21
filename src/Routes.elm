module Routes exposing (FeedType(..), ProfileDestination(..), Route(..), href, match)

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
    | Tag String


type Route
    = Home 
    | Auth
    | NewEditor 
    | Editor String
    | Login
    | Article String
    | Profile String ProfileDestination
    | Settings


routes : Parser (Route -> a) a
routes =
    -- URL parsing = extract information from the url
    -- Parser.s "#" </>
    -- parse path segments
    Parser.oneOf
        -- return thing on the left if the path to the right is a match
        [ Parser.map Home Parser.top  
        -- Parser.map (Index Global) (Parser.top)--#/ ?
        -- , Parser.map (Index Yours) (Parser.s "Y") --hmm how do I fix
        -- , Parser.map (\s -> Index (Tag s)) (Parser.s "T" </> Parser.string)
        , Parser.map Auth (Parser.s "register")
        , Parser.map NewEditor (Parser.s "editor")
        , Parser.map Editor (Parser.s "editor" </> Parser.string)
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
        Home ->
            "#/"

        -- Index Global ->
        --     "#/"

        -- Index Yours ->
        --     -- want this to be the same as above one
        --     "#/"

        -- Index (Tag tag) ->
        --     -- want this to be same as top one
        --     "#/T/" ++ tag

        Auth ->
            -- need /#/ before all of these
            "#/register"
        
        NewEditor ->
            "#/editor"

        Editor slug ->
            "#/editor/" ++ slug

        Login ->
            "#/login"

        Article slug ->
            "#/article/" ++ slug

        Profile username WholeProfile ->
            -- @ before username
            "#/profile/" ++ username

        Profile username Favorited ->
            -- @ before username
            "#/profile/" ++ username ++ "/favorites"

        Settings ->
            "#/settings"


href : Route -> Html.Attribute msg
href route =
    -- convert route into a string using routeToUrl then pipe result -> Html.Attributes.href
    -- which allows you to build links to pages via Route constructors
    Html.Attributes.href (routeToUrl route)


-- match : Url -> Maybe Route
-- match url =
--     -- match function that uses the routes parser to convert URLs
--     -- Parser.parse tries to parse the url’s path field with the provided parser.
--     -- It returns a Maybe because the parser may not match the current path.
--     -- In this case, if the parser matches, then Parser.parse will return a Route constructor inside Just.
--     -- Otherwise, it will return Nothing.
--     Parser.parse routes url



match : Url -> Maybe Route
match url =
    -- The RealWorld spec treats the fragment like a path.
    -- This makes it *literally* the path, so we can proceed
    -- with parsing as if it had been a normal path all along.
    { url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
        |> Parser.parse routes
