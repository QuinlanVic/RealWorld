module Auth exposing (main)

import Html exposing (..)

import Html.Attributes exposing (class)
import Html.Attributes exposing (href)

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
    div[class "auth-page"]
        [div[class "container page"]
            [div [class "row"]
                [div[class "col-md-6 col-md-offset-3 col-xs-12"]
                    [h1 [class "text-xs-center"] [text "Sign up"],
                    p [class "text-xs-center"] [a [href "#"] [text "Have an account?"]]
                    ]
                ]
            ]
        ]
--div is a function that takes in two arguments, a list of HTML attributes and a list of HTML children