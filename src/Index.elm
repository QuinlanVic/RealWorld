module Index exposing (main)

import Browser

import Html exposing (..)

import Html.Attributes exposing (id, class, href, src, style, type_)

-- import Exts.Html exposing (nbsp)
import Json.Decode exposing (Decoder, bool, field, int, list, null, string, succeed) 
import Json.Decode.Pipeline exposing (custom, hardcoded, required)  
import Response exposing (mapModel)
import Html.Events exposing (onClick)
import Http
import Auth exposing (baseUrl)
import Editor exposing (Article, articleDecoder) 

--Model--
type alias Model =
    { postPreviews : List PostPreview
    , tags : List String 
    }

initialModel : Model
initialModel =
    { postPreviews = [postPreview1, postPreview2]
    , tags =  [" programming", " javascript", " angularjs", " react", " mean", " node", " rails"]
    }

fetchArticles : Cmd Msg
fetchArticles =
    Http.get
        { url = baseUrl ++ "api/articles"
        , expect = Http.expectJson LoadArticles (field "article" articleDecoder) 
        }

init : () -> (Model, Cmd Msg)
init () =
    (initialModel, fetchArticles)

type alias PostPreview =
    { authorpage : String
    , authorimage : String
    , authorname : String
    , date : String
    , articletitle : String
    , articlepreview : String
    , numlikes : Int
    , liked : Bool
    , id : String 
    }

postPreview1 : PostPreview 
postPreview1 = 
    { authorpage = "profileelm.html"
    , authorimage = "http://i.imgur.com/Qr71crq.jpg"
    , authorname = "Eric Simons"
    , date = "January 20th"
    , articletitle = "How to build webapps that scale"
    , articlepreview = """In my demo, the holy grail layout is nested inside a document, so there's no body or main tags like shown above. Regardless, we're interested in the class names 
                        and the appearance of sections in the markup as opposed to the actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and 
                        the trivial order in which they appear in the markup. Let's break this down to paint a clear picture of what's happening..."""
    , numlikes = 29
    , liked = False
    , id = "Num1"
    }

postPreview2 : PostPreview 
postPreview2 =
    { authorpage = "profileelm.html"
    , authorimage = "http://i.imgur.com/N4VcUeJ.jpg"
    , authorname = "Albert Pai"
    , date = "January 20th"
    , articletitle = "The song you won't ever stop singing. No matter how hard you try."
    , articlepreview = """In my demo, the holy grail layout is nested inside a document, so there's no body or main tags like shown above. Regardless, we're interested in the class names 
                        and the appearance of sections in the markup as opposed to the actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and 
                        the trivial order in which they appear in the markup. Let's break this down to paint a clear picture of what's happening..."""
    , numlikes = 32
    , liked = False
    , id = "Num2"
    }

--Update--
updatePostPreviewLikes : PostPreview -> PostPreview
updatePostPreviewLikes postpreview = --very inefficient
    if postpreview.liked then {postpreview | liked = not postpreview.liked, numlikes = postpreview.numlikes - 1} else {postpreview | liked = not postpreview.liked, numlikes = postpreview.numlikes + 1}

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleLike -> ({model | postPreviews = List.map updatePostPreviewLikes model.postPreviews}, Cmd.none) --need lazy execution
        LoadArticles articles -> (model, Cmd.none)
        -- Like -> {model | liked = True}
        -- Unlike -> {model | liked = False}

subscriptions : Model -> Sub Msg
subscriptions articles = 
    Sub.none 

--View--
viewTag : String -> Html msg
viewTag tag =
    a [href "#", class "label label-pill label-default"] [text tag] 
    
-- viewTags : List String -> Html msg
-- viewTags tagList =
--     div [class "tag-list"]
--         case tag of tagList
--         [ a [href "#", class "label label-pill label-default"] [text " programming"]
--         , text nbsp --spaces inbetween the labels
--         ]

viewLoveButton : PostPreview -> Html Msg 
viewLoveButton postPreview =
    let 
        buttonClass =
            if postPreview.liked then 
                [class "btn btn-outline-primary btn-sm pull-xs-right", style "background-color" "#d00", style "color" "#fff", style "border-color" "black", type_ "button", onClick ToggleLike, id postPreview.id] 
            else 
                [class "btn btn-outline-primary btn-sm pull-xs-right", type_ "button", onClick ToggleLike] 
    in
    button buttonClass
           [i [class "ion-heart"] []
           , text (" " ++ String.fromInt postPreview.numlikes)
           ]

viewPostPreview : PostPreview -> Html Msg 
viewPostPreview postPreview =
    div [class "post-preview"] 
        [ div [class "post-meta"] 
                [ a [href postPreview.authorpage] [img [src postPreview.authorimage] []]
                , text " "
                , div [class "info"] 
                    [ a [href postPreview.authorpage, class "author"] [text postPreview.authorname]
                    , span [class "date"] [text postPreview.date] 
                    ]
                , viewLoveButton postPreview
                ]
            , a [href "postelm.html", class "preview-link"] 
                [ h1 [] [text postPreview.articletitle]
                , p [] [text postPreview.articlepreview]
                , span [] [text "Read more..."]
                ]
        ]

viewPosts : List PostPreview -> Html Msg 
viewPosts postPreviews =
    div [] --ul and li = weird dot :)
        (List.map viewPostPreview postPreviews) 

view : Model -> Html Msg
view model =
    div[]
    [ nav[class "navbar navbar-light"]
        [div [class "container"] 
            [ a [class "navbar-brand", href "indexelm.html"] [text "conduit"],
            ul [class "nav navbar-nav pull-xs-right"] --could make a function for doing all of this
                [ li [class "nav-item active"] [a [class "nav-link", href "indexelm.html"] [text "Home :)"]]
                , li [class "nav-item"] [a [class "nav-link", href "editorelm.html"] [i [class "ion-compose"][], text (" " ++ "New Post")]] --&nbsp; in Elm?
                , li [class "nav-item"] [a [class "nav-link", href "loginelm.html"] [text "Log in"]]
                , li [class "nav-item"] [a [class "nav-link", href "authelm.html"] [text "Sign up"]]
                , li [class "nav-item"] [a [class "nav-link", href "settingselm.html"] [text "Settings"]]
                ]
            ]
        ]
    , div [class "home-page"] 
        [ div [class "banner"] 
            [div [class "container"] 
                [ h1 [class "logo-font"] 
                    [text "conduit"]
                , p [] [text "A place to share your knowledge."]
                ]
            ]
        , div [class "container page"] 
            [div [class "row"]
                [ div [class "col-md-9"] 
                    [ div [class "feed-toggle"] 
                        [ul [class "nav nav-pills outline-active"] 
                            [ li [class "nav-item"] 
                                [a [class "nav-link disabled", href "#"] 
                                    [text "Your Feed"]
                                ]
                            , li [class "nav-item"] 
                                [a [class "nav-link active", href "#"] 
                                    [text "Global Feed"]
                                ]
                            ]
                        ]
                    , viewPosts model.postPreviews
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
                , div [class "col-md-3"] 
                    [div [class "sidebar"] 
                        [ p [] [text "Popular Tags"]
                        -- , viewTags [" programming", " javascript", " angularjs", " react", " mean", " node", " rails"]
                        , div [class "tag-list"] 
                            [ viewTag " programming"
                            --   a [href "#", class "label label-pill label-default"] [text " programming"]
                            , text " " --spaces inbetween the labels
                            , viewTag " javascript"
                            -- , a [href "#", class "label label-pill label-default"] [text " javascript"]
                            , text " "
                            , viewTag " angularjs"
                            -- , a [href "#", class "label label-pill label-default"] [text " angularjs"]
                            , text " "
                            , viewTag " react"
                            -- , a [href "#", class "label label-pill label-default"] [text " react"]
                            , text " "
                            , viewTag " mean"
                            -- , a [href "#", class "label label-pill label-default"] [text " mean"]
                            , text " "
                            , viewTag " node"
                            -- , a [href "#", class "label label-pill label-default"] [text " node"]
                            , text " "
                            , viewTag " rails"
                            -- , a [href "#", class "label label-pill label-default"] [text " rails"]
                            ]
                        ]
                    ]
                ]
            ]
        ]
    , footer []
        [ div [class "container"]
            [ a [href "/", class "logo-font"] [text "conduit"]
            , text " " --helps make spacing perfect even though it's not exactly included in the og html version
            , span [class "attribution"] 
                [ text "An interactive learning project from "
                , a [href "https:..thinkster.io"] [text "Thinkster"]
                , text ". Code & design licensed under MIT."
                ] 
            ]
        ]
    ]
    

type Msg 
    = ToggleLike 
    | LoadArticles (Result Http.Error Article)


main : Program () Model Msg
main = 
    Browser.element
        { init = init
        , view = view
        , update = update 
        , subscriptions = subscriptions 
        }
    