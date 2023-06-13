module Auth exposing (main, userDecoder)

import Html exposing (..)

import Html.Attributes exposing (class, href, placeholder, style, type_)

-- import Exts.Html exposing (nbsp)

import Html.Events exposing (onClick, onInput)

import Browser

import Http

import Json.Decode exposing (Decoder, bool, int, list, string, succeed) 

import Json.Decode.Pipeline exposing (hardcoded, required)  

import Json.Encode as Encode

import Json.Decode exposing (null)

--Model--
type alias Model =
    { username : String
    , email : String
    , password : String
    , signedUp : Bool 
    }

type alias User =
    { email : String
    , token : String
    , username : String
    , bio : String
    , image : String 
    }

-- saveUser : User -> Cmd Msg
-- saveUser user = 
--     let
--         body =
--             Http.jsonBody <|
--                 Encode.object
--                     [ ( "username", Encode.string user.username )
--                     , ( "email", Encode.string user.username )
--                     , ( "password", Encode.string user.password )
--                     ]

--         decoder =
--             accountDecoder
--                 |> Json.map (always ())
--     in
--     Http.request
--         { method = "POST"
--         , headers = []
--         , url = accountUrl
--         , body = body
--         , expect = Http.expectJson SavedAccount decoder
--         , timeout = Nothing
--         , tracker = Nothing
--         }

encodeUser : User -> Encode.Value
encodeUser user =
    Encode.object
        [ ( "username", Encode.string user.username ) 
        , ( "email", Encode.string user.email )
        -- , ( "password", Encode.string user.password )   
        ]

--userDecoder used for JSON decoding users returned when they register/sign-up
userDecoder : Decoder User 
userDecoder =
    succeed User
        |> required "email" string
        |> required "token" string
        |> required "username" string
        |> required "bio" string 
        |> required "image" string 
        -- hardcoded tells JSON decoder to use a static value as an argument in the underlying decoder function instead
        --of extracting a property from the JSON object

initialModel : Model
initialModel =
    { username = ""
    , email = ""
    , password = ""
    , signedUp = False
    }

init : () -> (Model, Cmd Msg)
init () =
    (initialModel, Cmd.none)

fetchUser : Cmd Msg
fetchUser =
    Http.get 
        { url = baseUrl ++ "/api/users"
        , expect = Http.expectJson LoadUser userDecoder 
        }

--Update--
update : Msg -> Model -> (Model, Cmd Msg)
update message model = --what to do (update) with each message type
    case message of --update record syntax
        SaveName username -> ({ model | username = username }, Cmd.none)
        SaveEmail email -> ({ model | email = email }, Cmd.none)
        SavePassword password -> ({model | password = password }, Cmd.none)
        Signup -> ({ model | signedUp = True }, Cmd.none)
        LoadUser _ -> (model, fetchUser)
        -- Error errormsg -> model 

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
        
--View--
-- getType : String -> String -> Msg
-- getType messageType = --get the type of message that should be sent to update from the placeholder (name/email/pswd)
--     case messageType of
--         "Your Name" -> SaveName  
--         "Email" -> SaveEmail  
--         "Password" -> SavePassword
--         _ -> Error    

-- viewForm : String -> String -> Html Msg
-- viewForm textType textHolder =
--     fieldset [class "form-group"] 
--         [input [class "form-control form-control-lg", type_ textType, placeholder textHolder, onInput (getType textType)] []
--         ]

baseUrl : String
baseUrl = "http://localhost:3000"    

view : Model -> Html Msg
view model =
    div[]
    [ nav[class "navbar navbar-light"]
        [div [class "container"] 
            [ a [class "navbar-brand", href "indexelm.html"] [text "conduit"],
            ul [class "nav navbar-nav pull-xs-right"] --could make a function for doing all of this
                [ li [class "nav-item"] [a [class "nav-link", href "indexelm.html"] [text "Home :)"]]
                , li [class "nav-item"] [a [class "nav-link", href "editorelm.html"] [i [class "ion-compose"][], text (" " ++ "New Post")]] --&nbsp; in Elm?
                , li [class "nav-item"] [a [class "nav-link", href "loginelm.html"] [text "Log in"]]
                , li [class "nav-item active"] [a [class "nav-link", href "authelm.html"] [text "Sign up"]]
                , li [class "nav-item"] [a [class "nav-link", href "settingselm.html"] [text "Settings"]]
                ]
            ]
        ]
    , div[class "auth-page"]
        [ div[class "container page"]
            [div [class "row"]
                [div[class "col-md-6 col-md-offset-3 col-xs-12"]
                    [h1 [class "text-xs-center"] [text "Sign up"],
                    p [class "text-xs-center"] [a [href "loginelm.html"] [text "Have an account?"]]        
                    , form []
                    -- [ viewForm "text" "Your Name"
                    -- , viewForm "text" "Email"
                    -- , viewForm "password" "Password"
                    [ fieldset [class "form-group"] [input [class "form-control form-control-lg", type_ "text", placeholder "Your Name", onInput SaveName] []] --another function for this
                    , fieldset [class "form-group"] [input [class "form-control form-control-lg", type_ "text", placeholder "Email", onInput SaveEmail] []]
                    , fieldset [class "form-group"] [input [class "form-control form-control-lg", type_ "password", placeholder "Password", onInput SavePassword] []]
                    , button [class "btn btn-lg btn-primary pull-xs-right", onClick Signup] [text "Sign up"]
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
    = SaveName String 
    | SaveEmail String
    | SavePassword String
    | Signup 
    | LoadUser (Result Http.Error User)
    -- | Error String 


main : Program () Model Msg 
main =
    Browser.element
        { init = init 
        , view = view
        , update = update 
        , subscriptions = subscriptions
        }