module Index exposing (main)

import Browser

import Html exposing (..)

import Html.Attributes exposing (class, href, src)

import Exts.Html exposing (nbsp)
import Json.Decode exposing (int)
import Response exposing (mapModel)
import Html.Events exposing (onClick)


--Model--
initialModel : {authorpage : String, authorimage : String, authorname : String, date : String, articletitle : String, articlepreview : String, numlikes : String, liked : Bool} 
initialModel =
    { authorpage = "profileelm.html"
    , authorimage = "http://i.imgur.com/Qr71crq.jpg"
    , authorname = "Eric Simons"
    , date = "January 20th"
    , articletitle = "How to build webapps that scale"
    , articlepreview = """In my demo, the holy grail layout is nested inside a document, so there's no body or main tags like shown above. Regardless, we're interested in the class names 
                        and the appearance of sections in the markup as opposed to the actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and 
                        the trivial order in which they appear in the markup. Let's break this down to paint a clear picture of what's happening..."""
    , numlikes = " 29"
    , liked = False
    }

--Update--
update : Msg -> {authorpage : String, authorimage : String, authorname : String, date : String, articletitle : String, articlepreview : String, numlikes : String, liked : Bool} -> {authorpage : String, authorimage : String, authorname : String, date : String, articletitle : String, articlepreview : String, numlikes : String, liked : Bool}
update msg model =
    case msg of
        Like -> {model | liked = True}
        Unlike -> {model | liked = False}
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

viewPostPreview : {authorpage : String, authorimage : String, authorname : String, date : String, articletitle : String, articlepreview : String, numlikes : String, liked : Bool} -> Html Msg 
viewPostPreview model =
    let 
        buttonClass =
            if model.liked then 
                "fa-heart"
            else 
                "fa-heart-o"
        msg =
            if model.liked then 
                Unlike
            else 
                Like
    in
viewTag : String -> Html msg
viewTag tag =
    a [href "#", class "label label-pill label-default"] [text tag]

view : {authorpage : String, authorimage : String, authorname : String, date : String, articletitle : String, articlepreview : String, numlikes : String} -> Html msg
view model =
    div [class "post-preview"] 
        [ div [class "post-meta"] 
                [ a [href model.authorpage] [img [src model.authorimage] []]
                , text nbsp
                , div [class "info"] 
                    [ a [href model.authorpage, class "author"] [text model.authorname]
                    , span [class "date"] [text model.date] 
                    ]
                , button [class "btn btn-outline-primary btn-sm pull-xs-right"] 
                    [i [class "ion-heart", class buttonClass, onClick msg] []
                    , text model.numlikes
                    ]
                ]
            , a [href "postelm.html", class "preview-link"] 
                [ h1 [] [text model.articletitle]
                , p [] [text model.articlepreview]
                , span [] [text "Read more..."]
                ]
        ]

view : {authorpage : String, authorimage : String, authorname : String, date : String, articletitle : String, articlepreview : String, numlikes : String, liked : Bool} -> Html Msg
view model =
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

main : Html msg
main =
    div[]
    [ nav[class "navbar navbar-light"]
        [div [class "container"] 
            [ a [class "navbar-brand", href "indexelm.html"] [text "conduit"],
            ul [class "nav navbar-nav pull-xs-right"] --could make a function for doing all of this
                [ li [class "nav-item"] [a [class "nav-link", href "editorelm.html"] [i [class "ion-compose"][], text (nbsp ++ "New Post")]] --&nbsp; in Elm?
                , li [class "nav-item"] [a [class "nav-link", href "authelm.html"] [text "Sign up"]]
                , li [class "nav-item"] [a [class "nav-link", href "settingselm.html"] [text "Settings"]]
                -- <!--           <li class="nav-item active">
                --<a class="nav-link" href="index.html">Home</a>
                --</li> -->
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
                    , viewPostPreview model 
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
                    , div [class "post-preview"] 
                        [ div [class "post-meta"] 
                            [ a [href "profileelm.html"] [img [src "http://i.imgur.com/N4VcUeJ.jpg"] []]
                            , text nbsp
                            , div [class "info"] 
                                [ a [href "profileelm.html", class "author"] [text "Albert Pai"]
                                , span [class "date"] [text "January 20th"]
                                ]
                            , button [class "btn btn-outline-primary btn-sm pull-xs-right"] 
                                [ i [class "ion-heart"] []
                                , text " 32" 
                                ]
                            ]
                        , a [href "postelm.html", class "preview-link"] 
                            [ h1 [] [text "The song you won't ever stop singing. No matter how hard you try."]
                            , p [] [text """In my demo, the holy grail layout is nested inside a document, so there's no body or main tags like shown above. Regardless, we're interested in the class names 
                                    and the appearance of sections in the markup as opposed to the actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and 
                                    the trivial order in which they appear in the markup. Let's break this down to paint a clear picture of what's happening..."""]
                            , span [] [text "Read more..."]
                            ]
                        ]
                    ]
                , div [class "col-md-3"] 
                    [div [class "sidebar"] 
                        [ p [] [text "Popular Tags"]
                        , div [class "tag-list"] 
                            [ viewTag " programming"
                            --   a [href "#", class "label label-pill label-default"] [text " programming"]
                            [ viewTag " programming"
                            --   a [href "#", class "label label-pill label-default"] [text " programming"]
                            , text nbsp --spaces inbetween the labels
                            , viewTag " javascript"
                            -- , a [href "#", class "label label-pill label-default"] [text " javascript"]
                            , viewTag " javascript"
                            -- , a [href "#", class "label label-pill label-default"] [text " javascript"]
                            , text nbsp
                            , viewTag " angularjs"
                            -- , a [href "#", class "label label-pill label-default"] [text " angularjs"]
                            , viewTag " angularjs"
                            -- , a [href "#", class "label label-pill label-default"] [text " angularjs"]
                            , text nbsp
                            , viewTag " react"
                            -- , a [href "#", class "label label-pill label-default"] [text " react"]
                            , viewTag " react"
                            -- , a [href "#", class "label label-pill label-default"] [text " react"]
                            , text nbsp
                            , viewTag " mean"
                            -- , a [href "#", class "label label-pill label-default"] [text " mean"]
                            , viewTag " mean"
                            -- , a [href "#", class "label label-pill label-default"] [text " mean"]
                            , text nbsp
                            , viewTag " node"
                            -- , a [href "#", class "label label-pill label-default"] [text " node"]
                            , viewTag " node"
                            -- , a [href "#", class "label label-pill label-default"] [text " node"]
                            , text nbsp
                            , viewTag " rails"
                            -- , a [href "#", class "label label-pill label-default"] [text " rails"]
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
                , text nbsp --helps make spacing perfect even though it's not exactly included in the og html version
                , span [class "attribution"] 
                    [ text "An interactive learning project from "
                    , a [href "https:..thinkster.io"] [text "Thinkster"]
                    , text ". Code & design licensed under MIT."
                    ] 
                ]
            ]
        ]
    ]
    

type Msg =
    Like 
    | Unlike 

main : Program () {authorpage : String, authorimage : String, authorname : String, date : String, articletitle : String, articlepreview : String, numlikes : String,  liked : Bool } Msg
main = 
    Browser.sandbox
            { init = initialModel
            , view = view
            , update = update 
            }
    