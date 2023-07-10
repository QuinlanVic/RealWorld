module Main exposing (main)

import Auth
import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Navigation
import Editor
import Html exposing (..)
import Html.Attributes exposing (class, href, id, placeholder, style, type_)
import Html.Events exposing (onClick)
import Index
import Login
import Post
import Profile
import Routes
import Settings
import Url exposing (Url)


type CurrentPage
    = -- PublicFeed
      -- | Register
      -- | CreateArticle
      -- | Login
      -- | Article
      -- | Profile
      -- | Settings
      -- | NotFound
      LoginOrSomethingLikeIt Auth.User
    | Edit Editor.Article
    | Post Post.Model
    | Profile Profile.Model
    | Settings Settings.UserSettings
    | NotFound


type alias Model =
    { page : CurrentPage
    , navigationKey : Navigation.Key -- program will supply navigationKey at runtime
    , url : Url
    }


initialModel : Navigation.Key -> Url -> Model
initialModel navigationKey url =
    { page = NotFound
    , navigationKey = navigationKey
    , url = url
    }


init : () -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init () url navigationKey =
    -- program supplies initial Url when the app boots
    -- Convert url into a route and construct initialmodel -> pass to setNewPage to set initial page
    setNewPage (Routes.match url) (initialModel navigationKey url)



---- VIEW ----


viewContent :
    Model
    -> ( String, Html Msg ) --Model
viewContent model =
    let
        url =
            model.url
    in
    case model.page of
        -- model.page
        -- PublicFeed ->
        --     ( "Conduit"
        --     , h1 [] [ text "Public Feed" ]
        --     )
        -- Register ->
        --     ( "Register"
        --     , h1 [] [ text "Register" ]
        --     )
        -- CreateArticle ->
        --     ( "CreateArticle"
        --     , h1 [] [ text "CreateArticle" ]
        --     )
        -- Login ->
        --     ( "Login"
        --     , h1 [] [ text "Login" ]
        --     )
        -- Article ->
        --     ( "Article"
        --     , h1 [] [ text "Article" ]
        --     )
        -- Profile ->
        --     ( "Profile"
        --     , h1 [] [ text "Profile" ]
        --     )
        -- Settings ->
        --     ( "Settings"
        --     , h1 [] [ text "Settings" ]
        --     )
        -- NotFound ->
        --     ( "Not Found"
        --     , div [ class "not-found" ]
        --         [ h1 [] [ text "Page Not Found" ] ]
        --     )
        LoginOrSomethingLikeIt user ->
            ( "What up, homie?"
            , Html.map AuthMessage (Auth.view user)
            )

        Edit article ->
            ( "Be The Change You Want To See In The Article"
            , Html.map EditorMessage <| Editor.view article
            )

        _ ->
            ( "Unimplemented ....... yet!"
            , div
                []
                [ text "UNIMPLEMENTED but check this out:"
                , br [] []
                , a
                    [ onClick (Visit <| Internal { url | path = "signup" })
                    , style "cursor" "pointer"
                    ]
                    [ text "Auth page yo" ]
                , br [] []
                , a
                    [ onClick (Visit <| Internal { url | path = "createpost" })
                    , style "cursor" "pointer"
                    ]
                    [ text "Feeling creative?" ]
                ]
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
            viewContent model
    in
    { title = title
    , body = [ content ] --viewHeader
    }



---- UPDATE ----


type Msg
    = NewRoute (Maybe Routes.Route)
    | Visit UrlRequest
    | AuthMessage Auth.Msg
    | EditorMessage Editor.Msg



-- | AccountMsg Account.Msg --add new message that wraps a message in an AccountMsg wrapper to create a modular update function
-- | PublicFeedMsg PublicFeed.Msg --like above 2.0
-- | UserFeedMsg UserFeed.Msg --like above 3.0
--helper function
-- processPageUpdate : (pageModel -> Page) -> (pageMsg -> Msg) -> Model -> (pageModel, Cmd pageMsg) -> (Model, Cmd Msg)
-- processPageUpdate createPage wrapMsg model (pageModel, pageCmd) =
--     ({model | page = createPage pageModel}, Cmd.map wrapMsg pageCmd)


setNewPage : Maybe Routes.Route -> Model -> ( Model, Cmd Msg )
setNewPage maybeRoute model =
    --update model's page based on the new route
    case maybeRoute of
        -- Just Routes.Index ->
        --     ( { model | page = PublicFeed }, Cmd.none )
        -- Just Routes.Auth ->
        --     ( { model | page = Register }, Cmd.none )
        -- Just Routes.Editor ->
        --     ( { model | page = CreateArticle }, Cmd.none )
        -- Just Routes.Login ->
        --     ( { model | page = Login }, Cmd.none )
        -- Just Routes.Article ->
        --     ( { model | page = Article }, Cmd.none )
        -- Just Routes.Profile ->
        --     ( { model | page = Profile }, Cmd.none )
        -- Just Routes.Settings ->
        --     ( { model | page = Settings }, Cmd.none )
        -- Nothing ->
        --     ( { model | page = NotFound }, Cmd.none )
        Just Routes.Auth ->
            ( { model | page = LoginOrSomethingLikeIt Auth.initialModel }
            , Navigation.pushUrl model.navigationKey "signup"
            )

        Just Routes.Editor ->
            ( { model | page = Edit Editor.initialModel }
            , Navigation.pushUrl model.navigationKey "createpost"
            )

        _ ->
            ( { model | page = NotFound }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case Debug.log "RECEIVED MESSAGE" msg of
        NewRoute maybeRoute ->
            setNewPage maybeRoute model

        Visit (Internal url) ->
            setNewPage
                (Routes.match url)
                model

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
