module Main exposing (main)

import Article
import Auth
import Browser exposing (Document, UrlRequest(..))
import Browser.Navigation as Navigation
import Editor
import Html exposing (..)
import Html.Attributes exposing (class, src, style)
import Http
import Index as PublicFeed
import Json.Decode exposing (Decoder, field, list, nullable, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Login
import Profile
import Routes exposing (Route(..))
import Settings
import Task exposing (Task)
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
    -- all of these fields are contained in the response from the server
    { email : String
    , token : String
    , username : String
    , bio : Maybe String
    , image : Maybe String
    }


type alias RegUser =
    -- first five fields are contained in the response from the server
    { email : String
    , token : String
    , username : String
    , bio : Maybe String
    , image : Maybe String
    , password : String -- user's password
    , signedUpOrloggedIn : Bool -- bool saying if they've signed up or not
    , errmsg : String -- display any API errors from authentication

    -- input validation errors when a new user is registering themselves
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
    , article : Article.Article
    , comments : Maybe Article.Comments
    , profile : Profile.ProfileType
    , articlesMade : Maybe Profile.Feed
    , tag : String
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


defaultProfile : Profile.ProfileType
defaultProfile =
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


defaultComment : Article.Comment
defaultComment =
    { id = 0
    , createdAt = "Dec 29th"
    , updatedAt = ""
    , body = "With supporting text below as a natural lead-in to additional content."
    , author = defaultAuthor
    }


initialModel : Navigation.Key -> Url -> Model
initialModel navigationKey url =
    { page = NotFound
    , navigationKey = navigationKey
    , url = url
    , currentPage = ""
    , isLoggedIn = False
    , user = defaultUser
    , article = defaultArticle
    , comments = Just [ defaultComment ]
    , profile = defaultProfile
    , articlesMade = Nothing
    , tag = ""
    }


init : () -> Url -> Navigation.Key -> ( Model, Cmd Msg )
init () url navigationKey =
    -- browser supplies initial Url when the app boots
    -- Convert url into a route and construct initialmodel -> pass to setNewPage to set initial page
    setNewPage (Routes.match url) (initialModel navigationKey url)


baseUrl : String
baseUrl =
    "http://localhost:8000/"


handleJsonResponse : Decoder a -> Http.Response String -> Result Http.Error a
handleJsonResponse decoder response =
    case response of
        Http.BadUrl_ url ->
            Err (Http.BadUrl url)

        Http.Timeout_ ->
            Err Http.Timeout

        Http.BadStatus_ { statusCode } _ ->
            Err (Http.BadStatus statusCode)

        Http.NetworkError_ ->
            Err Http.NetworkError

        Http.GoodStatus_ _ body ->
            case Json.Decode.decodeString decoder body of
                Err _ ->
                    Err (Http.BadBody body)

                Ok result ->
                    Ok result


fetchArticle2 : String -> Task Http.Error Article.Article
fetchArticle2 slug =
    Http.task
        { url = baseUrl ++ "api/articles/" ++ slug
        , body = Http.emptyBody
        , headers = []
        , method = "GET"
        , resolver = Http.stringResolver <| handleJsonResponse <| field "article" Article.articleDecoder -- Decoder Article.Article
        , timeout = Nothing
        }


fetchArticleAndComments : String -> Task Http.Error ( Article.Article, Article.Comments )
fetchArticleAndComments slug =
    -- Function to fetch both article and comments sequentially
    fetchArticle2 slug
        |> Task.andThen
            (\article ->
                fetchComments2 slug
                    |> Task.map (\comments -> ( article, comments ))
            )


fetchArticleEditor : String -> Cmd Msg
fetchArticleEditor slug =
    Http.get
        { url = baseUrl ++ "api/articles/" ++ slug
        , expect = Http.expectJson GotArticleEditor (field "article" Article.articleDecoder)
        }


fetchComments2 : String -> Task Http.Error Article.Comments
fetchComments2 slug =
    Http.task
        { url = baseUrl ++ "api/articles/" ++ slug ++ "/comments"
        , method = "GET"
        , headers = []
        , body = Http.emptyBody
        , resolver = Http.stringResolver <| handleJsonResponse <| field "comments" (list Article.commentDecoder)
        , timeout = Nothing
        }


fetchProfile : String -> Cmd Msg
fetchProfile username =
    Http.get
        { url = baseUrl ++ "api/profiles/" ++ username
        , expect = Http.expectJson GotProfile (field "profile" Profile.profileDecoder)
        }


fetchProfile2 : String -> Task Http.Error Profile.ProfileType
fetchProfile2 username =
    Http.task
        { url = baseUrl ++ "api/profiles/" ++ username
        , resolver = Http.stringResolver <| handleJsonResponse <| field "profile" Profile.profileDecoder
        , method = "GET"
        , headers = []
        , body = Http.emptyBody
        , timeout = Nothing
        }


fetchProfileArticles2 : String -> Task Http.Error Profile.Feed
fetchProfileArticles2 username =
    -- get the articles the author of the profile has created and convert it into a task
    Http.task
        { url = baseUrl ++ "api/articles?author=" ++ username
        , resolver = Http.stringResolver <| handleJsonResponse <| field "articles" (list Article.articleDecoder)
        , method = "GET"
        , headers = []
        , body = Http.emptyBody
        , timeout = Nothing
        }


fetchFavoritedArticles : String -> Task Http.Error Profile.Feed
fetchFavoritedArticles username =
    -- get the articles the author has favorited and convert it into a task
    Http.task
        { url = baseUrl ++ "api/articles?favorited=" ++ username
        , resolver = Http.stringResolver <| handleJsonResponse <| field "articles" (list Article.articleDecoder)
        , method = "GET"
        , headers = []
        , body = Http.emptyBody
        , timeout = Nothing
        }


fetchProfileAndArticles : String -> Task Http.Error ( Profile.ProfileType, Profile.Feed )
fetchProfileAndArticles slug =
    -- Function to fetch both the profile and the articles that the profile has made sequentially
    fetchProfile2 slug
        |> Task.andThen
            (\article ->
                fetchProfileArticles2 slug
                    |> Task.map (\comments -> ( article, comments ))
            )


fetchProfileAndFavArticles : String -> Task Http.Error ( Profile.ProfileType, Profile.Feed )
fetchProfileAndFavArticles slug =
    -- Function to fetch both the profile and the articles the profile has favourited sequentially
    fetchProfile2 slug
        |> Task.andThen
            (\article ->
                fetchFavoritedArticles slug
                    |> Task.map (\comments -> ( article, comments ))
            )


fetchYourFeed : Model -> Task Http.Error PublicFeed.Feed
fetchYourFeed model =
    -- need some kind of authentication to know which articles to fetch depended on the user
    let
        headers =
            [ Http.header "Authorization" ("Token " ++ model.user.token) ]
    in
    -- convert to task
    Http.task
        { method = "GET"
        , headers = headers
        , body = Http.emptyBody
        , resolver = Http.stringResolver <| handleJsonResponse <| field "articles" (list Article.articleDecoder)
        , url = baseUrl ++ "api/articles/feed"
        , timeout = Nothing
        }


fetchTags : Task Http.Error PublicFeed.Tags
fetchTags =
    -- convert to task
    Http.task
        { url = baseUrl ++ "api/tags"
        , resolver = Http.stringResolver <| handleJsonResponse <| PublicFeed.tagDecoder
        , method = "GET"
        , headers = []
        , body = Http.emptyBody
        , timeout = Nothing
        }


fetchGlobalFeed : Task Http.Error PublicFeed.Feed
fetchGlobalFeed =
    -- convert to task
    Http.task
        { method = "GET"
        , headers = []
        , body = Http.emptyBody
        , resolver = Http.stringResolver <| handleJsonResponse <| field "articles" (list Article.articleDecoder)
        , url = baseUrl ++ "api/articles"
        , timeout = Nothing
        }


fetchTagFeed : String -> Task Http.Error PublicFeed.Feed
fetchTagFeed tag =
    -- convert to task
    Http.task
        { method = "GET"
        , headers = []
        , body = Http.emptyBody
        , resolver = Http.stringResolver <| handleJsonResponse <| field "articles" (list Article.articleDecoder)
        , url = baseUrl ++ "api/articles?tag=" ++ tag
        , timeout = Nothing
        }


fetchYourFeedAndTags : Model -> Task Http.Error ( PublicFeed.Feed, PublicFeed.Tags )
fetchYourFeedAndTags model =
    -- Function to fetch your feed and tags sequentially
    fetchYourFeed model
        |> Task.andThen
            (\articles ->
                fetchTags
                    |> Task.map (\tags -> ( articles, tags ))
            )


fetchGlobalFeedAndTags : Task Http.Error ( PublicFeed.Feed, PublicFeed.Tags )
fetchGlobalFeedAndTags =
    -- Function to fetch both global feed and tags sequentially
    fetchGlobalFeed
        |> Task.andThen
            (\articles ->
                fetchTags
                    |> Task.map (\tags -> ( articles, tags ))
            )


fetchTagFeedAndTags : String -> Task Http.Error ( PublicFeed.Feed, PublicFeed.Tags )
fetchTagFeedAndTags tag =
    -- Function to fetch both tag feed and tags sequentially
    fetchTagFeed tag
        |> Task.andThen
            (\articles ->
                fetchTags
                    |> Task.map (\tags -> ( articles, tags ))
            )


userDecoder : Decoder User
userDecoder =
    succeed User
        |> required "email" string
        |> required "token" string
        |> required "username" string
        |> required "bio" (nullable string)
        |> required "image" (nullable string)


getUser : User -> Cmd Msg
getUser user =
    -- GET logged in user upon loadin with authorisation
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
      -- | GotArticleArticle (Result Http.Error Article.Article) -- done with getting the comments in one message
    | GotProfile (Result Http.Error Profile.ProfileType)
    | GotUser (Result Http.Error User)
    | GotArticleEditor (Result Http.Error Article.Article)
      -- | GotComments (Result Http.Error Article.Comments) -- done with getting the article in one message
      -- | GotProfileArticles (Result Http.Error Profile.Feed) -- done with getting the profile in one message
    | GotArticleAndComments (Result Http.Error ( Article.Article, Article.Comments ))
    | GotProfileAndArticles (Result Http.Error ( Profile.ProfileType, Profile.Feed ))
    | GotProfileAndFavArticles (Result Http.Error ( Profile.ProfileType, Profile.Feed ))
    | GotYFAndTags (Result Http.Error ( PublicFeed.Feed, PublicFeed.Tags ))
    | GotGFAndTags (Result Http.Error ( PublicFeed.Feed, PublicFeed.Tags ))
    | GotTFAndTags (Result Http.Error ( PublicFeed.Feed, PublicFeed.Tags ))


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
        -- Just (Routes.Index dest) ->
        --     case dest of
        --         Routes.Global ->
        --             -- fetch the global feed
        --             let
        --                 ( publicFeedModel, publicFeedCmd ) =
        --                     PublicFeed.init
        --             in
        --             ( { model | page = PublicFeed { publicFeedModel | user = model.user }, currentPage = "Home" }
        --               -- Cmd.map PublicFeedMessage publicFeedCmd
        --             , Task.attempt GotGFAndTags fetchGlobalFeedAndTags
        --             )

        --         Routes.Yours ->
        --             -- fetch your feed
        --             let
        --                 ( publicFeedModel, publicFeedCmd ) =
        --                     PublicFeed.init
        --             in
        --             ( { model | page = PublicFeed { publicFeedModel | user = model.user, showGF = False, showTag = False }, currentPage = "Home" }
        --             , Task.attempt GotYFAndTags (fetchYourFeedAndTags model)
        --             )

        --         Routes.Tag tag ->
        --             -- fetch the feed of articles that has that tag
        --             let
        --                 ( publicFeedModel, publicFeedCmd ) =
        --                     PublicFeed.init
        --             in
        --             ( { model | page = PublicFeed { publicFeedModel | user = model.user, showGF = False, showTag = True, tag = tag }, currentPage = "Home", tag = tag }
        --             , Task.attempt GotTFAndTags (fetchTagFeedAndTags tag)
        --             )

        Just Routes.Home ->
            -- fetch the global feed
            let
                ( publicFeedModel, publicFeedCmd ) =
                    PublicFeed.init
            in
            ( { model | page = PublicFeed { publicFeedModel | user = model.user }, currentPage = "Home" }
                -- Cmd.map PublicFeedMessage publicFeedCmd
            , Task.attempt GotGFAndTags fetchGlobalFeedAndTags
            )

        Just Routes.Auth ->
            let 
                ( authUser, authCmd ) =
                    Auth.init
            in
            ( { model | page = Auth authUser, currentPage = "Auth" }, Cmd.map AuthMessage authCmd )
        
        Just Routes.NewEditor ->
            let
                ( editorModel, editorCmd ) =
                    Editor.init
            in
            ( { model
                    | page =
                        Editor
                            { user = model.user
                            , article = defaultArticle
                            , created = False
                            , titleError = Just ""
                            , bodyError = Just ""
                            , descError = Just ""
                            , tagInput = ""
                            }
                    , currentPage = "Editor"
                  }
                , Cmd.map EditorMessage editorCmd
                )

        -- tricky
        Just (Routes.Editor slug) ->
            let
                ( editorModel, editorCmd ) =
                    Editor.init
            in
                ( { model
                    | page =
                        Editor
                            { user = model.user
                            , article = defaultArticle
                            , created = False
                            , titleError = Just ""
                            , bodyError = Just ""
                            , descError = Just ""
                            , tagInput = ""
                            }
                    , currentPage = "Editor"
                  }
                , fetchArticleEditor slug
                )

        Just Routes.Login ->
            let
                ( loginUser, loginCmd ) =
                    Login.init
            in
            ( { model | page = Login loginUser, currentPage = "Login" }, Cmd.map LoginMessage loginCmd )

        -- tricky
        Just (Routes.Article slug) ->
            -- Whenever we go to the Article page now, we have to fetch the article and initialise the page
            let
                ( articleModel, articleCmd ) =
                    Article.init
            in
            -- first do fetchArticle then do fetchComments using Task.attempt
            -- Cmd.batch [ fetchArticle slug, fetchComments slug ]
            ( { model | page = Article articleModel }, Task.attempt GotArticleAndComments (fetchArticleAndComments slug) )

        -- tricky
        Just (Routes.Profile username dest) ->
            case dest of
                Routes.WholeProfile ->
                    let
                        ( profileModel, profileCmd ) =
                            Profile.init
                    in
                    ( { model
                        | page = Profile profileModel
                        , currentPage =
                            if model.user.username == username then
                                "Profile"

                            else
                                ""
                      }
                      -- first do fetchProfile then fetchArticles using Task.attempt
                      -- Cmd.batch [ fetchProfile username, fetchProfileArticles username ]
                    , Task.attempt GotProfileAndArticles (fetchProfileAndArticles username)
                    )

                Routes.Favorited ->
                    let
                        ( profileModel, profileCmd ) =
                            Profile.init
                    in
                    ( { model
                        | page = Profile profileModel
                        , currentPage =
                            if model.user.username == username then
                                "Profile"

                            else
                                ""
                      }
                      -- first do fetchProfile then fetchFavArticles using Task.attempt
                      -- Cmd.map ProfileMessage (Profile.fetchFavoritedArticles username)
                    , Task.attempt GotProfileAndFavArticles (fetchProfileAndFavArticles username)
                    )

        -- tricky
        Just Routes.Settings ->
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

        -- done with getting comments in one message below
        -- got the article, now pass it to Article's model
        -- ( GotArticleArticle (Ok article), _ ) ->
        --     ( { model
        --         | page = Article { article = article, comments = model.comments, newComment = "", user = model.user }
        --         , article = article
        --       }
        --     , Cmd.none
        --     )
        -- -- error, just display the same page as before (Probably could do more here)
        -- ( GotArticleArticle (Err _), _ ) ->
        --     ( model, Cmd.none )
        ( GotArticleEditor (Ok article), _ ) ->
            ( { model
                -- change taglist into taginput to display the old tags in a string format :)
                | page = Editor { user = model.user, article = article, created = False, titleError = Just "", bodyError = Just "", descError = Just "", tagInput = String.join "," article.tagList }
                , article = article
              }
            , Cmd.none
            )

        ( GotArticleEditor (Err _), _ ) ->
            ( model, Cmd.none )

        -- done with getting an article in one message below
        -- ( GotComments (Ok comments), _ ) ->
        --     -- hack job ree
        --     ( { model
        --         | page = Article { article = model.article, comments = Just comments, newComment = "", user = model.user }
        --         , comments = Just comments
        --       }
        --     , Cmd.none
        --     )
        -- ( GotComments (Err _), _ ) ->
        --     ( model, Cmd.none )
        -- get the profile you are going to visit
        ( GotProfile (Ok profile), _ ) ->
            ( { model
                | page = Profile { articlesMade = model.articlesMade, favoritedArticles = Nothing, profile = profile, user = model.user, showMA = True }
                , profile = profile
              }
            , Cmd.none
            )

        -- error, just display the same page as before with default profile
        ( GotProfile (Err _), _ ) ->
            ( { model
                | page = Profile { articlesMade = model.articlesMade, favoritedArticles = Nothing, profile = defaultProfile, user = model.user, showMA = True }
                , profile = defaultProfile
              }
            , Cmd.none
            )

        -- done with getting a profile in one message below
        -- ( GotProfileArticles (Ok articlesMade), _ ) ->
        --     ( { model
        --         | page = Profile { profile = model.profile, articlesMade = Just articlesMade, favoritedArticles = Nothing, user = model.user, showMA = True }
        --         , articlesMade = Just articlesMade
        --       }
        --     , Cmd.none
        --     )
        -- ( GotProfileArticles (Err _), _ ) ->
        --     ( { model
        --         | page = Profile { profile = model.profile, articlesMade = Nothing, favoritedArticles = Nothing, user = model.user, showMA = True }
        --         , articlesMade = Nothing
        --       }
        --     , Cmd.none
        --     )
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
        ( GotUser (Err _), _ ) ->
            ( { model | currentPage = "Home" }, Cmd.none )

        -- new messages that involve handling 2 things at once
        ( GotArticleAndComments result, _ ) ->
            case result of
                Ok ( article, comments ) ->
                    -- Update your model with the fetched article and comments
                    -- You can also trigger further actions here if needed
                    ( { model
                        | page = Article { article = article, comments = Just comments, newComment = "", user = model.user }
                        , article = article
                        , comments = Just comments
                      }
                    , Cmd.none
                    )

                Err error ->
                    -- Handle the error if needed
                    ( model, Cmd.none )

        ( GotProfileAndArticles result, _ ) ->
            case result of
                Ok ( profile, articlesMade ) ->
                    ( { model
                        | page = Profile { articlesMade = Just articlesMade, favoritedArticles = Nothing, profile = profile, user = model.user, showMA = True }
                        , profile = profile
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { model
                        | page = Profile { profile = defaultProfile, articlesMade = Nothing, favoritedArticles = Nothing, user = model.user, showMA = True }
                        , articlesMade = Nothing
                        , profile = defaultProfile
                      }
                    , Cmd.none
                    )

        ( GotProfileAndFavArticles result, _ ) ->
            case result of
                Ok ( profile, favoritedArticles ) ->
                    ( { model
                        | page = Profile { articlesMade = Nothing, favoritedArticles = Just favoritedArticles, profile = profile, user = model.user, showMA = False }
                        , profile = profile
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { model
                        | page = Profile { profile = defaultProfile, articlesMade = Nothing, favoritedArticles = Nothing, user = model.user, showMA = False }
                        , articlesMade = Nothing
                        , profile = defaultProfile
                      }
                    , Cmd.none
                    )

        ( GotYFAndTags result, _ ) ->
            case result of
                Ok ( yourfeed, tags ) ->
                    ( { model
                        | page = PublicFeed { globalfeed = Nothing, yourfeed = Just yourfeed, tags = Just tags, user = model.user, showGF = False, showTag = False, tagfeed = Nothing, tag = "" }
                      }
                    , Cmd.none
                    )

                Err error ->
                    ( { model
                        | page = PublicFeed { globalfeed = Nothing, yourfeed = Nothing, tags = Nothing, user = model.user, showGF = False, showTag = False, tagfeed = Nothing, tag = "" }
                      }
                    , Cmd.none
                    )

        ( GotGFAndTags result, _ ) ->
            case result of
                Ok ( globalfeed, tags ) ->
                    ( { model
                        | page = PublicFeed { globalfeed = Just globalfeed, yourfeed = Nothing, tags = Just tags, user = model.user, showGF = True, showTag = False, tagfeed = Nothing, tag = "" }
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model
                        | page = PublicFeed { globalfeed = Nothing, yourfeed = Nothing, tags = Nothing, user = model.user, showGF = True, showTag = False, tagfeed = Nothing, tag = "" }
                      }
                    , Cmd.none
                    )

        ( GotTFAndTags result, _ ) ->
            case result of
                Ok ( tagfeed, tags ) ->
                    ( { model
                        | page = PublicFeed { globalfeed = Nothing, yourfeed = Nothing, tags = Just tags, user = model.user, showGF = False, showTag = True, tagfeed = Just tagfeed, tag = model.tag }
                      }
                    , Cmd.none
                    )

                Err _ ->
                    ( { model
                        | page = PublicFeed { globalfeed = Nothing, yourfeed = Nothing, tags = Nothing, user = model.user, showGF = False, showTag = True, tagfeed = Nothing, tag = "" }
                        , tag = ""
                      }
                    , Cmd.none
                    )

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
                | user = convertUser gotUser -- convert to normal user type
                , isLoggedIn = True
                , page = PublicFeed { publicFeedModel | user = model.user }
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
        -- intercept this message :)
        ( EditorMessage (Editor.GotArticle (Ok gotArticle)), _ ) ->
            let
                ( articleModel, articleCmd ) =
                    Article.init
            in
            -- change the page to Article after creating an article
            ( { model
                | page = Article { article = gotArticle, comments = Nothing, newComment = "", user = model.user }
              }
            , Cmd.map ArticleMessage articleCmd
            )

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
                | user = convertUser gotUser -- convert to normal user type
                , isLoggedIn = True
                , page = PublicFeed { publicFeedModel | user = convertUser gotUser }
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
        -- intercept this message :)
        ( ArticleMessage (Article.DeletedArticle _), _ ) ->
            let
                ( publicFeedModel, publicFeedCmd ) =
                    PublicFeed.init
            in
            -- change the page to the home page after deleting an article
            ( { model
                | page = PublicFeed publicFeedModel
                , currentPage = "Home"
              }
            , Cmd.map PublicFeedMessage publicFeedCmd
            )

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
        -- intercept this message
        ( SettingsMessage Settings.LogOut, _ ) ->
            let
                ( publicFeedModel, publicFeedCmd ) =
                    PublicFeed.init
            in
            -- change the page to the home page and log a user out
            ( { model
                | page = PublicFeed publicFeedModel
                , currentPage = "Home"
                , user = defaultUser -- logged user out :)
                , isLoggedIn = False
              }
            , Cmd.map PublicFeedMessage publicFeedCmd
            )

        -- intercept this message
        ( SettingsMessage (Settings.GotUser (Ok gotUser)), _ ) ->
            let
                -- initialise the profile page and its messages
                ( initProfileModel, profileCmd ) =
                    Profile.init
            in
            -- change the page to their profile page after updating their details (fetch their new profile though)
            ( { model
                | page = Profile initProfileModel
                , user = gotUser -- new user
              }
            , fetchProfile gotUser.username
            )

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
    Sub.none



---- VIEW ----


viewContent : Model -> ( String, Html Msg )
viewContent model =
    case model.page of
        PublicFeed publicFeedModel ->
            ( "Conduit - Conduit"
            , PublicFeed.view publicFeedModel |> Html.map PublicFeedMessage
            )

        Auth authUser ->
            ( "Auth - Conduit"
            , Auth.view authUser |> Html.map AuthMessage
            )

        Editor editorArticle ->
            ( "New Article - Conduit"
            , Editor.view editorArticle |> Html.map EditorMessage
            )

        Login loginUser ->
            ( "Login - Conduit"
            , Login.view loginUser |> Html.map LoginMessage
            )

        Article articleModel ->
            ( articleModel.article.title ++ " - Conduit"
            , Article.view articleModel |> Html.map ArticleMessage
            )

        Profile profileModel ->
            ( profileModel.profile.username ++ " - Conduit" 
            , Profile.view profileModel |> Html.map ProfileMessage
            )

        Settings settingsUserSettings ->
            ( "Settings - Conduit"
            , Settings.view settingsUserSettings |> Html.map SettingsMessage
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
    -- Logged out universal header used on all pages BUT changes the active element depending on the page
    let
        isActivePage pageName =
            if model.currentPage == pageName then
                "nav-item active"

            else
                "nav-item"
    in
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ class "navbar-brand", Routes.href Routes.Home {- (Routes.Index Routes.Global) -} ] [ text "conduit" ]
            , ul [ class "nav navbar-nav pull-xs-right" ]
                [ li [ class (isActivePage "Home") ] [ a [ class "nav-link", Routes.href Routes.Home {- (Routes.Index Routes.Global) -} ] [ text "Home :)" ] ]
                , li [ class (isActivePage "Login") ] [ a [ class "nav-link", Routes.href Routes.Login ] [ text "Log in" ] ]
                , li [ class (isActivePage "Auth") ] [ a [ class "nav-link", Routes.href Routes.Auth ] [ text "Sign up" ] ]
                ]
            ]
        ]


viewHeader : Model -> Html Msg
viewHeader model =
    -- Logged in universal header used on all pages BUT changes the active element depending on the page
    let
        isActivePage pageName =
            if model.currentPage == pageName then
                "nav-item active"

            else
                "nav-item"
    in
    nav [ class "navbar navbar-light" ]
        [ div [ class "container" ]
            [ a [ class "navbar-brand", Routes.href Routes.Home {- (Routes.Index Routes.Global) -} ] [ text "conduit" ]
            , ul [ class "nav navbar-nav pull-xs-right" ]
                [ li [ class (isActivePage "Home") ] [ a [ class "nav-link", Routes.href Routes.Home {- (Routes.Index Routes.Global) -} ] [ text "Home :)" ] ]
                , li [ class (isActivePage "Editor") ] [ a [ class "nav-link", Routes.href (Routes.NewEditor) ] [ i [ class "ion-compose" ] [], text (" " ++ "New Article") ] ]
                , li [ class (isActivePage "Settings") ] [ a [ class "nav-link", Routes.href Routes.Settings ] [ i [ class "ion-gear-a" ] [], text " Settings" ] ]
                , li [ class (isActivePage "Profile") ] [ a [ class "nav-link", Routes.href (Routes.Profile model.user.username Routes.WholeProfile) ] [ img [ style "width" "32px", style "height" "32px", style "border-radius" "30px", src (maybeImageBio model.user.image) ] [], text (" " ++ model.user.username) ] ]
                ]
            ]
        ]


view : Model -> Document Msg
view model =
    let
        ( title, content ) =
            viewContent model
    in
    if model.isLoggedIn then
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
