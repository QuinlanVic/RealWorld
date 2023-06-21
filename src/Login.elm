module Login exposing (main)

import Html exposing (..)

import Html.Attributes exposing (class, href, placeholder, style, type_)

import Html.Events exposing (onClick, onInput)
import Browser
import Post exposing (Model)

import Http

import Json.Decode exposing (Decoder, bool, int, list, string, succeed) 

import Json.Decode.Pipeline exposing (hardcoded, required)   

import Json.Encode as Encode

import Json.Decode exposing (null)

--Model--
type alias User =
    { email : String
    , password : String
    , loggedIn : Bool 
    }

baseUrl : String
baseUrl = "http://127.0.0.1:8010/proxy/"    

encodeUser : User -> Encode.Value
encodeUser user = --used to encode user sent to the server via POST request body (for registering)
    Encode.object
        [ ( "email", Encode.string user.email )
        , ( "password", Encode.string user.password )   
        ]

-- userDecoder : Decoder User 
-- userDecoder =
--     succeed User
--         |> required "email" string
--         |> required "token" string
--         |> required "username" string
--         |> required "bio" string 
--         |> required "image" string 
--         |> hardcoded ""
--         |> hardcoded True  
--         |> hardcoded ""

-- type alias Error =
--     (FormField, String)

-- getUserCompleted : User -> Result Http.Error User -> ( User, Cmd Msg )
-- getUserCompleted user result =
--     case result of  
--         Ok getUser ->
--             ({user | token = getUser.token, password = "", errmsg = ""} |> Debug.log "got the user", Cmd.none)  
--         Err error ->
--             ({user | errmsg = (Debug.toString error) }, Cmd.none)

initialModel : User
initialModel =
    { email = ""
    , password = ""
    , loggedIn = False
    }

init : () -> (User, Cmd Msg)
init () =
    (initialModel, Cmd.none)

-- fetchUser : Cmd Msg
-- fetchUser =
--     Http.get 
--         { url = baseUrl ++ "api/users"
--         , expect = Http.expectJson LoadUser userDecoder 
--         }

--Update--
update : Msg -> User -> (User, Cmd Msg)
update message user = --what to do (update) with each message type
    case message of
        SaveEmail email -> ({ user | email = email }, Cmd.none)
        SavePassword password -> ({user | password = password }, Cmd.none)
        Login -> ({ user | loggedIn = True }, Cmd.none)
        -- LoadUser result -> getUserCompleted user result 
        -- Error errormsg -> user 

subscriptions : User -> Sub Msg
subscriptions user =
    Sub.none
        
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
                [ li [class "nav-item"] [a [class "nav-link", href "indexelm.html"] [text "Home :)"]]
                , li [class "nav-item"] [a [class "nav-link", href "editorelm.html"] [i [class "ion-compose"][], text (" " ++ "New Post")]] --&nbsp; in Elm?
                , li [class "nav-item active"] [a [class "nav-link", href "loginelm.html"] [text "Log in"]]
                , li [class "nav-item"] [a [class "nav-link", href "authelm.html"] [text "Sign up"]]
                , li [class "nav-item"] [a [class "nav-link", href "settingselm.html"] [text "Settings"]]
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
            , text " " --helps make spacing perfect even though it's not exactly included in the og html version
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
    -- | LoadUser (Result Http.Error User) 
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
    Browser.element 
        { init = init
        , view = view
        , update = update 
        , subscriptions = subscriptions 
        }