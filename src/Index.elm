module Index exposing (Article, Feed, Model, Msg(..), Tags, init, tagDecoder, update, view)

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
import Task exposing (Task)



--Model--


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
    , author : Editor.Author
    }


type alias User =
    -- all of these fields are contained in the response from the server
    { email : String
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
    { globalfeed : Maybe Feed -- articlePreview may exist or not lol
    , yourfeed : Maybe Feed
    , tags : Maybe Tags -- tag may exist or not hehe
    , user : User
    , showGF : Bool
    , showTag : Bool
    , tagfeed : Maybe Feed
    , tag : String
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



-- SERVER CALLS --


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


fetchTagArticles : String -> Cmd Msg
fetchTagArticles tag =
    Http.get
        { url = baseUrl ++ "api/articles?tag=" ++ tag
        , expect = Http.expectJson GotTagFeed (field "articles" (list articleDecoder))
        }


fetchTags2 : Cmd Msg
fetchTags2 =
    Http.get
        { url = baseUrl ++ "api/tags"
        , expect = Http.expectJson GotTags tagDecoder
        }


fetchYourFeed : Model -> Task Http.Error Feed
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
        , resolver = Http.stringResolver <| handleJsonResponse <| field "articles" (list articleDecoder)
        , url = baseUrl ++ "api/articles/feed"
        , timeout = Nothing
        }


fetchTags : Task Http.Error Tags
fetchTags =
    -- convert to task
    Http.task
        { url = baseUrl ++ "api/tags"
        , resolver = Http.stringResolver <| handleJsonResponse <| tagDecoder
        , method = "GET"
        , headers = []
        , body = Http.emptyBody
        , timeout = Nothing
        }


fetchGlobalFeed : Task Http.Error Feed
fetchGlobalFeed =
    -- convert to task
    Http.task
        { method = "GET"
        , headers = []
        , body = Http.emptyBody
        , resolver = Http.stringResolver <| handleJsonResponse <| field "articles" (list articleDecoder)
        , url = baseUrl ++ "api/articles"
        , timeout = Nothing
        }


fetchTagFeed : String -> Task Http.Error Feed
fetchTagFeed tag =
    -- convert to task
    Http.task
        { method = "GET"
        , headers = []
        , body = Http.emptyBody
        , resolver = Http.stringResolver <| handleJsonResponse <| field "articles" (list articleDecoder)
        , url = baseUrl ++ "api/articles?tag=" ++ tag
        , timeout = Nothing
        }


fetchYourFeedAndTags : Model -> Task Http.Error ( Feed, Tags )
fetchYourFeedAndTags model =
    -- Function to fetch your feed and tags sequentially
    fetchYourFeed model
        |> Task.andThen
            (\articles ->
                fetchTags
                    |> Task.map (\tags -> ( articles, tags ))
            )


fetchGlobalFeedAndTags : Task Http.Error ( Feed, Tags )
fetchGlobalFeedAndTags =
    -- Function to fetch both global feed and tags sequentially
    fetchGlobalFeed
        |> Task.andThen
            (\articles ->
                fetchTags
                    |> Task.map (\tags -> ( articles, tags ))
            )


fetchTagFeedAndTags : String -> Task Http.Error ( Feed, Tags )
fetchTagFeedAndTags tag =
    -- Function to fetch both tag feed and tags sequentially
    fetchTagFeed tag
        |> Task.andThen
            (\articles ->
                fetchTags
                    |> Task.map (\tags -> ( articles, tags ))
            )


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



-- END OF SERVER CALLS --


author1 : Editor.Author
author1 =
    -- default stuff for testing at first and in case things break
    { username = "Eric Simons"
    , bio = Just ""
    , image = Just "http://i.imgur.com/Qr71crq.jpg"
    , following = False
    }


articlePreview1 : Article
articlePreview1 =
    -- default stuff for testing at first and in case things break
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
    -- default stuff for testing at first and in case things break
    { username = "Albert Pai"
    , bio = Just ""
    , image = Just "http://i.imgur.com/N4VcUeJ.jpg"
    , following = False
    }


articlePreview2 : Article
articlePreview2 =
    -- default stuff for testing at first and in case things break
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
    -- default stuff for testing at first and in case things break
    { email = ""
    , token = ""
    , username = ""
    , bio = Just ""
    , image = Just ""
    }


initialModel : Model
initialModel =
    { globalfeed = Just [ articlePreview1, articlePreview2 ]
    , yourfeed = Just []
    , tags = Just [ " programming", " javascript", " angularjs", " react", " mean", " node", " rails" ]
    , user = defaultUser
    , showGF = True
    , showTag = False
    , tagfeed = Just []
    , tag = ""
    }


init : ( Model, Cmd Msg )
init =
    -- probably only place where these calls are done and needed
    -- Cmd.batch [ fetchGlobalArticles, fetchTags2 ]
    ( initialModel, Cmd.batch [ fetchGlobalArticles, fetchTags2 ] )



--Update--


type Msg
    = ToggleLike Article
    | GotGlobalFeed (Result Http.Error Feed)
    | GotTags (Result Http.Error Tags)
    | GotYourFeed (Result Http.Error Feed)
    | GotTagFeed (Result Http.Error Feed)
    | LoadGF
    | LoadYF
    | LoadTF String
    | FetchArticleIndex String
    | FetchProfileIndex String
    | GotArticleLoadGF (Result Http.Error Article)
    | GotArticleLoadYF (Result Http.Error Article)



-- | GotYFAndTags (Result Http.Error ( Feed, Tags ))
-- | GotGFAndTags (Result Http.Error ( Feed, Tags ))
-- | GotTFAndTags (Result Http.Error ( Feed, Tags ))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleLike article ->
            if article.favorited then
                ( model
                , if model.showGF then
                    unfavoriteArticle model article

                  else
                    unfavoriteArticleYF model article
                )

            else
                ( model
                , if model.showGF then
                    favoriteArticle model article

                  else
                    favoriteArticleYF model article
                )

        GotGlobalFeed (Ok globalfeed) ->
            ( { model | globalfeed = Just globalfeed, showGF = True, showTag = False }, Cmd.none )

        GotGlobalFeed (Err _) ->
            ( model, Cmd.none )

        GotTags (Ok tags) ->
            ( { model | tags = Just tags }, Cmd.none )

        GotTags (Err _) ->
            ( model, Cmd.none )

        GotYourFeed (Ok yourfeed) ->
            ( { model | yourfeed = Just yourfeed, showGF = False, showTag = False }, Cmd.none )

        GotYourFeed (Err _) ->
            ( model, Cmd.none )

        GotTagFeed (Ok tagfeed) ->
            ( { model | tagfeed = Just tagfeed, showGF = False, showTag = True }, Cmd.none )

        GotTagFeed (Err _) ->
            ( model, Cmd.none )

        LoadGF ->
            ( model, fetchGlobalArticles )

        LoadYF ->
            ( model, fetchYourArticles model )

        LoadTF tag ->
            ( { model | tag = tag }, fetchTagArticles tag )

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



-- Not that Index is a component this is not needed
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


viewTag : String -> Html Msg
viewTag tag =
    button
        [ -- href ""
          {- , Routes.href (Routes.Index (Routes.Tag tag)) -}
          onClick (LoadTF tag)
        , class "label label-pill label-default"
        ]
        [ text tag ]


maybeImageBio : Maybe String -> String
maybeImageBio maybeIB =
    case maybeIB of
        Just imagebio ->
            imagebio

        Nothing ->
            ""


viewTagInPreview : String -> Html Msg
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


viewarticlePreview : Article -> Html Msg
viewarticlePreview article =
    div [ class "post-preview" ]
        [ div [ class "post-meta" ]
            [ a
                [ Routes.href (Routes.Profile article.author.username Routes.WholeProfile)

                --   href ""
                --, onClick (FetchProfileIndex article.author.username)
                ]
                [ img [ src (maybeImageBio article.author.image) ] [] ]
            , text " "
            , div [ class "info" ]
                [ a
                    [ Routes.href (Routes.Profile article.author.username Routes.WholeProfile)

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

            --  href ""
            -- , onClick (FetchArticleIndex article.slug)
            , class "preview-link"
            ]
            [ h1 [] [ text article.title ]
            , p [] [ text article.description ]
            , span [] [ text "Read more..." ]
            , viewTagsInPreview article.tagList -- show tags in preview now
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
                    -- ul and li = weird dot :)
                    (List.map viewarticlePreview feed)

        Nothing ->
            div [ class "post-preview" ]
                [ text "Loading feed :)" ]


viewTags : Maybe Tags -> Html Msg
viewTags maybeTags =
    case maybeTags of
        Just tags ->
            if List.isEmpty tags then
                div [ class "loading-tags" ]
                    [ text "There are no tags here... yet :)" ]

            else
                div [ class "tag-list" ]
                    (List.map viewTag tags)

        Nothing ->
            div [ class "loading-tags" ]
                [ text "Loading tags..." ]


viewThreeFeeds : Model -> Html Msg
viewThreeFeeds model =
    if model.user.token /= "" then
        -- if the user's token is not empty then they are logged in and we can show the Your Feed tab
        if model.showTag then
            -- if we have to show the Tag Feed
            ul [ class "nav nav-pills outline-active" ]
                [ li [ class "nav-item" ]
                    [ button
                        [ class "nav-link"

                        -- , Routes.href (Routes.Index Routes.Yours)
                        -- , href ""
                        , style "cursor" "pointer"
                        , onClick LoadYF
                        ]
                        [ text "Your Feed" ]
                    ]
                , li [ class "nav-item" ]
                    [ button
                        [ class "nav-link"

                        -- , Routes.href (Routes.Index Routes.Global)
                        -- , href ""
                        , style "cursor" "pointer"
                        , onClick LoadGF
                        ]
                        [ text "Global Feed" ]
                    ]
                , li [ class "nav-item" ]
                    [ button
                        [ class "nav-link active"

                        -- , Routes.href (Routes.Index (Routes.Tag model.tag))
                        -- , href ""
                        , style "cursor" "pointer"
                        , onClick (LoadTF model.tag)
                        ]
                        [ i [ class "ion-pound" ] []
                        , text (" " ++ model.tag ++ " ")
                        ]
                    ]
                ]

        else if model.showGF then
            ul [ class "nav nav-pills outline-active" ]
                [ li [ class "nav-item" ]
                    [ button
                        [ class "nav-link"

                        -- , Routes.href (Routes.Index Routes.Yours)
                        -- , href ""
                        , style "cursor" "pointer"
                        , onClick LoadYF
                        ]
                        [ text "Your Feed" ]
                    ]
                , li [ class "nav-item" ]
                    [ button
                        [ class "nav-link active"

                        -- , Routes.href (Routes.Index Routes.Global)
                        -- , href ""
                        , style "cursor" "pointer"
                        , onClick LoadGF
                        ]
                        [ text "Global Feed" ]
                    ]
                ]

        else
            ul [ class "nav nav-pills outline-active" ]
                [ li [ class "nav-item" ]
                    [ button
                        [ class "nav-link active"

                        -- , Routes.href (Routes.Index Routes.Yours)
                        -- , href ""
                        , style "cursor" "pointer"
                        , onClick LoadYF
                        ]
                        [ text "Your Feed" ]
                    ]
                , li [ class "nav-item" ]
                    [ button
                        [ class "nav-link"

                        -- , Routes.href (Routes.Index Routes.Global)
                        -- , href ""
                        , style "cursor" "pointer"
                        , onClick LoadGF
                        ]
                        [ text "Global Feed" ]
                    ]
                ]

    else if model.showTag then
        -- if their token is empty then the user is not logged in and we should not display the Your Feed tab
        -- if we are supposed to show the Tag Feed
        ul [ class "nav nav-pills outline-active" ]
            [ li [ class "nav-item" ]
                [ button
                    [ class "nav-link"

                    -- , Routes.href (Routes.Index Routes.Global)
                    -- , href ""
                    , style "cursor" "pointer"
                    , onClick LoadGF
                    ]
                    [ text "Global Feed" ]
                ]
            , li [ class "nav-item" ]
                [ button
                    [ class "nav-link active"

                    -- , Routes.href (Routes.Index (Routes.Tag model.tag))
                    -- , href ""
                    , style "cursor" "pointer"
                    , onClick (LoadTF model.tag)
                    ]
                    [ i [ class "ion-pound" ] []
                    , text (" " ++ model.tag ++ " ")
                    ]
                ]
            ]

    else
        -- if we are not supposed to show the Tag Feed
        ul [ class "nav nav-pills outline-active" ]
            [ li [ class "nav-item" ]
                [ button
                    [ class "nav-link active"

                    -- , Routes.href (Routes.Index Routes.Global)
                    -- , href ""
                    , style "cursor" "pointer"
                    , onClick LoadGF
                    ]
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
                            [ viewThreeFeeds model ]
                        , if model.showTag then
                            viewArticles model.tagfeed

                          else if model.showGF then
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
                [ a
                    [ Routes.href Routes.Home

                    {- (Routes.Index Routes.Global) -}
                    , class "logo-font"
                    ]
                    [ text "conduit" ]
                , text " " -- helps make spacing perfect even though it's not exactly included in the og html version
                , span [ class "attribution" ]
                    [ text "An interactive learning project from "
                    , a [ href "https://thinkster.io/" ] [ text "Thinkster" ] -- external link
                    , text ". Code & design licensed under MIT."
                    ]
                ]
            ]
        ]



-- Now that Index is a component this is not needed
-- main : Program () Model Msg
-- main =
--     Browser.element
--         { init = init
--         , view = view
--         , update = update
--         , subscriptions = subscriptions
--         }
