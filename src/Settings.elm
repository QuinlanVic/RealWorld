module Settings exposing (main)

import Html exposing (..)

import Html.Attributes exposing (class, href, type_, placeholder)
import Html.Attributes exposing (rows)

main : Html msg

main = 
    div[]
    [ nav[class "navbar navbar-light"]
        [div [class "container"] 
            [ a [class "navbar-brand", href "index.html"] [text "conduit"],
            ul [class "nav navbar-nav pull-xs-right"] --could make a function for doing all of this
                [ li [class "nav-item"] [a [class "nav-link", href "editor.html"] [i [class "ion-compose"][text "New Post"]]] --&nbsp; in Elm?
                , li [class "nav-item"] [a [class "nav-link", href "authelm.html"] [text "Sign up"]]
                , li [class "nav-item"] [a [class "nav-link", href "settingselm.html"] [text "Settings"]]
                ]
            ]
        ]
    , div [class "settings-page"]
        [div [class "container page"] 
            [div [class "row"] 
                [div [class "col-md-6 col-md-offset-3 col-xs-12"] 
                    [ h1 [class "text-xs-center"] [text "Your Settings"]
                    , form [] 
                        [ fieldset [class "form-group"] 
                            [input [class "form-control", type_ "text", placeholder "URL of profile picture"] [] --<!--<input type="file" id="file"> -->
                            ]
                        , fieldset [class "form-group"] 
                            [input [class "form-control form-control-lg", type_ "text", placeholder "Your Name"] []
                            ]
                        , fieldset [class "form-group"] 
                            [textarea [class "form-control form-control-lg", rows 8, placeholder "Short bio about you"] []
                            ]
                        , fieldset [class "form-group"] 
                            [input [class "form-control form-control-lg", type_ "text", placeholder "Email"] []
                            ]
                        , fieldset [class "form-group"]
                            [input [class "form-control form-control-ig", type_ "password", placeholder "Password"] []
                            ]
                        , button [class "btn btn-lg btn-primary pull-xs-right"] [text "Update Settings"]
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


