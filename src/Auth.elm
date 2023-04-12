module Auth exposing (main)

import Html exposing (..)

import Html.Attributes exposing (class, href, type_, placeholder)

--Model--
-- initialModel : {url : String, caption : String}

--Update--

--View--
-- HTML version:
--   <div class="container page">
--     <div class="row">

--       <div class="col-md-6 col-md-offset-3 col-xs-12">
--         <h1 class="text-xs-center">Sign up</h1>
--         <p class="text-xs-center">
--           <a href="#">Have an account?</a>
--         </p>
 
main : Html msg
main =
    div[]
    [ nav[class "navbar navbar-light"]
        [div [class "container"] 
            [ a [class "navbar-brand", href "index.html"] [text "conduit"],
            ul [class "nav navbar-nav pull-xs-right"] --could make a function for doing all of this
                [ li [class "nav-item"] [a [class "nav-link", href "editor.html"] [i [class "ion-compose"][text "New Post"]]] --&nbsp; in Elm?
                , li [class "nav-item"] [a [class "nav-link", href "Auth.elm"] [text "Sign up"]]
                , li [class "nav-item"] [a [class "nav-link", href "settings.html"] [text "Settings"]]
                ]
            ]
    ]
    , div[class "auth-page"]
        [ div[class "container page"]
            [div [class "row"]
                [div[class "col-md-6 col-md-offset-3 col-xs-12"]
                    [h1 [class "text-xs-center"] [text "Sign up"],
                    p [class "text-xs-center"] [a [href "#"] [text "Have an account?"]]        
                    , form []
                    [ fieldset [class "form-group"] [input [class "form-control form-control-lg", type_ "text", placeholder "Your Name"] []] --another funciton for this
                    , fieldset [class "form-group"] [input [class "form-control form-control-lg", type_ "text", placeholder "Email"] []]
                    , fieldset [class "form-group"] [input [class "form-control form-control-lg", type_ "password", placeholder "Password"] []]
                    , button [class "btn btn-lg btn-primary pull-xs-right"] [text "Sign up"]
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
--div is a function that takes in two arguments, a list of HTML attributes and a list of HTML children