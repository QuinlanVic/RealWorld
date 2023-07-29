module Main exposing (main)

import Article
import Auth
import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Navigation
import Debug exposing (log)
import Editor
import Html exposing (..)
import Html.Attributes exposing (class, href, id, placeholder, style, type_)
import Html.Events exposing (onClick)
import Http
import Index as PublicFeed
import Json.Decode exposing (Decoder, bool, field, int, list, nullable, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Json.Encode as Encode
import Login
import Profile
import Routes exposing (Route(..))
import Settings
import Url exposing (Url)


type CurrentPage
    = PublicFeed PublicFeed.Model
    | Auth Auth.User 
    | Editor Editor.Model
    | Login Auth.User
    | Article Article.Model
    | Profile Profile.Model
    | Settings Settings.Model
    | NotFound


type alias User =
    { email : String --all of these fields are contained in the response from the server (besides last 3)
    , token : String
    , username : String
    , bio : Maybe String
    , image : Maybe String
    }


type alias RegUser =
    { email : String --all of these fields are contained in the response from the server (besides last 3)
    , token : String
    , username : String
    , bio : Maybe String
    , image : Maybe String
    , password : String --user's password
    , signedUpOrloggedIn : Bool --bool saying if they've signed up or not (maybe used later)
    , errmsg : String --display any API errors from authentication
    , usernameError : Maybe String
    , emailError : Maybe String
    , passwordError : Maybe String
    }


type alias Model =
    { page : CurrentPage
    , navigationKey : Navigation.Key -- program will supply navigationKey at runtime
    , url : Url
    , currentPage : String
    , isLoggedIn : Bool
    , user : User
    }


defaultUser : User
defaultUser =
    { email = ""
    , token = ""
    , username = ""
    , bio = Just ""
    , image = Just ""
    }

defaultAuthor : Editor.Author 
defaultAuthor =
    { username = ""
    , bio = Just ""
    , image = Just ""
    , following = False
    }

defaultArticle : Editor.Article
defaultArticle =
    { slug = ""
    , title = ""
    , description = ""
    , body = ""
    , tagList = [ "" ]
    , createdAt = ""
    , updatedAt = ""
    , favorited = False
    , favoritesCount = 0
    , author = defaultAuthor
    }

initialModel : Navigation.Key -> Url -> Model
initialModel navigationKey url =
    { page = NotFound
    , navigationKey = navigationKey
    , url = url
    , currentPage = ""
    , isLoggedIn = False -- this is what I NEED
    , user = defaultUser
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
        , expect = Http.expectJson GotArticle (field "article" Article.articleDecoder)
        }


fetchProfile : String -> Cmd Msg
fetchProfile username =
    Http.get
        { url = baseUrl ++ "api/profiles/" ++ username
        , expect = Http.expectJson GotProfile (field "profile" Profile.profileDecoder)
        }


encodeUser : RegUser -> Encode.Value
encodeUser user =
    --used to encode user sent to the server via POST request body (for registering)
    Encode.object
        [ ( "username", Encode.string user.username )
        , ( "email", Encode.string user.email )
        , ( "password", Encode.string user.password )
        ]


userDecoder : Decoder User
userDecoder =
    succeed User
        |> required "email" string
        |> required "token" string
        |> required "username" string
        |> required "bio" (nullable string)
        |> required "image" (nullable string)



-- saveUser : RegUser -> Cmd Msg
-- saveUser user =
--     let
--         body =
--             Http.jsonBody <| Encode.object [ ( "user", encodeUser <| user ) ]
--     in
--     Http.post
--         { body = body
--         , expect = Http.expectJson LoadUser (field "user" userDecoder) -- wrap JSON received in LoadUser Msg
--         , url = baseUrl ++ "api/users"
--         }


getUser : User -> Cmd Msg
getUser user =
    --GET logged in user upon loadin
    let
        headers =
            [ Http.header "Authorization" ("Token " ++ user.token) ]
    in
    Http.request
        { method = "GET"
        , headers = headers
        , url = baseUrl ++ "api/user"
        , expect = Http.expectJson GotUser (field "user" userDecoder)
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
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
    | GotArticle (Result Http.Error Article.Article)
    | GotProfile (Result Http.Error Profile.ProfileType)
    | GotUser (Result Http.Error User)


convertUser : RegUser -> User
convertUser regUser =
    { email = regUser.email
    , token = regUser.token
    , username = regUser.username
    , bio = regUser.bio
    , image = regUser.image
    }


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
            ( { model 
                | page = Editor 
                    { user = model.user
                    , article = defaultArticle
                    , created = False
                    , titleError = Just ""
                    , bodyError = Just ""
                    , descError = Just ""
                    }
                , currentPage = "Editor" 
              }
            , Cmd.map EditorMessage editorCmd )

        Just Routes.Login ->
            let
                ( loginUser, loginCmd ) =
                    Login.init
            in
            ( { model | page = Login loginUser, currentPage = "Login" }, Cmd.map LoginMessage loginCmd )

        -- tricky
        Just (Routes.Article slug) ->
            -- Whenever we go to the Article page now, we have to fetch the article and initialise the page
            -- ( model, fetchArticle slug )
            let
                ( articleModel, articleCmd ) =
                    Article.init
            in
            ( { model | page = Article articleModel }, Cmd.map ArticleMessage articleCmd )

        -- tricky
        Just (Routes.Profile username) ->
            -- ( model, fetchProfile username )
            let
                ( profileModel, profileCmd ) =
                    Profile.init
            in
            ( { model | page = Profile profileModel, currentPage = "Profile" }, Cmd.map ProfileMessage profileCmd )

        -- tricky
        Just Routes.Settings ->
            -- ( model, fetchProfile model.user.username )
            let
                ( settingsUserSettings, settingsCmd ) =
                    Settings.init
            in
            ( { model | page = Settings settingsUserSettings, currentPage = "Settings" }, getUser model.user )

        Nothing ->
            ( { model | page = NotFound, currentPage = "NotFound" }, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.page ) of
        -- Debug.log "RECEIVED MESSAGE" msg
        ( NewRoute maybeRoute, _ ) ->
            setNewPage maybeRoute model

        -- got the article, now pass it to Article's model
        ( GotArticle (Ok article), _ ) ->
            ( { model
                | page = Article { article = article, author = article.author, comments = Nothing, newComment = "" }
              }
            , Cmd.none
            )

        -- error, just display the same page as before (Probably could do more here)
        ( GotArticle (Err _), _ ) ->
            ( model, Cmd.none )

        -- get the profile you are going to visit
        ( GotProfile (Ok profile), _ ) ->
            ( { model | page = Profile { articlesMade = Nothing, favoritedArticles = Nothing, profile = profile } }, Cmd.none )

        -- error, just display the same page as before (Probably could do more)
        ( GotProfile (Err _), _ ) ->
            ( model, Cmd.none )

        -- get the user to go to their settings
        ( GotUser (Ok user), _ ) ->
            ( { model
                | page =
                    Settings
                        { user = user
                        , password = ""
                        , signedUpOrloggedIn = False
                        , errmsg = ""
                        , usernameError = Just ""
                        , emailError = Just ""
                        , passwordError = Just ""
                        }
              }
            , Cmd.none
            )

        -- error, just display the same page as before (Probably could do more) 
        ( GotUser (Err error), _ ) ->
            ( { model | currentPage = "Home" }, Cmd.none )

        -- Index
        ( PublicFeedMessage publicFeedMsg, PublicFeed publicFeedModel ) ->
            let
                ( updatedPublicFeedModel, publicFeedCmd ) =
                    PublicFeed.update publicFeedMsg publicFeedModel
            in
            ( { model
                | page = PublicFeed updatedPublicFeedModel
                , currentPage = "Home"
              }
            , Cmd.map PublicFeedMessage publicFeedCmd
            )

        -- Auth
        -- intercept this message :)
        ( AuthMessage (Auth.SignedUpGoHome (Ok gotUser)), _ ) ->
            let
                ( publicFeedModel, publicFeedCmd ) =
                    PublicFeed.init
            in
            -- change the page to the home page and also update the Main model's user field
            ( { model
                | user = convertUser gotUser --convert to normal user type
                , isLoggedIn = True
                , page = PublicFeed publicFeedModel
                , currentPage = "Home"
              }
            , Cmd.map PublicFeedMessage publicFeedCmd
            )

        ( AuthMessage authMsg, Auth authUser ) ->
            let
                ( updatedAuthUser, authCmd ) =
                    Auth.update authMsg authUser
            in
            ( { model | page = Auth updatedAuthUser }, Cmd.map AuthMessage authCmd )

        -- Editor
        ( EditorMessage editorMsg, Editor editorArticle ) ->
            let
                ( updatedEditorArticle, editorCmd ) =
                    Editor.update editorMsg editorArticle
            in
            ( { model | page = Editor updatedEditorArticle }, Cmd.map EditorMessage editorCmd )

        -- Login
        ( LoginMessage (Login.SignedUpGoHome (Ok gotUser)), _ ) ->
            let
                ( publicFeedModel, publicFeedCmd ) =
                    PublicFeed.init
            in
            -- change the page to the home page and also update the Main model's user field
            ( { model
                | user = convertUser gotUser --convert to normal user type
                , isLoggedIn = True
                , page = PublicFeed publicFeedModel
                , currentPage = "Home"
              }
            , Cmd.map PublicFeedMessage publicFeedCmd
            )

        ( LoginMessage loginMsg, Login loginUser ) ->
            let
                ( updatedLoginUser, loginCmd ) =
                    Login.update loginMsg loginUser
            in
            ( { model | page = Login updatedLoginUser }, Cmd.map LoginMessage loginCmd )

        -- Article
        ( ArticleMessage articleMsg, Article articleModel ) ->
            let
                ( updatedArticleModel, articleCmd ) =
                    Article.update articleMsg articleModel
            in
            ( { model | page = Article updatedArticleModel }, Cmd.map ArticleMessage articleCmd )

        -- Profile
        ( ProfileMessage profileMsg, Profile profileModel ) ->
            let
                ( updatedProfileModel, profileCmd ) =
                    Profile.update profileMsg profileModel
            in
            ( { model | page = Profile updatedProfileModel }, Cmd.map ProfileMessage profileCmd )

        -- Settings
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


maybeImageBio : Maybe String -> String
maybeImageBio maybeIB =
    case maybeIB of
        Just imagebio ->
            imagebio

        Nothing ->
            ""


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

                -- , li [ class (isActivePage "User") ] [ a [ class "nav-link", Routes.href Routes.Settings ] [ i [ class "ion-gear-a" ] [], text " Settings" ] ] -- \u{00A0}
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
                -- could make a function for doing all of this
                [ li [ class (isActivePage "Home") ] [ a [ class "nav-link", Routes.href Routes.Index ] [ text "Home :)" ] ]
                , li [ class (isActivePage "Editor") ] [ a [ class "nav-link", Routes.href Routes.Editor ] [ i [ class "ion-compose" ] [], text (" " ++ "New Article") ] ] --&nbsp; in Elm?
                , li [ class (isActivePage "Settings") ] [ a [ class "nav-link", Routes.href Routes.Settings ] [ i [ class "ion-gear-a" ] [], text " Settings" ] ] -- \u{00A0}

                -- add user's profile information
                -- , li [ class (isActivePage "Profile") ] [ a [ class "nav-link", Routes.href Routes.Profile ] [ img [ src (maybeImageBio model.user.image), class "user-img" ] [], text " Settings" ] ]
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
    -- Also, do not show "Your Feed" if the user is logged out :)
    if model.isLoggedIn then
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
