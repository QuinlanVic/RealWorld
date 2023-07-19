module Index exposing (Article, Model, Msg, init, main, update, view)

-- import Exts.Html exposing (nbsp)

import Auth exposing (baseUrl)
import Browser
import Editor exposing (Author, articleDecoder, authorDecoder)
import Html exposing (..)
import Html.Attributes exposing (class, href, id, src, style, type_)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, bool, field, int, list, null, nullable, string, succeed)
import Json.Decode.Pipeline exposing (custom, hardcoded, required)
import Json.Encode as Encode
import Response exposing (mapModel)
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


type alias Feed =
    List Article


type alias Tags =
    List String


type alias Model =
    { feed : Maybe Feed --postpreview may exist or not lol
    , tags : Maybe Tags --tag may exist or not hehe
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
    { feed = Just [ postPreview1, postPreview2 ]
    , tags = Just [ " programming", " javascript", " angularjs", " react", " mean", " node", " rails" ]
    }


fetchArticles : Cmd Msg
fetchArticles =
    Http.get
        { url = baseUrl ++ "api/articles"
        , expect = Http.expectJson LoadArticles (list (field "article" articleDecoder))
        }


fetchTags : Cmd Msg
fetchTags =
    Http.get
        { url = baseUrl ++ "api/tags"
        , expect = Http.expectJson LoadTags tagDecoder
        }


favouriteArticle : Article -> Cmd Msg
favouriteArticle article =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "article", encodeArticle <| article ) ]
    in
    Http.post
        { body = body
        , expect = Http.expectJson LoadArticles (list (field "article" articleDecoder))
        , url = baseUrl ++ "api/" ++ article.slug ++ "/favorite"
        }


init : () -> ( Model, Cmd Msg )
init () =
    ( initialModel, Cmd.batch [ fetchArticles, fetchTags ] )


author1 : Editor.Author
author1 =
    { username = "Eric Simons"
    , bio = ""
    , image = "http://i.imgur.com/Qr71crq.jpg"
    , following = False

    -- , authorpage = "profileelm.html"
    }


postPreview1 : Article
postPreview1 =
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
    , bio = ""
    , image = "http://i.imgur.com/N4VcUeJ.jpg"
    , following = False

    -- , authorpage = "profileelm.html"
    }


postPreview2 : Article
postPreview2 =
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



--Update--


saveArticle : Article -> Cmd Msg
saveArticle article =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "slug", Encode.string article.slug ) ]
    in
    Http.post
        { body = body
        , expect = Http.expectJson LoadArticles (list (field "article" articleDecoder))
        , url = baseUrl ++ "api/articles/{" ++ article.slug ++ "}/favorite"
        }


toggleLike : Article -> Article
toggleLike post =
    if post.favorited then
        { post | favorited = not post.favorited, favoritesCount = post.favoritesCount - 1 }

    else
        { post | favorited = not post.favorited, favoritesCount = post.favoritesCount + 1 }


updateArticleBySlug : (Article -> Article) -> Article -> Feed -> Feed
updateArticleBySlug updateArticle article feed =
    List.map
        (\currArticle ->
            if currArticle.slug == article.slug then
                updateArticle currArticle

            else
                currArticle
        )
        feed


updatePostPreviewLikes : (Article -> Article) -> Article -> Maybe Feed -> Maybe Feed
updatePostPreviewLikes updateArticle article maybeFeed =
    Maybe.map (updateArticleBySlug updateArticle article) maybeFeed


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleLike article ->
            ( { model | feed = updatePostPreviewLikes toggleLike article model.feed }, favouriteArticle article )

        -- need lazy execution
        LoadArticles (Ok feed) ->
            ( { model | feed = Just feed }, Cmd.none )

        LoadArticles (Err _) ->
            ( model, Cmd.none )

        LoadTags (Ok tags) ->
            ( { model | tags = Just tags }, Cmd.none )

        LoadTags (Err _) ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions articles =
    Sub.none



--View--


viewLoveButton : Article -> Html Msg
viewLoveButton postPreview =
    let
        buttonClass =
            if postPreview.favorited then
                [ class "btn btn-outline-primary btn-sm pull-xs-right", style "background-color" "#d00", style "color" "#fff", style "border-color" "black", type_ "button", onClick (ToggleLike postPreview) ]

            else
                [ class "btn btn-outline-primary btn-sm pull-xs-right", type_ "button", onClick (ToggleLike postPreview) ]
    in
    button buttonClass
        [ i [ class "ion-heart" ] []
        , text (" " ++ String.fromInt postPreview.favoritesCount)
        ]


viewTag : String -> Html msg
viewTag tag =
    a [ href "#", class "label label-pill label-default" ] [ text tag ]


viewPostPreview : Article -> Html Msg
viewPostPreview post =
    div [ class "post-preview" ]
        [ div [ class "post-meta" ]
            [ a [ Routes.href Routes.Profile ] [ img [ src post.author.image ] [] ]
            , text " "
            , div [ class "info" ]
                [ a [ Routes.href Routes.Profile, class "author" ] [ text post.author.username ]
                , span [ class "date" ] [ text post.createdAt ]
                ]
            , viewLoveButton post
            ]
        , a [ Routes.href Routes.Post, class "preview-link" ]
            [ h1 [] [ text post.title ]
            , p [] [ text post.description ]
            , span [] [ text "Read more..." ]
            ]
        ]


viewPosts : Maybe Feed -> Html Msg
viewPosts maybeFeed =
    case maybeFeed of
        Just feed ->
            div []
                (List.map viewPostPreview feed)

        Nothing ->
            --put something nice here :)
            div [ class "loading-feed" ]
                [ text "Loading Feed..." ]



-- viewTags : List String -> Html msg
-- viewTags tags =
--     case tags of
--         [] ->
--             text ""
--         _ ->
--             div [ class "tag-list" ] (List.map viewTag tags)


viewTags : Maybe Tags -> Html Msg
viewTags maybeTags =
    case maybeTags of
        Just tags ->
            div [ class "tag-list" ]
                (List.map viewTag tags)

        Nothing ->
            div [ class "loading-tags" ]
                [ text "Loading tags..." ]



-- Only show the Global Feed if the user is not logged in (Maybe this will go into the )
-- viewTwoFeeds : LoggedIn -> Html Msg
-- viewTwoFeeds loggedIn =
--     if loggedIn then
--         [ ul [ class "nav nav-pills outline-active" ]
--             [ li [ class "nav-item" ]
--                 [ a [ class "nav-link disabled", href "#" ]
--                     [ text "Your Feed" ]
--                 ]
--             , li [ class "nav-item" ]
--                 [ a [ class "nav-link active", href "#" ]
--                     [ text "Global Feed" ]
--                 ]
--             ]
--         ]
--     else
--         [ ul [ class "nav nav-pills outline-active" ]
--             li [ class "nav-item" ]
--                 [ a [ class "nav-link active", href "#" ]
--                     [ text "Global Feed" ]
--                 ]
--         ]


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
                            --  , viewTwoFeeds (islogggedIn)
                            [ ul [ class "nav nav-pills outline-active" ]
                                [ li [ class "nav-item" ]
                                    [ a [ class "nav-link disabled", href "#" ]
                                        [ text "Your Feed" ]
                                    ]
                                , li [ class "nav-item" ]
                                    [ a [ class "nav-link active", href "#" ]
                                        [ text "Global Feed" ]
                                    ]
                                ]
                            ]
                        , viewPosts model.feed
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


type Msg
    = ToggleLike Article
    | LoadArticles (Result Http.Error Feed)
    | LoadTags (Result Http.Error Tags)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
