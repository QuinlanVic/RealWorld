module Login exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, style, type_)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, bool, field, int, list, null, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Json.Encode as Encode
import Post exposing (Model)
import Auth exposing (User, baseUrl, initialModel, userDecoder) 


--Model--
-- type alias Model =
--     { user : Maybe User
--     }


-- type alias User = --reuse from Auth.elm
--     { email : String --all of these fields are contained in the response from the server (besides last 3)
--     , token : String
--     , username : String
--     , bio : Maybe String
--     , image : Maybe String
--     , password : String --user's password
--     , signedUp : Bool --bool saying if they've signed up or not (maybe used later)
--     , errmsg : String --display any API errors from authentication
--     , usernameError : Maybe String 
--     , emailError : Maybe String 
--     , passwordError : Maybe String 
--     }


-- baseUrl : String
-- baseUrl = --reuse from Auth.elm
--     "http://localhost:3000"


saveUser : User -> Cmd Msg
saveUser user =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "user", encodeUser <| user ) ]
    in
    Http.post
        { body = body
        , expect = Http.expectJson LoadUser userDecoder -- wrap JSON received in LoadUser Msg
        , url = baseUrl ++ "api/users/login"
        }


encodeUser : User -> Encode.Value
encodeUser user =
    --used to encode user sent to the server via POST request body (for registering)
    Encode.object
        [ ( "email", Encode.string user.email )
        , ( "password", Encode.string user.password )
        ]



--userDecoder used for JSON decoding users returned when they register/sign-up

-- userDecoder : Decoder User
-- userDecoder = --reuse from Auth.elm
--     succeed User
--         |> required "email" string
--         |> required "token" string
--         |> required "username" string
--         |> required "bio" (nullable string)
--         |> required "image" (nullable string)
--         |> hardcoded ""
--         |> hardcoded True
--         |> hardcoded ""
--         |> hardcoded (Just "")
--         |> hardcoded (Just "")
--         |> hardcoded (Just "")
-- hardcoded tells JSON decoder to use a static value as an argument in the underlying decoder function instead
--of extracting a property from the JSON object



-- type alias Error =
--     (FormField, String)


getUserCompleted : User -> Result Http.Error User -> ( User, Cmd Msg )
getUserCompleted user result =
    case result of
        Ok getUser ->
            ( { user | token = getUser.token, password = "", errmsg = "" } |> Debug.log "got the user", Cmd.none )

        Err error ->
            ( { user | errmsg = Debug.toString error }, Cmd.none )


-- initialModel : User
-- initialModel = --reuse from Auth.elm
--     { email = ""
--     , token = ""
--     , username = ""
--     , bio = Just ""
--     , image = Just ""
--     , password = ""
--     , signedUpOrloggedIn = False
--     , errmsg = ""
--     , usernameError = Just ""
--     , emailError = Just ""
--     , passwordError = Just ""
--     }


init : () -> ( User, Cmd Msg )
init () =
    ( initialModel, Cmd.none )


fetchUser : Cmd Msg
fetchUser =
    Http.get
        { url = baseUrl ++ "api/users"
        , expect = Http.expectJson LoadUser userDecoder
        }



--Update--


update : Msg -> User -> ( User, Cmd Msg )
update message user =
    --what to do (update) with each message type
    case message of
        SaveEmail email ->
            ( { user | email = email }, Cmd.none )

        SavePassword password ->
            ( { user | password = password }, Cmd.none )

        Login ->
            ( { user | signedUpOrloggedIn = True }, saveUser user )

        -- LoadUser (Ok getUser) -> --confused here (return new model from the server with hardcoded password, errmsg and signedup values as those are not a part of the user record returned from the server?)
        --     -- ({getUser | signedUp = True, password = "", errmsg = ""}, Cmd.none)
        --     -- ({getUser | signedUp = True, password = "", errmsg = ""} |> Debug.log "got the user", Cmd.none)
        --     ({user | email = getUser.email, token = getUser.token, username = getUser.username, bio = getUser.bio, image = getUser.image, password = "", errmsg = ""} |> Debug.log "got the user", Cmd.none)
        -- LoadUser (Err error) ->
        --     (user, Cmd.none)
        LoadUser result ->
            getUserCompleted user result
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
    div []
        [ nav [ class "navbar navbar-light" ]
            [ div [ class "container" ]
                [ a [ class "navbar-brand", href "indexelm.html" ] [ text "conduit" ]
                , ul [ class "nav navbar-nav pull-xs-right" ]
                    --could make a function for doing all of this
                    [ li [ class "nav-item" ] [ a [ class "nav-link", href "indexelm.html" ] [ text "Home :)" ] ]
                    , li [ class "nav-item" ] [ a [ class "nav-link", href "editorelm.html" ] [ i [ class "ion-compose" ] [], text (" " ++ "New Post") ] ]
                    , li [ class "nav-item active" ] [ a [ class "nav-link", href "loginelm.html" ] [ text "Log in" ] ]
                    , li [ class "nav-item" ] [ a [ class "nav-link", href "authelm.html" ] [ text "Sign up" ] ]
                    , li [ class "nav-item" ] [ a [ class "nav-link", href "settingselm.html" ] [ text "Settings" ] ]
                    ]
                ]
            ]
        , div [ class "auth-page" ]
            [ div [ class "container page" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-6 col-md-offset-3 col-xs-12" ]
                        [ h1 [ class "text-xs-center" ] [ text "Log in" ]
                        , p [ class "text-xs-center" ] [ a [ href "authelm.html" ] [ text "Don't have an account?" ] ]

                        -- , div [ class showError ]
                        --     [ div [ class "alert alert-danger" ] [ text user.errmsg ]
                        --     ]
                        , form []
                            -- [ viewForm "text" "Your Name"
                            -- , viewForm "text" "Email"
                            -- , viewForm "password" "Password"
                            [ fieldset [ class "form-group" ] [ input [ class "form-control form-control-lg", type_ "email", placeholder "Email", onInput SaveEmail ] [] ]
                            , fieldset [ class "form-group" ] [ input [ class "form-control form-control-lg", type_ "password", placeholder "Password", onInput SavePassword ] [] ]
                            , button [ class "btn btn-lg btn-primary pull-xs-right", type_ "button", onClick Login ] [ text "Log In" ]
                            ]
                        ]
                    ]
                ]
            ]
        , footer []
            [ div [ class "container" ]
                [ a [ href "/", class "logo-font" ] [ text "conduit" ]
                , text " " --helps make spacing perfect even though it's not exactly included in the og html version
                , span [ class "attribution" ]
                    [ text "An interactive learning project from "
                    , a [ href "https:..thinkster.io" ] [ text "Thinkster" ]
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
    | LoadUser (Result Http.Error User)
-- | Error String

main : Program () User Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
