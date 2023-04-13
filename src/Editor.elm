module Editor exposing (main)

import Html exposing (..)

import Html.Attributes exposing (class, href, placeholder, rows, type_)

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
                ]
            ]
        ]
    , div [class "settings-page"]
        [div [class "container page"] 
            [div [class "row"] 
                [div [class "col-md-10 col-md-offset-1 col-xs-12"] 
                    [form [] 
                        [ fieldset [class "form-group"] 
                            [input [class "form-control form-control-lg", type_ "text", placeholder "Post Title"] []]
                        , fieldset [class "form-group"] 
                            [textarea [class "form-control", rows 8, placeholder "Write your post (in markdown)"] []]
                        , fieldset [class "form-group"] 
                            [ input [class "form-control", type_ "text", placeholder "Enter tags"] []
                            , div [class "tag-list"]
                                [ span [class "label label-pill label-default"] [i [class "ion-close-round"] [], text "programming"]
                                , span [class "label label-pill label-default"] [i [class "ion-close-round"] [], text "javascript"]
                                , span [class "label label-pill label-default"] [i [class "ion-close-round"] [], text "webdev"]
                                ]
                            ]
                        , button [class "btn btn-lg btn-primary pull-xs-right"] [text "Create Post"]    
                        ]
                    ]
                ]
            ]
        ]
    , footer []
        [ div [class "container"]
            [ a [href "/", class "logo-font"] [text "conduit"]]
            , span [class "attribution"] 
                [ text "An interactive learning project from"
                , a [href "https:..thinkster.io"] [text "Thinkster"]
                , text "Code & design licensed under MIT."
                ]
        ]
    ]
