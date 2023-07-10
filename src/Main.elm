module Main exposing (main)

import Auth
import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Navigation
import Editor
import Html exposing (..)
import Html.Attributes exposing (class, href, id, placeholder, style, type_)
import Html.Events exposing (onClick)
import Index as PublicFeed
import Login
import Post
import Profile
import Routes exposing (Route(..))
import Settings
import Url exposing (Url)


type CurrentPage
    = PublicFeed PublicFeed.Model
    | Auth Auth.User
    | Editor Editor.Article
    | Login Auth.User
    | Post Post.Model
    | Profile Profile.Model
    | Settings Settings.UserSettings
    | NotFound



--   LoginOrSomethingLikeIt Auth.User
-- | Edit Editor.Article
-- | Post Post.Model
-- | Profile Profile.Model
-- | Settings Settings.UserSettings
-- | NotFound


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
        PublicFeed publicFeedModel ->
            ( "Conduit"
            , PublicFeed.view publicFeedModel |> Html.map PublicFeedMessage
              -- , h1 [] [ text "Public Feed" ]
            )

        Auth authUser ->
            ( "Auth"
            , Auth.view authUser |> Html.map AuthMessage
              -- , h1 [] [ text "Auth" ]
            )

        Editor editorArticle ->
            ( "Editor"
            , Editor.view editorArticle |> Html.map EditorMessage
              -- , h1 [] [ text "Editor" ]
            )

        Login loginUser ->
            ( "Login"
            , Login.view loginUser |> Html.map LoginMessage
              -- , h1 [] [ text "Login" ]
            )

        Post postModel ->
            ( "Article"
            , Post.view postModel |> Html.map PostMessage
              -- , h1 [] [ text "Article" ]
            )

        Profile profileModel ->
            ( "Profile"
            , Profile.view profileModel |> Html.map ProfileMessage
              -- , h1 [] [ text "Profile" ]
            )

        Settings settingsUserSettings ->
            ( "Settings"
            , Settings.view settingsUserSettings |> Html.map SettingsMessage
              -- , h1 [] [ text "Settings" ]
            )

        NotFound ->
            ( "Not Found"
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
--             [ onClick (Visit <| Internal { url | path = "createpost" })
--             , style "cursor" "pointer"
--             ]
--             [ text "Feeling creative?" ]
--         ]
--     )
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
        Just Routes.Index ->
            let
                ( publicFeedModel, publicFeedCmd ) =
                    PublicFeed.init ()
            in
            ( { model | page = PublicFeed publicFeedModel }, Cmd.map PublicFeedMessage publicFeedCmd )

        Just Routes.Auth ->
            let
                ( authUser, authCmd ) =
                    Auth.init
            in
            ( { model | page = Auth authUser }, Cmd.map AuthMessage authCmd )

        Just Routes.Editor ->
            let
                ( editorArticle, editorCmd ) =
                    Editor.init
            in
            ( { model | page = Editor editorArticle }, Cmd.map EditorMessage editorCmd )

        Just Routes.Login ->
            let
                ( loginUser, loginCmd ) =
                    Login.init
            in
            ( { model | page = Login loginUser }, Cmd.map LoginMessage loginCmd )

        Just Routes.Post ->
            let
                ( postModel, postCmd ) =
                    Post.init
            in
            ( { model | page = Post postModel }, Cmd.map PostMessage postCmd )

        Just Routes.Profile ->
            let
                ( profileModel, profileCmd ) =
                    Profile.init
            in
            ( { model | page = Profile profileModel }, Cmd.map ProfileMessage profileCmd )

        Just Routes.Settings ->
            let
                ( settingsUserSettings, settingsCmd ) =
                    Settings.init
            in
            ( { model | page = Settings settingsUserSettings }, Cmd.map SettingsMessage settingsCmd )

        Nothing ->
            ( { model | page = NotFound }, Cmd.none )



-- Just Routes.Auth ->
--     ( { model | page = LoginOrSomethingLikeIt Auth.initialModel }
--     , Navigation.pushUrl model.navigationKey "signup"
--     )
-- Just Routes.Editor ->
--     ( { model | page = Edit Editor.initialModel }
--     , Navigation.pushUrl model.navigationKey "createpost"
--     )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        -- Debug.log "RECEIVED MESSAGE" msg
        ( NewRoute maybeRoute, _ ) ->
            setNewPage maybeRoute model

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

        ( PostMessage postMsg, Post postModel ) ->
            let
                ( updatedPostModel, postCmd ) =
                    Post.update postMsg postModel
            in
            ( { model | page = Post updatedPostModel }, Cmd.map PostMessage postCmd )

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

        -- Visit (Internal url) ->
        --     setNewPage
        --         (Routes.match url)
        --         model
        _ ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- later, when dealing with subscriptions :O
-- case model.page of
--     PublicFeed publicFeedModel ->
--     PublicFeed.subscriptions publicFeedModel
--     |> Sub.map PublicFeedMsg
--     _ ->
--     Sub.none


type Msg
    = NewRoute (Maybe Routes.Route)
    | Visit UrlRequest
    | PublicFeedMessage PublicFeed.Msg
    | AuthMessage Auth.Msg
    | EditorMessage Editor.Msg
    | LoginMessage Login.Msg
    | PostMessage Post.Msg
    | ProfileMessage Profile.Msg
    | SettingsMessage Settings.Msg



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
