module Index exposing (Article, Model, Msg(..), init, update, view)

-- import Exts.Html exposing (nbsp)
-- import Browser

import Article exposing (Msg(..))
import Auth exposing (baseUrl)
import Editor exposing (authorDecoder)
import Html exposing (..)
import Html.Attributes exposing (class, href, src, style, type_)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, bool, field, int, list, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Routes



--Model--


type alias Article =
    --whole article
    { slug : String
    , title : String
    , description : String
    , body : String
    , tagList : List String
    , createdAt : String
    , updatedAt : String
    , favorited : Bool
    , favoritesCount : Int
    , author : Editor.Author
    }


type alias User =
    { email : String --all of these fields are contained in the response from the server (besides last 3)
    , token : String
    , username : String
    , bio : Maybe String
    , image : Maybe String
    }


type alias Feed =
    List Article


type alias Tags =
    List String


type alias Model =
    { globalfeed : Maybe Feed --articlePreview may exist or not lol
    , yourfeed : Maybe Feed
    , tags : Maybe Tags --tag may exist or not hehe
    , user : User
    , showGF : Bool
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
        |> required "author" authorDecoder


tagDecoder : Decoder Tags
tagDecoder =
    field "tags" (list string)


encodeArticle : Article -> Encode.Value
encodeArticle article =
    --used to encode Article slug sent to the server via Article request body
    Encode.object
        [ ( "slug", Encode.string article.slug ) ]


initialModel : Model
initialModel =
    { globalfeed = Just [ articlePreview1, articlePreview2 ]
    , yourfeed = Just []
    , tags = Just [ " programming", " javascript", " angularjs", " react", " mean", " node", " rails" ]
    , user = defaultUser
    , showGF = True
    }


fetchGlobalArticles : Cmd Msg
fetchGlobalArticles =
    Http.get
        { url = baseUrl ++ "api/articles"
        , expect = Http.expectJson GotGlobalFeed (field "articles" (list articleDecoder))
        }


fetchYourArticles : Model -> Cmd Msg
fetchYourArticles model =
    -- need some kind of authentication to know which articles to fetch depended on the user
    let
        body =
            Http.emptyBody

        headers =
            [ Http.header "Authorization" ("Token " ++ model.user.token) ]
    in
    Http.request
        { method = "GET"
        , headers = headers
        , body = body
        , expect = Http.expectJson GotYourFeed (field "articles" (list articleDecoder))
        , url = baseUrl ++ "api/articles/feed"
        , timeout = Nothing
        , tracker = Nothing
        }


fetchTags : Cmd Msg
fetchTags =
    Http.get
        { url = baseUrl ++ "api/tags"
        , expect = Http.expectJson GotTags tagDecoder
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
        , expect = Http.expectJson GotArticleLoadGF (field "article" articleDecoder)
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
        , expect = Http.expectJson GotArticleLoadGF (field "article" articleDecoder)
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
        , expect = Http.expectJson GotArticleLoadYF (field "article" articleDecoder)
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
        , expect = Http.expectJson GotArticleLoadYF (field "article" articleDecoder)
        , url = baseUrl ++ "api/articles/" ++ article.slug ++ "/favorite"
        , timeout = Nothing
        , tracker = Nothing
        }


init : ( Model, Cmd Msg )
init =
    ( initialModel, Cmd.batch [ fetchGlobalArticles, fetchTags ] )


author1 : Editor.Author
author1 =
    { username = "Eric Simons"
    , bio = Just ""
    , image = Just "http://i.imgur.com/Qr71crq.jpg"
    , following = False

    -- , authorpage = "profileelm.html"
    }


articlePreview1 : Article
articlePreview1 =
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
    , author = author1
    }


author2 : Editor.Author
author2 =
    { username = "Albert Pai"
    , bio = Just ""
    , image = Just "http://i.imgur.com/N4VcUeJ.jpg"
    , following = False

    -- , authorpage = "profileelm.html"
    }


articlePreview2 : Article
articlePreview2 =
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
    , author = author2
    }


defaultUser : User
defaultUser =
    { email = ""
    , token = ""
    , username = ""
    , bio = Just ""
    , image = Just ""
    }



--Update--


type Msg
    = ToggleLike Article
    | GotGlobalFeed (Result Http.Error Feed)
    | GotTags (Result Http.Error Tags)
    | GotYourFeed (Result Http.Error Feed)
    | LoadGF
    | LoadYF
    | FetchArticleIndex String
    | FetchProfileIndex String
    | GotArticleLoadGF (Result Http.Error Article)
    | GotArticleLoadYF (Result Http.Error Article)



-- toggleLike : Article -> Article
-- toggleLike article =
--     -- favoritesCount should update automatically when the server returns the new Article!!!!
--     if article.favorited then
--         -- favoritesCount = article.favoritesCount - 1
--         { article | favorited = not article.favorited }
--     else
--         -- , favoritesCount = article.favoritesCount + 1
--         { article | favorited = not article.favorited }
-- updateArticleBySlug : (Article -> Article) -> Article -> Feed -> Feed
-- updateArticleBySlug updateArticle article feed =
--     List.map
--         (\currArticle ->
--             if currArticle.slug == article.slug then
--                 updateArticle currArticle
--             else
--                 currArticle
--         )
--         feed
-- updatearticlePreviewLikes : (Article -> Article) -> Article -> Maybe Feed -> Maybe Feed
-- updatearticlePreviewLikes updateArticle article maybeFeed =
--     Maybe.map (updateArticleBySlug updateArticle article) maybeFeed


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleLike article ->
            -- how to distinguish between yourfeed and globalfeed articles? (Don't, do both (FOR NOW...))
            if article.favorited then
                --  ( { model | globalfeed = updatearticlePreviewLikes toggleLike article model.globalfeed, yourfeed = updatearticlePreviewLikes toggleLike article model.yourfeed }, unfavoriteArticle model article )
                ( model, if model.showGF then unfavoriteArticle model article else unfavoriteArticleYF model article )

            else
                -- ( { model | globalfeed = updatearticlePreviewLikes toggleLike article model.globalfeed, yourfeed = updatearticlePreviewLikes toggleLike article model.yourfeed }, favoriteArticle model article )
                ( model, if model.showGF then favoriteArticle model article else favoriteArticleYF model article )

        -- need lazy execution?
        GotGlobalFeed (Ok globalfeed) ->
            ( { model | globalfeed = Just globalfeed, showGF = True }, Cmd.none )

        GotGlobalFeed (Err _) ->
            ( model, Cmd.none )

        GotTags (Ok tags) ->
            ( { model | tags = Just tags }, Cmd.none )

        GotTags (Err _) ->
            ( model, Cmd.none )

        GotYourFeed (Ok yourfeed) ->
            ( { model | yourfeed = Just yourfeed, showGF = False }, Cmd.none )

        GotYourFeed (Err _) ->
            ( model, Cmd.none )

        LoadGF ->
            ( model, fetchGlobalArticles )

        LoadYF ->
            ( model, fetchYourArticles model )

        FetchArticleIndex slug ->
            -- intercepted in Main.elm now
            ( model, Cmd.none )

        FetchProfileIndex username ->
            ( model, Cmd.none )

        GotArticleLoadGF (Ok article) ->
            ( model, fetchGlobalArticles )

        GotArticleLoadGF (Err _) ->
            ( model, Cmd.none )

        GotArticleLoadYF (Ok article) ->
            ( model, fetchYourArticles model )

        GotArticleLoadYF (Err _) ->
            ( model, Cmd.none )



-- subscriptions : Model -> Sub Msg
-- subscriptions articles =
--     Sub.none
--View--


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


viewTag : String -> Html msg
viewTag tag =
    a [ href "#", class "label label-pill label-default" ] [ text tag ]


maybeImageBio : Maybe String -> String
maybeImageBio maybeIB =
    case maybeIB of
        Just imagebio ->
            imagebio

        Nothing ->
            ""


viewarticlePreview : Article -> Html Msg
viewarticlePreview article =
    div [ class "post-preview" ]
        [ div [ class "post-meta" ]
            [ a
                [ Routes.href (Routes.Profile article.author.username)

                --   href ""
                -- , onClick (FetchProfileIndex article.author.username)
                ]
                [ img [ src (maybeImageBio article.author.image) ] [] ]
            , text " "
            , div [ class "info" ]
                [ a
                    [ Routes.href (Routes.Profile article.author.username)

                    --   href ""
                    -- , onClick (FetchProfileIndex article.author.username)
                    , class "author"
                    ]
                    [ text article.author.username ]
                , span [ class "date" ] [ text (formatDate article.createdAt) ]
                ]
            , viewLoveButton article
            ]
        , a
            [ Routes.href (Routes.Article article.slug)

            --   href ""
            -- , onClick (FetchArticleIndex article.slug)
            , class "preview-link"
            ]
            [ h1 [] [ text article.title ]
            , p [] [ text article.description ]
            , span [] [ text "Read more..." ]
            ]
        ]


viewArticles : Maybe Feed -> Html Msg
viewArticles maybeFeed =
    case maybeFeed of
        Just feed ->
            if List.isEmpty feed then
                div [ class "post-preview" ]
                    [ text "No articles are here... yet :)" ]

            else
                div []
                    (List.map viewarticlePreview feed)

        Nothing ->
            --put something nice here :)
            div [ class "loading-feed" ]
                [ text "Loading feed :)" ]


viewTags : Maybe Tags -> Html Msg
viewTags maybeTags =
    case maybeTags of
        Just tags ->
            if List.isEmpty tags then
                div [ class "loading-tags" ]
                    [ text "There are no tags... yet :)" ]

            else
                div [ class "tag-list" ]
                    (List.map viewTag tags)

        Nothing ->
            div [ class "loading-tags" ]
                [ text "Loading tags..." ]



-- Only show the Global Feed if the user is not logged in (Maybe this will go into the )


viewTwoFeeds : Model -> Html Msg
viewTwoFeeds model =
    if model.user.token /= "" then
        -- if the user's token is not empty then they are logged in and we can show the Your Feed tab
        if model.showGF then
            ul [ class "nav nav-pills outline-active" ]
                [ li [ class "nav-item" ]
                    [ a [ class "nav-link", href "", onClick LoadYF ]
                        -- nav-link active
                        [ text "Your Feed" ]
                    ]
                , li [ class "nav-item" ]
                    [ a [ class "nav-link active", href "", onClick LoadGF ]
                        [ text "Global Feed" ]
                    ]
                ]

        else
            ul [ class "nav nav-pills outline-active" ]
                [ li [ class "nav-item" ]
                    [ a [ class "nav-link active", href "", onClick LoadYF ]
                        -- nav-link active
                        [ text "Your Feed" ]
                    ]
                , li [ class "nav-item" ]
                    [ a [ class "nav-link", href "", onClick LoadGF ]
                        [ text "Global Feed" ]
                    ]
                ]

    else
        -- if their token is empty then the user is not logged in and we should only display the Global Feed tab
        ul [ class "nav nav-pills outline-active" ]
            [ li [ class "nav-item" ]
                [ a [ class "nav-link active", href "", onClick LoadGF ]
                    [ text "Global Feed" ]
                ]
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


view : Model -> Html Msg
view model =
    div []
        [ div [ class "home-page" ]
            [ div [ class "banner" ]
                [ div [ class "container" ]
                    [ h1 [ class "logo-font" ]
                        [ text "conduit" ]
                    , p [] [ text "A place to share your knowledge." ]
                    ]
                ]
            , div [ class "container page" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-9" ]
                        [ div [ class "feed-toggle" ]
                            [ viewTwoFeeds model ]
                        , if model.showGF then
                            viewArticles model.globalfeed

                          else
                            viewArticles model.yourfeed
                        ]
                    , div [ class "col-md-3" ]
                        [ div [ class "sidebar" ]
                            [ p [] [ text "Popular Tags" ]
                            , viewTags model.tags
                            ]
                        ]
                    ]
                ]
            ]
        , footer []
            [ div [ class "container" ]
                [ a [ Routes.href Routes.Index, class "logo-font" ] [ text "conduit" ]
                , text " " --helps make spacing perfect even though it's not exactly included in the og html version
                , span [ class "attribution" ]
                    [ text "An interactive learning project from "
                    , a [ href "https://thinkster.io/" ] [ text "Thinkster" ] --external link
                    , text ". Code & design licensed under MIT."
                    ]
                ]
            ]
        ]



-- main : Program () Model Msg
-- main =
--     Browser.element
--         { init = init
--         , view = view
--         , update = update
--         , subscriptions = subscriptions
--         }
