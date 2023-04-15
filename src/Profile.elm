module Profile exposing (..)

import Html exposing (..)

import Html.Attributes exposing (class, href, src)

import Exts.Html exposing (nbsp)

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
    , div [class "profile-page"]
        [ div [class "user-info"] 
             [ div [class "container"] 
                [div [class "row"]
                    [div [class "col-md-10 col-md-offset-1"] 
                        [ img [src "http://i.imgur.com/Qr71crq.jpg", class "user-img"] []
                        , h4 [] [text "Eric Simons"]
                        , p [] [text " Cofounder @GoThinkster, lived in Aol's HQ for a few months, kinda looks like Peeta from the Hunger Games"]
                        , text nbsp
                        , button [class "btn btn-sm btn-outline-secondary action-btn"] 
                            [i [class "ion-plus-round"] []
                            , text (nbsp ++ nbsp ++ "  Follow Eric Simons ")
                            , span [class "counter"] [text "(10)"]
                            ]
                        ]
                    ]
                ]
            ]
        , div [class "container"] 
            [div [class "row"] 
                 [div [class "col-md-10 col-md-offset-1"] 
                     [ div [class "posts-toggle"]
                        [ul [class "nav nav-pills outline-active"]
                            [ li [class "nav-item"] 
                                [a [class "nav-link active", href "#"] [text "My Posts"]]
                            , li [class "nav-item"] 
                                [a [class "nav-link", href "#"] [text "Favorited Posts"]]
                            ]
                        ]
                    , div [class "post-preview"] 
                        [div [class "post-meta"] 
                            [ a [href "profileelm.html"] [img [src "http://i.imgur.com/Qr71crq.jpg"] []]
                            , text nbsp
                            , div [class "info"] 
                                [ a [href "profileelm.html", class "author"] [text "Eric Simons"]
                                , span [class "date"] [text "January 20th"]
                                ]
                            , button [class "btn btn-outline-primary btn-sm pull-xs-right"] 
                                [ i [class "ion-heart"] []
                                , text " 29"
                                ]
                            ]
                        , a [href "post-meta", class "preview-link"]
                            [ h1 [] [text "How to build webapps that scale"]
                            , p [] [text """In my demo, the holy grail layout is nested inside a document, so there's no body or main tags like shown above. 
                                            Regardless, we're interested in the class names and the appearance of sections in the markup as opposed to the 
                                            actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and the 
                                            trivial order in which they appear in the markup. Let's break this down to paint a clear picture of what's happening..."""]
                            , span [] [text "Read more..."] 
                            ]
                        ]
                    , div [class "post-preview"] 
                        [div [class "post-meta"] 
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
                            , p [] [text """In my demo, the holy grail layout is nested inside a document, so there's no body or main tags like shown above. 
                                            Regardless, we're interested in the class names and the appearance of sections in the markup as opposed to the 
                                            actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and the 
                                            trivial order in which they appear in the markup. Let's break this down to paint a clear picture of what's happening..."""] 
                            , span [] [text "Read more..."] 
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
