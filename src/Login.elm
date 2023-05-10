module Login exposing (main)

import Html exposing (..)

import Html.Attributes exposing (class, href, placeholder, style, type_)

import Exts.Html exposing (nbsp)

import Html.Events exposing (onClick, onInput)
import Browser
import Post exposing (Model)

import Validate
import Exts.Html.Bootstrap.Glyphicons exposing (Glyphicon(..))

--Model--
type alias User =
    { email : String
    , password : String
    , loggedIn : Bool 
    }

-- type alias Error =
--     (FormField, String)

initialModel : User
initialModel =
    { email = ""
    , password = ""
    , loggedIn = False
    }

--Update--
update : Msg -> User -> User 
update message user = --what to do (update) with each message type
    case message of
        SaveEmail email -> { user | email = email }
        SavePassword password -> {user | password = password }
        Login -> { user | loggedIn = True }
        -- Error errormsg -> user 
        
--View--
-- getType : String -> String -> Msg
-- getType messageType = --get the type of message that should be sent to update from the placeholder (name/email/pswd)
--     case messageType of  
--         "Email" -> SaveEmail  
--         "Password" -> SavePassword
--         _ -> Error    

-- viewForm : String -> String -> Html Msg
-- viewForm textType textHolder =
--     fieldset [class "form-group"] 
--         [input [class "form-control form-control-lg", type_ textType, placeholder textHolder, onInput (getType textType)] []
--         ]
    
view : User -> Html Msg
view user =
    div[]
    [ nav[class "navbar navbar-light"]
        [div [class "container"] 
            [ a [class "navbar-brand", href "indexelm.html"] [text "conduit"],
            ul [class "nav navbar-nav pull-xs-right"] --could make a function for doing all of this
                [ li [class "nav-item"] [a [class "nav-link", href "editorelm.html"] [i [class "ion-compose"][], text (nbsp ++ "New Post")]] --&nbsp; in Elm?
                , li [class "nav-item"] [a [class "nav-link", href "loginelm.html", style "color" "black"] [text "Log in"]]
                , li [class "nav-item"] [a [class "nav-link", href "authelm.html"] [text "Sign up"]]
                , li [class "nav-item"] [a [class "nav-link", href "settingselm.html"] [text "Settings"]]
                -- <!--           <li class="nav-item active">
                --<a class="nav-link" href="index.html">Home</a>
                --</li> -->
                ]
            ]
        ]
    , div[class "auth-page"]
        [ div[class "container page"]
            [div [class "row"]
                [div[class "col-md-6 col-md-offset-3 col-xs-12"]
                    [h1 [class "text-xs-center"] [text "Log in"],
                    p [class "text-xs-center"] [a [href "authelm.html"] [text "Don't have an account?"]]        
                    , form []
                    -- [ viewForm "text" "Your Name"
                    -- , viewForm "text" "Email"
                    -- , viewForm "password" "Password"
                    [ fieldset [class "form-group"] [input [class "form-control form-control-lg", type_ "text", placeholder "Email", onInput SaveEmail] []]
                    , fieldset [class "form-group"] [input [class "form-control form-control-lg", type_ "password", placeholder "Password", onInput SavePassword] []]
                    , button [class "btn btn-lg btn-primary pull-xs-right", onClick Login] [text "Log In"]
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
--div is a function that takes in two arguments, a list of HTML attributes and a list of HTML children

--messages for defining what the update is to do upon interactivity
type Msg 
    = SaveEmail String
    | SavePassword String
    | Login 
    -- | Error String 

-- type FormField 
--     = Email
--     | Password

-- validate : User -> List Error
-- validate =
--     Validate.all
--         [ .email >> Validate.ifBlank (Email, "Please enter an email :)")
--         , .password >> Validate.ifBlank (Password, "Please enter your password :)")
--         ]


main : Program () User Msg 
main =
    Browser.sandbox
        { init = initialModel
        , view = view
        , update = update 
        }