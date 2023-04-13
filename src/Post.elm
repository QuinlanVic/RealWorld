module Post exposing (..)

import Html exposing (..)

import Html.Attributes exposing (class, href, placeholder, rows, src, type_)

main : Html msg
main =
     div[]
    [ nav[class "navbar navbar-light"]
        [div [class "container"] 
            [ a [class "navbar-brand", href "index.html"] [text "conduit"],
            ul [class "nav navbar-nav pull-xs-right"] --could make a function for doing all of this
                [ li [class "nav-item"] [a [class "nav-link", href "editorelm.html"] [i [class "ion-compose"][text "New Post"]]] --&nbsp; in Elm?
                , li [class "nav-item"] [a [class "nav-link", href "authelm.html"] [text "Sign up"]]
                , li [class "nav-item"] [a [class "nav-link", href "settingselm.html"] [text "Settings"]]
                -- <!--           <li class="nav-item active">
                --<a class="nav-link" href="index.html">Home</a>
                --</li> -->
                ]
            ]
        ]
    , div [class "post-page"] 
        [div [class "banner"] 
            [div [class "container"] 
                [ h1 [] [text "How to build webapps that scale"]
                , div [class "post-meta"] 
                    [ a [href "profile.html"] 
                        [img [src "http://i.imgur.com/Qr71crq.jpg"][]]
                    , div [class "info"] 
                        [ a [href "profile.html", class "author"] [text "Eric Simons"]
                        , span [class "date"] [text "January 20th"]
                        ]
                    , button [class "btn btn-sm btn-outline-secondary"] 
                        [ i [class "ion-plus-round"][]
                        , text "Follow Eric Simons" --&nbsp;
                        , span [class "counter"] [text "(10)"]]
                    , button [class "btn btn-sm btn-outline-primary"] -- &nbsp;&nbsp; before
                        [ i [class "ion-heart"] []
                        , text "Favorite Post"
                        , span [class "counter"] [text "(29)"]] --&nbsp; after
                    ]
                ]
            ]
        ]
    ]