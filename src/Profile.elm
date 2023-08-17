module Profile exposing (Feed, Model, Msg(..), ProfileType, articleDecoder, fetchFavoritedArticles, fetchProfileArticles, init, profileDecoder, update, view)

import Html exposing (..)
import Html.Attributes exposing (class, href, src, style, type_)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, bool, field, int, list, nullable, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Routes



-- Model --


type alias ProfileType =
    { username : String
    , bio : Maybe String
    , image : Maybe String
    , following : Bool
    }


type alias User =
    -- all of these fields are contained in the response from the server
    { email : String
    , token : String
    , username : String
    , bio : Maybe String
    , image : Maybe String
    }


type alias Article =
    -- whole article
    { slug : String
    , title : String
    , description : String
    , body : String
    , tagList : List String
    , createdAt : String
    , updatedAt : String
    , favorited : Bool
    , favoritesCount : Int
    , author : ProfileType
    }


type alias Feed =
    List Article


type alias Model =
    { profile : ProfileType
    , articlesMade : Maybe Feed
    , favoritedArticles : Maybe Feed
    , user : User
    , showMA : Bool
    }


defaultProfile : ProfileType
defaultProfile =
    -- default stuff for testing at first and if something breaks
    { username = ""
    , bio = Just ""
    , image = Just ""
    , following = False
    }


defaultUser : User
defaultUser =
    -- default stuff for testing at first and if something breaks
    { email = ""
    , token = ""
    , username = ""
    , bio = Just ""
    , image = Just ""
    }


articlePreview1 : Article
articlePreview1 =
    -- default stuff for testing at first and if something breaks
    { slug = "slug1"
    , title = "How to build webapps that scale"
    , description = """In my demo, the holy grail layout is nested inside a document, so there's no body or main tags like shown above. Regardless, we're interested in the class names 
                        and the appearance of sections in the markup as opposed to the actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and 
                        the trivial order in which they appear in the markup. Let's break this down to paint a clear picture of what's happening..."""
    , body = ""
    , tagList = [ "" ]
    , createdAt = "January 20th"
    , updatedAt = ""
    , favorited = False
    , favoritesCount = 29
    , author = defaultProfile
    }


articlePreview2 : Article
articlePreview2 =
    -- default stuff for testing at first and if something breaks
    { slug = "slug2"
    , title = "The song you won't ever stop singing. No matter how hard you try."
    , description = """In my demo, the holy grail layout is nested inside a document, so there's no body or main tags like shown above. Regardless, we're interested in the class names 
                        and the appearance of sections in the markup as opposed to the actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and 
                        the trivial order in which they appear in the markup. Let's break this down to paint a clear picture of what's happening..."""
    , body = ""
    , tagList = [ "" ]
    , createdAt = "January 20th"
    , updatedAt = ""
    , favorited = False
    , favoritesCount = 32
    , author = defaultProfile
    }


initialModel : Model
initialModel =
    { profile = defaultProfile
    , articlesMade = Just [ articlePreview1, articlePreview2 ]
    , favoritedArticles = Just []
    , user = defaultUser
    , showMA = True
    }


articleDecoder : Decoder Article
articleDecoder =
    succeed Article
        |> required "slug" string
        |> required "title" string
        |> required "description" string
        |> required "body" string
        |> required "tagList" (list string)
        |> required "createdAt" string
        |> required "updatedAt" string
        |> required "favorited" bool
        |> required "favoritesCount" int
        -- "author": {
        |> required "author" profileDecoder


profileDecoder : Decoder ProfileType
profileDecoder =
    succeed ProfileType
        |> required "username" string
        |> required "bio" (nullable string)
        |> required "image" (nullable string)
        |> required "following" bool


encodeMaybeString : Maybe String -> Encode.Value
encodeMaybeString maybeString =
    case maybeString of
        Just string ->
            Encode.string string

        Nothing ->
            Encode.null


encodeProfile : ProfileType -> Encode.Value
encodeProfile profile =
    -- used to encode profile sent to the server
    Encode.object
        [ ( "username", Encode.string profile.username )
        , ( "bio", encodeMaybeString profile.bio )
        , ( "image", encodeMaybeString profile.image )
        ]


encodeArticle : Article -> Encode.Value
encodeArticle article =
    --used to encode Article slug sent to the server via Article request body
    Encode.object
        [ ( "slug", Encode.string article.slug ) ]



-- done in main now
-- fetchProfile : String -> Cmd Msg
-- fetchProfile username =
--     -- need to fetch the profile
--     Http.get
--         { url = baseUrl ++ "api/profiles/" ++ username
--         , expect = Http.expectJson GotProfile profileDecoder
--         }


fetchProfileArticles : String -> Cmd Msg
fetchProfileArticles username =
    -- get the articles the author of the profile has created
    Http.get
        { url = baseUrl ++ "api/articles?author=" ++ username
        , expect = Http.expectJson GotProfileArticles (field "articles" (list articleDecoder))
        }


fetchFavoritedArticles : String -> Cmd Msg
fetchFavoritedArticles username =
    -- get the articles the author has favorited
    Http.get
        { url = baseUrl ++ "api/articles?favorited=" ++ username
        , expect = Http.expectJson GotFavoritedArticles (field "articles" (list articleDecoder))
        }


favoriteArticle : Model -> Article -> Cmd Msg
favoriteArticle model article =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "article", encodeArticle <| article ) ]

        headers =
            [ Http.header "Authorization" ("Token " ++ model.user.token) ]
    in
    Http.request
        { method = "POST"
        , headers = headers
        , body = body
        , expect = Http.expectJson GotArticleLoadArticles (field "article" articleDecoder)
        , url = baseUrl ++ "api/articles/" ++ article.slug ++ "/favorite"
        , timeout = Nothing
        , tracker = Nothing
        }


unfavoriteArticle : Model -> Article -> Cmd Msg
unfavoriteArticle model article =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "article", encodeArticle <| article ) ]

        headers =
            [ Http.header "Authorization" ("Token " ++ model.user.token) ]
    in
    Http.request
        { method = "DELETE"
        , headers = headers
        , body = body
        , expect = Http.expectJson GotArticleLoadArticles (field "article" articleDecoder)
        , url = baseUrl ++ "api/articles/" ++ article.slug ++ "/favorite"
        , timeout = Nothing
        , tracker = Nothing
        }


favoriteArticleYF : Model -> Article -> Cmd Msg
favoriteArticleYF model article =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "article", encodeArticle <| article ) ]

        headers =
            [ Http.header "Authorization" ("Token " ++ model.user.token) ]
    in
    Http.request
        { method = "POST"
        , headers = headers
        , body = body
        , expect = Http.expectJson GotArticleLoadFavArticles (field "article" articleDecoder)
        , url = baseUrl ++ "api/articles/" ++ article.slug ++ "/favorite"
        , timeout = Nothing
        , tracker = Nothing
        }


unfavoriteArticleYF : Model -> Article -> Cmd Msg
unfavoriteArticleYF model article =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "article", encodeArticle <| article ) ]

        headers =
            [ Http.header "Authorization" ("Token " ++ model.user.token) ]
    in
    Http.request
        { method = "DELETE"
        , headers = headers
        , body = body
        , expect = Http.expectJson GotArticleLoadFavArticles (field "article" articleDecoder)
        , url = baseUrl ++ "api/articles/" ++ article.slug ++ "/favorite"
        , timeout = Nothing
        , tracker = Nothing
        }


followUser : Model -> ProfileType -> Cmd Msg
followUser model profile =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "profile", encodeProfile <| profile ) ]

        headers =
            [ Http.header "Authorization" ("Token " ++ model.user.token) ]
    in
    Http.request
        { method = "POST"
        , headers = headers
        , body = body
        , expect = Http.expectJson GotProfile (field "profile" profileDecoder)
        , url = baseUrl ++ "api/profiles/" ++ profile.username ++ "/follow"
        , timeout = Nothing
        , tracker = Nothing
        }


unfollowUser : Model -> ProfileType -> Cmd Msg
unfollowUser model profile =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "profile", encodeProfile <| profile ) ]

        headers =
            [ Http.header "Authorization" ("Token " ++ model.user.token) ]
    in
    Http.request
        { method = "DELETE"
        , headers = headers
        , body = body
        , expect = Http.expectJson GotProfile (field "profile" profileDecoder)
        , url = baseUrl ++ "api/profiles/" ++ profile.username ++ "/follow"
        , timeout = Nothing
        , tracker = Nothing
        }


init : ( Model, Cmd Msg )
init =
    -- () -> (No longer need unit flag as it's no longer an application but a component)
    -- get a specific profile ( fetchProfile username ) and the articles they have made in Main
    ( initialModel, Cmd.none )


baseUrl : String
baseUrl =
    "http://localhost:8000/"



-- Update --


type Msg
    = ToggleLike Article
    | ToggleFollow
    | GotProfile (Result Http.Error ProfileType)
    | GotProfileArticles (Result Http.Error Feed)
    | GotFavoritedArticles (Result Http.Error Feed)
    | LoadArticlesMade String
    | LoadFavoritedArticles String
    | GotArticleLoadArticles (Result Http.Error Article)
    | GotArticleLoadFavArticles (Result Http.Error Article)


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        ToggleLike article ->
            if article.favorited then
                ( model
                , if model.showMA then
                    unfavoriteArticle model article

                  else
                    unfavoriteArticleYF model article
                )

            else
                ( model
                , if model.showMA then
                    favoriteArticle model article

                  else
                    favoriteArticleYF model article
                )

        ToggleFollow ->
            if model.profile.following then
                ( model, unfollowUser model model.profile )

            else
                ( model, followUser model model.profile )

        GotProfile (Ok userProfile) ->
            ( { model | profile = userProfile }, Cmd.none )

        GotProfile (Err _) ->
            ( model, Cmd.none )

        GotProfileArticles (Ok articlesMade) ->
            ( { model | articlesMade = Just articlesMade, showMA = True }, Cmd.none )

        GotProfileArticles (Err _) ->
            ( model, Cmd.none )

        GotFavoritedArticles (Ok favoritedArticles) ->
            ( { model | favoritedArticles = Just favoritedArticles, showMA = False }, Cmd.none )

        GotFavoritedArticles (Err _) ->
            ( model, Cmd.none )

        LoadArticlesMade profile ->
            ( model, fetchProfileArticles profile )

        LoadFavoritedArticles profile ->
            ( model, fetchFavoritedArticles profile )

        GotArticleLoadArticles (Ok article) ->
            ( model, fetchProfileArticles model.profile.username )

        GotArticleLoadArticles (Err _) ->
            ( model, Cmd.none )

        GotArticleLoadFavArticles (Ok article) ->
            ( model, fetchFavoritedArticles model.profile.username )

        GotArticleLoadFavArticles (Err _) ->
            ( model, Cmd.none )



-- Now that Profile.elm is a component this is not neeeded
-- subscriptions : Model -> Sub Msg
-- subscriptions model =
--     Sub.none
-- View --


maybeImageBio : Maybe String -> String
maybeImageBio maybeIB =
    case maybeIB of
        Just imagebio ->
            imagebio

        Nothing ->
            ""


viewSettingsButton : Html Msg
viewSettingsButton =
    a [ class "btn btn-sm btn-outline-secondary action-btn", Routes.href Routes.Settings ]
        [ i [ class "ion-gear-a" ] []
        , text " Edit Profile Settings "
        ]


viewFollowButton : Model -> Html Msg
viewFollowButton model =
    let
        buttonClass =
            if model.profile.following then
                [ class "btn btn-sm btn-outline-secondary action-btn", style "background-color" "skyblue", style "color" "#fff", style "border-color" "black", type_ "button", onClick ToggleFollow ]

            else
                [ class "btn btn-sm btn-outline-secondary action-btn", type_ "button", onClick ToggleFollow ]
    in
    button buttonClass
        [ i [ class "ion-plus-round" ] []
        , text
            (" \u{00A0} "
                ++ (if model.profile.following then
                        "Unfollow"

                    else
                        "Follow"
                   )
                ++ " "
                ++ model.profile.username
                ++ " "
            )
        ]


viewLoveButton : Article -> Html Msg
viewLoveButton articlePreview =
    let
        buttonClass =
            if articlePreview.favorited then
                [ class "btn btn-outline-primary btn-sm pull-xs-right", style "background-color" "#d00", style "color" "#fff", style "border-color" "black", type_ "button", onClick (ToggleLike articlePreview) ]

            else
                [ class "btn btn-outline-primary btn-sm pull-xs-right", type_ "button", onClick (ToggleLike articlePreview) ]
    in
    button buttonClass
        [ i [ class "ion-heart" ] []
        , text (" " ++ String.fromInt articlePreview.favoritesCount)
        ]


formatDate : String -> String
formatDate dateStr =
    case splitDate dateStr of
        Just ( year, month, day ) ->
            monthName month ++ " " ++ day ++ ", " ++ year

        Nothing ->
            "Invalid date"


splitDate : String -> Maybe ( String, String, String )
splitDate dateStr =
    let
        parts =
            String.split "-" dateStr
    in
    case parts of
        [ year, month, dayWithTime ] ->
            let
                day =
                    String.left 2 dayWithTime
            in
            Just ( year, month, day )

        _ ->
            Nothing


monthName : String -> String
monthName month =
    case month of
        "01" ->
            "January"

        "02" ->
            "February"

        "03" ->
            "March"

        "04" ->
            "April"

        "05" ->
            "May"

        "06" ->
            "June"

        "07" ->
            "July"

        "08" ->
            "August"

        "09" ->
            "September"

        "10" ->
            "October"

        "11" ->
            "November"

        "12" ->
            "December"

        _ ->
            "Invalid month"


viewTagInPreview : String -> Html msg
viewTagInPreview tag =
    -- css skill issue :( (fixed?)
    li [ class "tag-default tag-pill tag-outline" ]
        [ text tag ]


viewTagsInPreview : List String -> Html Msg
viewTagsInPreview maybeTags =
    -- display tags on far right in line with "Read more..."
    if List.isEmpty maybeTags then
        span [] []

    else
        ul [ class "tag-list", style "float" "right" ]
            (List.map viewTagInPreview maybeTags)


viewArticlePreview : Article -> Html Msg
viewArticlePreview article =
    div [ class "post-preview" ]
        [ div [ class "post-meta" ]
            [ a
                [ Routes.href (Routes.Profile article.author.username Routes.WholeProfile) ]
                [ img [ src (maybeImageBio article.author.image) ] [] ]
            , text " "
            , div [ class "info" ]
                [ a
                    [ Routes.href (Routes.Profile article.author.username Routes.WholeProfile), class "author" ]
                    [ text article.author.username ]
                , span [ class "date" ] [ text (formatDate article.createdAt) ]
                ]
            , viewLoveButton article
            ]
        , a [ Routes.href (Routes.Article article.slug), class "preview-link" ]
            [ h1 [] [ text article.title ]
            , p [] [ text article.description ]
            , span [] [ text "Read more..." ]
            , viewTagsInPreview article.tagList -- show tags in preview now
            ]
        ]


viewArticles : Maybe Feed -> Html Msg
viewArticles maybeArticlesMade =
    case maybeArticlesMade of
        Just articles ->
            if List.isEmpty articles then
                div [ class "post-preview" ]
                    [ text "No articles are here... yet :)" ]

            else
                div []
                    -- ul and li = weird dot :)
                    (List.map viewArticlePreview articles)

        Nothing ->
            div [ class "loading-feed" ]
                [ text "Loading Feed..." ]


viewTwoFeeds : Model -> Html Msg
viewTwoFeeds model =
    -- function to display the 2 different feeds depending on if they are viewing articles the profile has made or favorited
    if model.showMA then
        ul [ class "nav nav-pills outline-active" ]
            [ li [ class "nav-item" ]
                [ a
                    [ class "nav-link active"
                    , Routes.href (Routes.Profile model.profile.username Routes.WholeProfile)

                    --, onClick (LoadArticlesMade model.profile.username)
                    ]
                    [ text "My Articles" ]
                ]
            , li [ class "nav-item" ]
                [ a
                    [ class "nav-link"
                    , Routes.href (Routes.Profile model.profile.username Routes.Favorited)

                    --, onClick (LoadFavoritedArticles model.profile.username)
                    ]
                    [ text "Favorited Articles" ]
                ]
            ]

    else
        ul [ class "nav nav-pills outline-active" ]
            [ li [ class "nav-item" ]
                [ a
                    [ class "nav-link"
                    , Routes.href (Routes.Profile model.profile.username Routes.WholeProfile)

                    --, onClick (LoadArticlesMade model.profile.username)
                    ]
                    [ text "My Articles" ]
                ]
            , li [ class "nav-item" ]
                [ a
                    [ class "nav-link active"
                    , Routes.href (Routes.Profile model.profile.username Routes.Favorited)

                    --, onClick (LoadFavoritedArticles model.profile.username)
                    ]
                    [ text "Favorited Articles" ]
                ]
            ]


view : Model -> Html Msg
view model =
    div []
        [ div [ class "profile-page" ]
            [ div [ class "user-info" ]
                [ div [ class "container" ]
                    [ div [ class "row" ]
                        [ div [ class "col-md-10 col-md-offset-1" ]
                            [ img [ src (maybeImageBio model.profile.image), class "user-img" ] []
                            , h4 [] [ text model.profile.username ]
                            , p [] [ text (maybeImageBio model.profile.bio) ]
                            , text " "
                            , if (model.user.username == model.profile.username) && (model.user.username /= "") then
                                viewSettingsButton

                              else
                                viewFollowButton model
                            ]
                        ]
                    ]
                ]
            , div [ class "container" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-10 col-md-offset-1" ]
                        [ div [ class "articles-toggle" ]
                            [ viewTwoFeeds model ]
                        , if model.showMA then
                            viewArticles model.articlesMade

                          else
                            viewArticles model.favoritedArticles
                        ]
                    ]
                ]
            ]
        , footer []
            [ div [ class "container" ]
                [ a [ Routes.href (Routes.Index Routes.Global), class "logo-font" ] [ text "conduit" ]
                , text " " -- helps make spacing perfect even though it's not exactly included in the og html version
                , span [ class "attribution" ]
                    [ text "An interactive learning project from "
                    , a [ href "https://thinkster.io/" ] [ text "Thinkster" ] -- external link
                    , text ". Code & design licensed under MIT."
                    ]
                ]
            ]
        ]



-- Now profile is a component and no longer an application
-- main : Program () Model Msg
-- main =
--     -- view initialModel
--     Browser.element
--         { init = initialModel
--         , view = view
--         , update = update
--         , subscriptions = subscriptions
--         }
