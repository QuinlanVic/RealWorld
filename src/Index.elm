module Index exposing (Model, Msg, init, main, update, view)

-- import Exts.Html exposing (nbsp)

import Auth exposing (baseUrl)
import Browser
import Editor exposing (Author, authorDecoder)
import Html exposing (..)
import Html.Attributes exposing (class, href, id, src, style, type_)
import Html.Events exposing (onClick)
import Http
import Json.Decode exposing (Decoder, bool, field, int, list, null, string, succeed)
import Json.Decode.Pipeline exposing (custom, hardcoded, required)
import Response exposing (mapModel)
import Routes



--Model--


type alias Id =
    Int


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
    , id : Id
    }


type alias Feed =
    List Article


type alias Model =
    { feed : Maybe Feed --postpreview may exist or not lol
    , tags : List String
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
        |> hardcoded 0


initialModel : Model
initialModel =
    { feed = Just [ postPreview1, postPreview2 ]
    , tags = [ " programming", " javascript", " angularjs", " react", " mean", " node", " rails" ]
    }


fetchArticles : Cmd Msg
fetchArticles =
    Http.get
        { url = baseUrl ++ "api/articles"
        , expect = Http.expectJson LoadArticles (list (field "article" articleDecoder))
        }


init : () -> ( Model, Cmd Msg )
init () =
    ( initialModel, fetchArticles )


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
    { slug = """In my demo, the holy grail layout is nested inside a document, so there's no body or main tags like shown above. Regardless, we're interested in the class names 
                        and the appearance of sections in the markup as opposed to the actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and 
                        the trivial order in which they appear in the markup. Let's break this down to paint a clear picture of what's happening..."""
    , title = "How to build webapps that scale"
    , description = ""
    , body = ""
    , tagList = [ "" ]
    , createdAt = "January 20th"
    , updatedAt = ""
    , favorited = False
    , favoritesCount = 29
    , author = author1
    , id = 1
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
    { slug = """In my demo, the holy grail layout is nested inside a document, so there's no body or main tags like shown above. Regardless, we're interested in the class names 
                        and the appearance of sections in the markup as opposed to the actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and 
                        the trivial order in which they appear in the markup. Let's break this down to paint a clear picture of what's happening..."""
    , title = "The song you won't ever stop singing. No matter how hard you try."
    , description = ""
    , body = ""
    , tagList = [ "" ]
    , createdAt = "January 20th"
    , updatedAt = ""
    , favorited = False
    , favoritesCount = 32
    , author = author2
    , id = 2
    }



--Update--


updateArticleById : (Article -> Article) -> Id -> Feed -> Feed
updateArticleById updateArticle id feed =
    List.map
        (\article ->
            if article.id == id then
                updateArticle article

            else
                article
        )
        feed


updatePostPreviewLikes : (Article -> Article) -> Id -> Maybe Feed -> Maybe Feed
updatePostPreviewLikes updateArticle id maybeFeed =
    Maybe.map (updateArticleById updateArticle id) maybeFeed



-- case postpreviews of
--     Just post ->
--         if post.favorited then
--             Just { post | favorited = not post.favorited, favoritesCount = post.favoritesCount - 1 }
--         else
--             Just { post | favorited = not post.favorited, favoritesCount = post.favoritesCount + 1 }
--     Nothing ->
--         Nothing


toggleLike : Article -> Article
toggleLike article =
    { article | favorited = not article.favorited }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleLike id ->
            ( { model | feed = updatePostPreviewLikes toggleLike id model.feed }, Cmd.none )

        -- need lazy execution
        LoadArticles (Ok feed) ->
            ( { model | feed = Just feed }, Cmd.none )

        LoadArticles (Err _) ->
            ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions articles =
    Sub.none



--View--


viewTag : String -> Html msg
viewTag tag =
    a [ href "#", class "label label-pill label-default" ] [ text tag ]


viewTags : List String -> Html msg
viewTags tags =
    case tags of
        [] ->
            text ""

        _ ->
            div [ class "tag-list" ] (List.map viewTag tags)


viewLoveButton : Article -> Html Msg
viewLoveButton postPreview =
    let
        buttonClass =
            if postPreview.favorited then
                [ class "btn btn-outline-primary btn-sm pull-xs-right", style "background-color" "#d00", style "color" "#fff", style "border-color" "black", type_ "button", onClick (ToggleLike postPreview.id) ]

            else
                [ class "btn btn-outline-primary btn-sm pull-xs-right", type_ "button", onClick (ToggleLike postPreview.id) ]
    in
    button buttonClass
        [ i [ class "ion-heart" ] []
        , text (" " ++ String.fromInt postPreview.favoritesCount)
        ]


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
            , p [] [ text post.slug ]
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

                        -- , div [class "post-preview"]
                        --     [ div [class "post-meta"]
                        --         [ a [href "profileelm.html"] [img [src "http://i.imgur.com/Qr71crq.jpg"] []]
                        --         , text nbsp
                        --         , div [class "info"]
                        --             [ a [href "profileelm.html", class "author"] [text "Eric Simons"]
                        --             , span [class "date"] [text "January 20th"]
                        --             ]
                        --         , button [class "btn btn-outline-primary btn-sm pull-xs-right"]
                        --             [i [class "ion-heart"] []
                        --             , text " 29"
                        --             ]
                        --         ]
                        --     , a [href "postelm.html", class "preview-link"]
                        --         [ h1 [] [text "How to build webapps that scale"]
                        --         , p [] [text """In my demo, the holy grail layout is nested inside a document, so there's no body or main tags like shown above. Regardless, we're interested in the class names
                        --                 and the appearance of sections in the markup as opposed to the actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and
                        --                 the trivial order in which they appear in the markup. Let's break this down to paint a clear picture of what's happening..."""]
                        --         , span [] [text "Read more..."]
                        --         ]
                        --     ]
                        -- , viewPostPreview model2
                        -- , div [class "post-preview"]
                        --     [ div [class "post-meta"]
                        --         [ a [href "profileelm.html"] [img [src "http://i.imgur.com/N4VcUeJ.jpg"] []]
                        --         , text nbsp
                        --         , div [class "info"]
                        --             [ a [href "profileelm.html", class "author"] [text "Albert Pai"]
                        --             , span [class "date"] [text "January 20th"]
                        --             ]
                        --         , button [class "btn btn-outline-primary btn-sm pull-xs-right"]
                        --             [ i [class "ion-heart"] []
                        --             , text (" " ++ String.fromInt 32)
                        --             ]
                        --         ]
                        --     , a [href "postelm.html", class "preview-link"]
                        --         [ h1 [] [text "The song you won't ever stop singing. No matter how hard you try."]
                        --         , p [] [text """In my demo, the holy grail layout is nested inside a document, so there's no body or main tags like shown above. Regardless, we're interested in the class names
                        --                 and the appearance of sections in the markup as opposed to the actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and
                        --                 the trivial order in which they appear in the markup. Let's break this down to paint a clear picture of what's happening..."""]
                        --         , span [] [text "Read more..."]
                        --         ]
                        --     ]
                        ]
                    , div [ class "col-md-3" ]
                        [ div [ class "sidebar" ]
                            [ p [] [ text "Popular Tags" ]
                            , viewTags model.tags

                            -- , viewTags [" programming", " javascript", " angularjs", " react", " mean", " node", " rails"]
                            --  viewTag " programming"
                            -- --   a [href "#", class "label label-pill label-default"] [text " programming"]
                            -- , text " " --spaces inbetween the labels
                            -- , viewTag " javascript"
                            -- -- , a [href "#", class "label label-pill label-default"] [text " javascript"]
                            -- , text " "
                            -- , viewTag " angularjs"
                            -- -- , a [href "#", class "label label-pill label-default"] [text " angularjs"]
                            -- , text " "
                            -- , viewTag " react"
                            -- -- , a [href "#", class "label label-pill label-default"] [text " react"]
                            -- , text " "
                            -- , viewTag " mean"
                            -- -- , a [href "#", class "label label-pill label-default"] [text " mean"]
                            -- , text " "
                            -- , viewTag " node"
                            -- -- , a [href "#", class "label label-pill label-default"] [text " node"]
                            -- , text " "
                            -- , viewTag " rails"
                            -- -- , a [href "#", class "label label-pill label-default"] [text " rails"]
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
    = ToggleLike Id
    | LoadArticles (Result Http.Error Feed)


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
