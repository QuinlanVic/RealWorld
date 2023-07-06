module Main2 exposing (main)

import Auth
import Browser exposing (Document, UrlRequest)
import Browser.Navigation as Navigation
import Editor
import Html exposing (..)
import Html.Attributes exposing (class, href, id, placeholder, style, type_)
import Index
import Login
import Post
import Profile
import Routes
import Settings
import Url exposing (Url)


type Page
    = PublicFeed
    | Register
    | CreateArticle
    | Login
    | Article
    | Profile
    | Settings
    | NotFound


type alias Model =
    { page : Page
    , navigationKey : Navigation.Key -- program will supply navigationKey at runtime
    }


initialModel : Navigation.Key -> Model
initialModel navigationKey =
    { page = NotFound
    , navigationKey = navigationKey
    }


init : () -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init () url navigationKey =
    -- program supplies initial Url when the app boots
    -- Convert url into a route and construct initialmodel -> pass to setNewPage to set initial page
    setNewPage (Routes.match url) (initialModel navigationKey)



---- VIEW ----


viewContent : Page -> ( String, Html Msg )
viewContent page =
    case page of
        PublicFeed ->
            ( "Conduit"
            , h1 [] [ text "Public Feed" ]
            )

        Register ->
            ( "Register"
            , h1 [] [ text "Register" ]
            )

        CreateArticle ->
            ( "CreateArticle"
            , h1 [] [ text "CreateArticle" ]
            )

        Login ->
            ( "Login"
            , h1 [] [ text "Login" ]
            )

        Article ->
            ( "Article"
            , h1 [] [ text "Article" ]
            )

        Profile ->
            ( "Profile"
            , h1 [] [ text "Profile" ]
            )

        Settings ->
            ( "Settings"
            , h1 [] [ text "Settings" ]
            )

        NotFound ->
            ( "Not Found"
            , div [ class "not-found" ]
                [ h1 [] [ text "Page Not Found" ] ]
            )



-- viewHeader : Html Msg
-- viewHeader =
--     div [class "header"]
--         [div [class "header-nav"]
--             [ a [class "nav-brand", Routes.href Routes.Home] --a = anchor tag
--                 [text "Picshare"]
--             , a [class "nav-account", Routes.href Routes.Account]
--                 [i [class "fa fa-2x fa-gear"] [] ]
--                 --account link displays a gear with an i tag and Font Awesome classes
--             ]
--         ]


view : Model -> Document Msg
view model =
    let
        ( title, content ) =
            viewContent model.page
    in
    { title = title
    , body = [ content ] --viewHeader
    }



---- UPDATE ----


type Msg
    = NewRoute (Maybe Routes.Route)
    | Visit UrlRequest



-- | AccountMsg Account.Msg --add new message that wraps a message in an AccountMsg wrapper to create a modular update function
-- | PublicFeedMsg PublicFeed.Msg --like above 2.0
-- | UserFeedMsg UserFeed.Msg --like above 3.0
--helper function
-- processPageUpdate : (pageModel -> Page) -> (pageMsg -> Msg) -> Model -> (pageModel, Cmd pageMsg) -> (Model, Cmd Msg)
-- processPageUpdate createPage wrapMsg model (pageModel, pageCmd) =
--     ({model | page = createPage pageModel}, Cmd.map wrapMsg pageCmd)


setNewPage : Maybe Routes.Route -> Model -> ( Model, Cmd Msg )
setNewPage maybeRoute model =
    --update model's page basede on the new route
    case maybeRoute of
        Just Routes.Index ->
            ( { model | page = PublicFeed }, Cmd.none )

        Just Routes.Auth ->
            ( { model | page = Register }, Cmd.none ) 

        Just Routes.Editor ->
            ( { model | page = CreateArticle }, Cmd.none )

        Just Routes.Login ->
            ( { model | page = Login }, Cmd.none )

        Just Routes.Article ->
            ( { model | page = Article }, Cmd.none )

        Just Routes.Profile ->
            ( { model | page = Profile }, Cmd.none )

        Just Routes.Settings ->
            ( { model | page = Settings }, Cmd.none )

        Nothing ->
            ( { model | page = NotFound }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewRoute maybeRoute ->
            setNewPage maybeRoute model

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = Visit
        , onUrlChange = Routes.match >> NewRoute
        }



--wrap current URL whenever the URL changes in the browser and then passes the wrapped value to update
--transform the incoming Url into Maybe Route with Routes.match then pass Maybe Route onto the NewRoute constructor
-- elm make src/Main.elm --output=main.js