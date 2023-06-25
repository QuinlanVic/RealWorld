module Auth exposing (main, userDecoder)

-- import Exts.Html exposing (nbsp)

import Browser
import Html exposing (..)
import Html.Attributes exposing (class, href, id, placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, bool, field, int, list, null, nullable, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Json.Encode as Encode
import Regex exposing (Regex, contains, fromString) 

--Model--
-- type alias Model =
--     { username : String
--     , email : String
--     , password : String
--     , signedUp : Bool
--     }

type alias User =
    { email : String --all of these fields are contained in the response from the server (besides last 3)
    , token : String
    , username : String
    , bio : Maybe String
    , image : Maybe String
    , password : String --user's password
    , signedUp : Bool --bool saying if they've signed up or not (maybe used later)
    , errmsg : String --display any API errors from authentication
    , usernameError : Maybe String 
    , emailError : Maybe String 
    , passwordError : Maybe String 
    }


baseUrl : String
baseUrl =
    "http://localhost:3000/"


saveUser : User -> Cmd Msg
saveUser user =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "user", encodeUser <| user ) ]
    in
    Http.post
        { body = body
        , expect = Http.expectJson LoadUser (field "user" userDecoder) -- wrap JSON received in LoadUser Msg
        , url = baseUrl ++ "api/users"
        }


getUserCompleted : User -> Result Http.Error User -> ( User, Cmd Msg )
getUserCompleted user result =
    case result of
        Ok getUser ->
            --confused here (return new model from the server with hardcoded password, errmsg and signedup values as those are not a part of the user record returned from the server?)
            ( { getUser | signedUp = True, password = "", errmsg = "" }, Cmd.none )

        Err error ->
            ( { user | errmsg = Debug.toString error }, Cmd.none )


encodeUser : User -> Encode.Value
encodeUser user =
    --used to encode user sent to the server via POST request body (for registering)
    Encode.object
        [ ( "username", Encode.string user.username )
        , ( "email", Encode.string user.email )
        , ( "password", Encode.string user.password )
        ]

--userDecoder used for JSON decoding users returned when they register/sign-up
userDecoder : Decoder User
userDecoder =
    succeed User
        |> required "email" string
        |> required "token" string
        |> required "username" string
        |> required "bio" (nullable string)
        |> required "image" (nullable string)
        |> hardcoded ""
        |> hardcoded True
        |> hardcoded ""
        |> hardcoded (Just "")
        |> hardcoded (Just "")
        |> hardcoded (Just "")
-- hardcoded tells JSON decoder to use a static value as an argument in the underlying decoder function instead
--of extracting a property from the JSON object

initialModel : User
initialModel =
    { email = ""
    , token = ""
    , username = ""
    , bio = Just ""
    , image = Just ""
    , password = ""
    , signedUp = False
    , errmsg = ""
    , usernameError = Just ""
    , emailError = Just ""
    , passwordError = Just ""
    }


init : () -> ( User, Cmd Msg )
init () =
    ( initialModel, Cmd.none )



-- fetchUser : Cmd Msg
-- fetchUser =
--     Http.get
--         { url = baseUrl ++ "api/users"
--         , expect = Http.expectJson LoadUser userDecoder -- wrap JSON received in LoadUser Msg
--         }
--Update--
update : Msg -> User -> ( User, Cmd Msg )
update message user =
    --what to do (update) with each message type
    case message of
        --update record syntax
        SaveName username ->
            ( { user | username = username, usernameError = validateUsername username }, Cmd.none )

        SaveEmail email ->
            ( { user | email = email, emailError = validateEmail email }, Cmd.none )

        SavePassword password ->
            ( { user | password = password, passwordError = validatePassword password }, Cmd.none )

        Signup ->
            let --trim the input fields before updating it and then ensure that these fields are valid
                trimmedUser = {user | username = String.trim user.username, email = String.trim user.email, password = String.trim user.password}
                updatedTrimmedUser = { trimmedUser | signedUp = True, usernameError = user.usernameError, emailError = user.emailError, passwordError = user.passwordError }
            in
            
            ( updatedTrimmedUser, saveUser updatedTrimmedUser )

        -- LoadUser (Ok getUser) -> --confused here (return new model from the server with hardcoded password, errmsg and signedup values as those are not a part of the user record returned from the server?)
        --     -- ({getUser | signedUp = True, password = "", errmsg = ""}, Cmd.none)
        --     -- ({getUser | signedUp = True, password = "", errmsg = ""} |> Debug.log "got the user", Cmd.none)
        --     ({user | email = getUser.email, token = getUser.token, username = getUser.username, bio = getUser.bio, image = getUser.image, password = "", errmsg = "noerror"}, Cmd.none)
        -- LoadUser (Err error) ->
        -- ({user | errmsg = Debug.toString error}, Cmd.none)
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
--         "Your Name" -> SaveName
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
    let
        mainStuff =
            let
                loggedIn : Bool 
                loggedIn =  
                    if String.length user.token > 0 then 
                        True
                    else 
                        False 

                greeting : String
                greeting =
                    "Hello, " ++ user.username ++ "!"
            in
            if loggedIn then
                --testing
                div [ id "greeting" ]
                    [ h3 [ class "text-center" ] [ text greeting ]
                    , p [ class "text-center" ] [ text "You have successfully signed up!" ]
                    ]
            else
                div [ class "auth-page" ]
                    [ div [ class "container page" ]
                        [ div [ class "row" ]
                            [ div [ class "col-md-6 col-md-offset-3 col-xs-12" ]
                                [ h1 [ class "text-xs-center" ] [ text "Sign up" ]
                                , p [ class "text-xs-center" ] [ a [ href "loginelm.html" ] [ text "Have an account?" ] ]
                                , div [ class "showError" ]
                                    [ div [ class "alert alert-danger" ] [ text user.errmsg ]
                                    ]
                                , form []
                                    -- [ viewForm "text" "Your Name"
                                    -- , viewForm "text" "Email"
                                    -- , viewForm "password" "Password"
                                    -- another function for this
                                    [ fieldset [ class "form-group" ] [ input [ class "form-control form-control-lg", type_ "text", placeholder "Your Name", onInput SaveName, value user.username ] [] ] 
                                    , div [] [ text (Maybe.withDefault "" user.usernameError) ]
                                    , fieldset [ class "form-group" ] [ input [ class "form-control form-control-lg", type_ "email", placeholder "Email", onInput SaveEmail, value user.email ] [] ]
                                    , div [] [ text (Maybe.withDefault "" user.emailError) ]
                                    , fieldset [ class "form-group" ] [ input [ class "form-control form-control-lg", type_ "password", placeholder "Password", onInput SavePassword, value user.password ] [] ]
                                    , div [] [ text (Maybe.withDefault "" user.passwordError) ]
                                    , button [ class "btn btn-lg btn-primary pull-xs-right", type_ "button", onClick Signup ] [ text "Sign up" ]
                                    ]
                                ]
                            ]
                        ]
                    ]
    in
    div []
        [ nav [ class "navbar navbar-light" ]
            [ div [ class "container" ]
                [ a [ class "navbar-brand", href "indexelm.html" ] [ text "conduit" ]
                , ul [ class "nav navbar-nav pull-xs-right" ]
                    --could make a function for doing all of this
                    [ li [ class "nav-item" ] [ a [ class "nav-link", href "indexelm.html" ] [ text "Home :)" ] ]
                    , li [ class "nav-item" ] [ a [ class "nav-link", href "editorelm.html" ] [ i [ class "ion-compose" ] [], text (" " ++ "New Post") ] ] --&nbsp; in Elm?
                    , li [ class "nav-item" ] [ a [ class "nav-link", href "loginelm.html" ] [ text "Log in" ] ]
                    , li [ class "nav-item active" ] [ a [ class "nav-link", href "authelm.html" ] [ text "Sign up" ] ]
                    , li [ class "nav-item" ] [ a [ class "nav-link", href "settingselm.html" ] [ text "Settings" ] ]
                    ]
                ]
            ]
        , mainStuff --testing
        -- div[class "auth-page"]
        --     [ div[class "container page"]
        --         [div [class "row"]
        --             [div[class "col-md-6 col-md-offset-3 col-xs-12"]
        --                 [h1 [class "text-xs-center"] [text "Sign up"],
        --                 p [class "text-xs-center"] [a [href "loginelm.html"] [text "Have an account?"]]
        --                 , form []
        --                 -- [ viewForm "text" "Your Name"
        --                 -- , viewForm "text" "Email"
        --                 -- , viewForm "password" "Password"
        --                 [ fieldset [class "form-group"] [input [class "form-control form-control-lg", type_ "text", placeholder "Your Name", onInput SaveName] []] --another function for this
        --                 , fieldset [class "form-group"] [input [class "form-control form-control-lg", type_ "email", placeholder "Email", onInput SaveEmail] []]
        --                 , fieldset [class "form-group"] [input [class "form-control form-control-lg", type_ "password", placeholder "Password", onInput SavePassword] []]
        --                 , button [class "btn btn-lg btn-primary pull-xs-right", onClick Signup] [text "Sign up"]
        --                 ]
        --                 ]
        --             ]
        --         ]
        --     ]
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
    = SaveName String
    | SaveEmail String
    | SavePassword String
    | Signup
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

-- elm-live src/Auth.elm --open --start-page=authelm.html -- --output=auth.js
-- elm make src/Auth.elm --output auth.js
