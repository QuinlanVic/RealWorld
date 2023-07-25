module Main exposing (main)

import Article
import Auth
import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Navigation
import Editor
import Html exposing (..)
import Html.Attributes exposing (class, href, id, placeholder, style, type_)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, bool, field, int, list, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Json.Encode as Encode
import Index as PublicFeed
import Login
import Profile
import Routes exposing (Route(..))
import Settings
import Url exposing (Url)
 

type CurrentPage
    = PublicFeed PublicFeed.Model
    | Auth Auth.User
    | Editor Editor.Article
    | Login Auth.User
    | Article Article.Model
    | Profile Profile.Model
    | Settings Auth.User
    | NotFound



--   LoginOrSomethingLikeIt Auth.User
-- | Edit Editor.Article
-- | Article Article.Model
-- | Profile Profile.Model
-- | Settings Settings.UserSettings
-- | NotFound


type alias Model =
    { page : CurrentPage
    , navigationKey : Navigation.Key -- program will supply navigationKey at runtime
    , url : Url
    , currentPage : String
    , isLoggedIn : Bool
    }


initialModel : Navigation.Key -> Url -> Model
initialModel navigationKey url =
    { page = NotFound
    , navigationKey = navigationKey
    , url = url
    , currentPage = ""
    , isLoggedIn = False -- this is what I NEED
    }


init : () -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init () url navigationKey =
    -- browser supplies initial Url when the app boots
    -- Convert url into a route and construct initialmodel -> pass to setNewPage to set initial page
    setNewPage (Routes.match url) (initialModel navigationKey url)


baseUrl : String
baseUrl =
    "http://localhost:8000/"


fetchArticle : String -> Cmd Msg
fetchArticle slug =
    Http.get
        { url = baseUrl ++ "api/articles/" ++ slug
        , expect = Http.expectJson GotArticle (field "article" Editor.articleDecoder)
        }


---- UPDATE ----
-- | AccountMsg Account.Msg --add new message that wraps a message in an AccountMsg wrapper to create a modular update function
-- | PublicFeedMsg PublicFeed.Msg --like above 2.0
-- | UserFeedMsg UserFeed.Msg --like above 3.0
--helper function
-- processPageUpdate : (pageModel -> Page) -> (pageMsg -> Msg) -> Model -> (pageModel, Cmd pageMsg) -> (Model, Cmd Msg)
-- processPageUpdate createPage wrapMsg model (pageModel, pageCmd) =
--     ({model | page = createPage pageModel}, Cmd.map wrapMsg pageCmd)


type Msg
    = NewRoute (Maybe Routes.Route)
    | Visit UrlRequest
    | PublicFeedMessage PublicFeed.Msg
    | AuthMessage Auth.Msg
    | EditorMessage Editor.Msg
    | LoginMessage Login.Msg
    | ArticleMessage Article.Msg
    | ProfileMessage Profile.Msg
    | SettingsMessage Settings.Msg
    | GotArticle (Result Http.Error Editor.Article)


setNewPage : Maybe Routes.Route -> Model -> ( Model, Cmd Msg )
setNewPage maybeRoute model =
    --update model's page based on the new route
    case maybeRoute of
        Just Routes.Index ->
            let
                ( publicFeedModel, publicFeedCmd ) =
                    PublicFeed.init
            in
            ( { model | page = PublicFeed publicFeedModel, currentPage = "Home" }, Cmd.map PublicFeedMessage publicFeedCmd )

        Just Routes.Auth ->
            let
                ( authUser, authCmd ) =
                    Auth.init
            in
            ( { model | page = Auth authUser, currentPage = "Auth" }, Cmd.map AuthMessage authCmd )

        Just Routes.Editor ->
            let
                ( editorArticle, editorCmd ) =
                    Editor.init
            in
            ( { model | page = Editor editorArticle, currentPage = "Editor" }, Cmd.map EditorMessage editorCmd )

        Just Routes.Login ->
            let
                ( loginUser, loginCmd ) =
                    Login.init
            in
            ( { model | page = Login loginUser, currentPage = "Login" }, Cmd.map LoginMessage loginCmd )

        Just Routes.Article ->
            let
                ( articleModel, articleCmd ) =
                    Article.init
            in
            ( { model | page = Article articleModel, currentPage = "Article" }, Cmd.map ArticleMessage articleCmd )

        Just Routes.Profile ->
            let
                ( profileModel, profileCmd ) =
                    Profile.init
            in
            ( { model | page = Profile profileModel, currentPage = "Profile" }, Cmd.map ProfileMessage profileCmd )

        Just Routes.Settings ->
            let
                ( settingsUserSettings, settingsCmd ) =
                    Settings.init
            in
            ( { model | page = Settings settingsUserSettings, currentPage = "Settings" }, Cmd.map SettingsMessage settingsCmd )

        Nothing ->
            ( { model | page = NotFound, currentPage = "NotFound" }, Cmd.none )



-- Just Routes.Auth ->
--     ( { model | page = LoginOrSomethingLikeIt Auth.initialModel }
--     , Navigation.pushUrl model.navigationKey "signup"
--     )
-- Just Routes.Editor ->
--     ( { model | page = Edit Editor.initialModel }
--     , Navigation.pushUrl model.navigationKey "createarticle"
--     )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        -- Debug.log "RECEIVED MESSAGE" msg
        ( NewRoute maybeRoute, _ ) ->
            setNewPage maybeRoute model

        -- intercept the global message from publicfeed that we want
        ( PublicFeedMessage (PublicFeed.FetchArticle slug), _ ) ->
            ( model, Cmd.batch [fetchArticle slug ])

        ( GotArticle (Ok article), _ ) ->
            ( { model | page = Article { article = article, author = article.author, comments = Just [], newComment "" } }, Cmd.none ) 
        
        (GotArticle (Err _), _) -> 
            ( model, Cmd.none )

        ( PublicFeedMessage publicFeedMsg, PublicFeed publicFeedModel ) ->
            let
                ( updatedPublicFeedModel, publicFeedCmd ) =
                    PublicFeed.update publicFeedMsg publicFeedModel
            in
            ( { model | page = PublicFeed updatedPublicFeedModel }, Cmd.map PublicFeedMessage publicFeedCmd )

        ( AuthMessage authMsg, Auth authUser ) ->
            let
                ( updatedAuthUser, authCmd ) =
                    Auth.update authMsg authUser
            in
            ( { model | page = Auth updatedAuthUser }, Cmd.map AuthMessage authCmd )

        ( EditorMessage editorMsg, Editor editorArticle ) ->
            let
                ( updatedEditorArticle, editorCmd ) =
                    Editor.update editorMsg editorArticle
            in
            ( { model | page = Editor updatedEditorArticle }, Cmd.map EditorMessage editorCmd )

        ( LoginMessage loginMsg, Login loginUser ) ->
            let
                ( updatedLoginUser, loginCmd ) =
                    Login.update loginMsg loginUser
            in
            ( { model | page = Login updatedLoginUser }, Cmd.map LoginMessage loginCmd )

        ( ArticleMessage articleMsg, Article articleModel ) ->
            let
                ( updatedArticleModel, articleCmd ) =
                    Article.update articleMsg articleModel
            in
            ( { model | page = Article updatedArticleModel }, Cmd.map ArticleMessage articleCmd )

        ( ProfileMessage profileMsg, Profile profileModel ) ->
            let
                ( updatedProfileModel, profileCmd ) =
                    Profile.update profileMsg profileModel
            in
            ( { model | page = Profile updatedProfileModel }, Cmd.map ProfileMessage profileCmd )

        ( SettingsMessage settingsMsg, Settings settingsUserSettings ) ->
            let
                ( updatedSettingsUserSettings, settingsCmd ) =
                    Settings.update settingsMsg settingsUserSettings
            in
            ( { model | page = Settings updatedSettingsUserSettings }, Cmd.map SettingsMessage settingsCmd )

        -- ( Visit (Browser.Internal url), _ ) ->
        --     ( model, Navigation.pushUrl model.navigationKey (Url.toString url) )
        ( Visit urlRequest, _ ) ->
            case urlRequest of
                Internal url ->
                    ( model, Navigation.pushUrl model.navigationKey (Url.toString url) )

                External url ->
                    ( model, Navigation.load url )

        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    -- going to use this to trigger when a user logs in? :)
    -- Browser.Navigation.onUrlChange (NvigateTo << parseUrl)
    -- later, when dealing with subscriptions? :O
    -- case model.page of
    --     PublicFeed publicFeedModel ->
    --     PublicFeed.subscriptions publicFeedModel
    --     |> Sub.map PublicFeedMsg
    --     _ ->
    --     Sub.none
    Sub.none



---- VIEW ----


viewContent :
    Model
    -> ( String, Html Msg ) --Model
viewContent model =
    let
        url =
            model.url

        -- isLoggedIn =
        --     model.isLoggedIn
    in
    case model.page of
        PublicFeed publicFeedModel ->
            ( "Conduit - Conduit"
            , PublicFeed.view publicFeedModel |> Html.map PublicFeedMessage
              -- , h1 [] [ text "Public Feed" ]
            )

        Auth authUser ->
            ( "Auth - Conduit"
            , Auth.view authUser |> Html.map AuthMessage
              -- , h1 [] [ text "Auth" ]
            )

        Editor editorArticle ->
            ( "Editor - Conduit"
            , Editor.view editorArticle |> Html.map EditorMessage
              -- , h1 [] [ text "Editor" ]
            )

        Login loginUser ->
            ( "Login - Conduit"
            , Login.view loginUser |> Html.map LoginMessage
              -- , h1 [] [ text "Login" ]
            )

        Article articleModel ->
            ( "Article - Conduit"
            , Article.view articleModel |> Html.map ArticleMessage
              -- , h1 [] [ text "Article" ]
            )

        Profile profileModel ->
            ( "Profile - Conduit"
            , Profile.view profileModel |> Html.map ProfileMessage
              -- , h1 [] [ text "Profile" ]
            )

        Settings settingsUserSettings ->
            ( "Settings - Conduit"
            , Settings.view settingsUserSettings |> Html.map SettingsMessage
              -- , h1 [] [ text "Settings" ]
            )

        NotFound ->
            ( "Not Found - Conduit"
            , div [ class "not-found" ]
                [ h1 [] [ text "Page Not Found" ] ]
            )



-- LoginOrSomethingLikeIt user ->
--     ( "What up, homie?"
--     , Html.map AuthMessage (Auth.view user)
--     )
-- Edit article ->
--     ( "Be The Change You Want To See In The Article"
--     , Html.map EditorMessage <| Editor.view article
--     )
-- _ ->
--     ( "Unimplemented ....... yet!"
--     , div
--         []
--         [ text "UNIMPLEMENTED but check this out:"
--         , br [] []
--         , a
--             [ onClick (Visit <| Internal { url | path = "signup" })
--             , style "cursor" "pointer"
--             ]
--             [ text "Auth page yo" ]
--         , br [] []
--         , a
--             [ onClick (Visit <| Internal { url | path = "createarticle" })
--             , style "cursor" "pointer"
--             ]
--             [ text "Feeling creative?" ]
--         ]
--     )


viewHeaderLO : Model -> Html Msg
viewHeaderLO model =
    --Logged out universal header used on all pages BUT changes the active element depending on the page
    let
        isActivePage pageName =
            if model.currentPage == pageName then
                "nav-item active"

            else
                "nav-item"
    in
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ class "navbar-brand", Routes.href Routes.Index ] [ text "conduit" ]
            , ul [ class "nav navbar-nav pull-xs-right" ]
                --could make a function for doing all of this
                [ li [ class (isActivePage "Home") ] [ a [ class "nav-link", Routes.href Routes.Index ] [ text "Home :)" ] ]

                -- , li [ class (isActivePage "Editor") ] [ a [ class "nav-link", Routes.href Routes.Editor ] [ i [ class "ion-compose" ] [], text (" " ++ "New Article") ] ] --&nbsp; in Elm?
                , li [ class (isActivePage "Login") ] [ a [ class "nav-link", Routes.href Routes.Login ] [ text "Log in" ] ]
                , li [ class (isActivePage "Auth") ] [ a [ class "nav-link", Routes.href Routes.Auth ] [ text "Sign up" ] ]

                -- , li [ class (isActivePage "Settings") ] [ a [ class "nav-link", Routes.href Routes.Settings ] [ i [ class "ion-gear-a" ] [], text " Settings" ] ] -- \u{00A0}
                ]
            ]
        ]


viewHeader : Model -> Html Msg
viewHeader model =
    --Logged in universal header used on all pages BUT changes the active element depending on the page
    let
        isActivePage pageName =
            if model.currentPage == pageName then
                "nav-item active"

            else
                "nav-item"
    in
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ class "navbar-brand", Routes.href Routes.Index ] [ text "conduit" ]
            , ul [ class "nav navbar-nav pull-xs-right" ]
                --could make a function for doing all of this
                [ li [ class (isActivePage "Home") ] [ a [ class "nav-link", Routes.href Routes.Index ] [ text "Home :)" ] ]
                , li [ class (isActivePage "Editor") ] [ a [ class "nav-link", Routes.href Routes.Editor ] [ i [ class "ion-compose" ] [], text (" " ++ "New Article") ] ] --&nbsp; in Elm?
                , li [ class (isActivePage "Login") ] [ a [ class "nav-link", Routes.href Routes.Login ] [ text "Log in" ] ]
                , li [ class (isActivePage "Auth") ] [ a [ class "nav-link", Routes.href Routes.Auth ] [ text "Sign up" ] ]
                , li [ class (isActivePage "Settings") ] [ a [ class "nav-link", Routes.href Routes.Settings ] [ i [ class "ion-gear-a" ] [], text " Settings" ] ] -- \u{00A0}
                ]
            ]
        ]


view : Model -> Document Msg
view model =
    let
        ( title, content ) =
            viewContent model
    in
    -- loggedin vs loggedout headers (WHAT I NEED!)
    if True then
        -- model.isLoggedIn
        { title = title
        , body = [ viewHeader model, content ]
        }

    else
        { title = title
        , body = [ viewHeaderLO model, content ]
        }



---- PROGRAM ----


main : Program () Model Msg
main =
    -- init gets the current Url from the browsers navigation bar
    -- click on link = intercepted as a UrlRequest, does not load new HTML, url gets sent to onUrlChange
    -- onUrlChange wraps the current URL whenever the URL changes in the browser and then passes the wrapped value to update
    -- it transforms the incoming Url into Maybe Route with Routes.match then pass Maybe Route onto the NewRoute constructor
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = Visit
        , onUrlChange = Routes.match >> NewRoute
        }



-- serve using: npx serve -c serve.json
