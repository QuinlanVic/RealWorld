module Auth exposing (Msg(..), User, baseUrl, init, initialModel, isFormValid, trimString, update, userDecoder, validateEmail, validatePassword, validateUsername, view)

import Html exposing (..)
import Html.Attributes exposing (class, href, id, placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, nullable, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Json.Encode as Encode
import Regex exposing (Regex, fromString)
import Routes



--Model--
-- Changed the Model to User for better understanding
-- type alias Model =
--     { username : String
--     , email : String
--     , password : String
--     , signedUpOrloggedIn : Bool
--     }


type alias User =
    -- first 5 fields are contained in the response from the server
    { email : String
    , token : String
    , username : String
    , bio : Maybe String
    , image : Maybe String
    , password : String -- user's password
    , signedUpOrloggedIn : Bool -- bool saying if they've signed up or not
    , errmsg : String -- display any API errors from authentication

    -- input validation errors when a new user is registering themselves
    , usernameError : Maybe String
    , emailError : Maybe String
    , passwordError : Maybe String
    }


baseUrl : String
baseUrl =
    "https://api.realworld.io/"


saveUser : User -> Cmd Msg
saveUser user =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "user", encodeUser <| user ) ]
    in
    Http.post
        { body = body
        , expect = Http.expectJson SignedUpGoHome (field "user" userDecoder) -- wrap JSON received in LoadUser Msg
        , url = baseUrl ++ "api/users"
        }


encodeUser : User -> Encode.Value
encodeUser user =
    --used to encode user sent to the server via POST request body (for registering)
    Encode.object
        [ ( "username", Encode.string user.username )
        , ( "email", Encode.string user.email )
        , ( "password", Encode.string user.password )
        ]


userDecoder : Decoder User
userDecoder =
    -- userDecoder used for JSON decoding users returned when they register/sign-up
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


initialModel : User
initialModel =
    { email = ""
    , token = ""
    , username = ""
    , bio = Just ""
    , image = Just ""
    , password = ""
    , signedUpOrloggedIn = False
    , errmsg = ""
    , usernameError = Just ""
    , emailError = Just ""
    , passwordError = Just ""
    }


init : ( User, Cmd Msg )
init =
    -- () -> (No longer need unit flag as it's no longer an application but a component)
    ( initialModel, Cmd.none )


isWhiteSpace : Char -> Bool
isWhiteSpace c =
    c == ' ' || c == '\t' || c == '\n'


trimString : String -> String
trimString inputString =
    String.filter (not << isWhiteSpace) inputString


validateUsername : String -> Maybe String
validateUsername username =
    if String.isEmpty username then
        Just "Username is required"

    else
        Nothing


validateEmail : String -> Maybe String
validateEmail email =
    if String.isEmpty email then
        Just "Email is required"

    else
        let
            emailRegexResult : Maybe Regex
            emailRegexResult =
                fromString "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        in
        case emailRegexResult of
            Just emailRegex ->
                if not (Regex.contains emailRegex email) then
                    Just "Invalid Email Format"

                else
                    Nothing

            Nothing ->
                Just "Invalid email pattern"


validatePassword : String -> Maybe String
validatePassword pswd =
    if String.isEmpty pswd then
        Just "Password is required"

    else if String.length (trimString pswd) < 6 then
        Just "Password must be at least 6 characters long"

    else
        Nothing



--Update--


type Msg
    = SaveName String
    | SaveEmail String
    | SavePassword String
    | Signup
      -- | GotUser (Result Http.Error User) -- done in main now :)
    | SignedUpGoHome (Result Http.Error User)


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
            let
                -- trimString the input fields and then ensure that these fields are valid
                trimmedUser =
                    { user | email = trimString user.email, password = trimString user.password }

                validatedUser =
                    { trimmedUser | usernameError = validateUsername (trimString user.username), emailError = validateEmail trimmedUser.email, passwordError = validatePassword trimmedUser.password }
            in
            if isFormValid validatedUser then
                ( validatedUser, saveUser validatedUser )

            else
                ( validatedUser, Cmd.none )

        SignedUpGoHome (Ok gotUser) ->
            -- intercepted in Main.elm now
            ( { gotUser | signedUpOrloggedIn = True, password = "", errmsg = "" }, Cmd.none )

        SignedUpGoHome _ ->
            ( user, Cmd.none ) -- { user | errmsg = Debug.toString error }


isFormValid : User -> Bool
isFormValid user =
    Maybe.withDefault "" user.usernameError == "" && Maybe.withDefault "" user.emailError == "" && Maybe.withDefault "" user.passwordError == ""



-- no longer needed as Auth is a component now
-- subscriptions : User -> Sub Msg
-- subscriptions user =
--     Sub.none
--View--


view : User -> Html Msg
view user =
    let
        mainStuff =
            let
                -- was all used for testing
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
                -- below is all that should be shown, above was only for testing
                div [ class "auth-page" ]
                    [ div [ class "container page" ]
                        [ div [ class "row" ]
                            [ div [ class "col-md-6 col-md-offset-3 col-xs-12" ]
                                [ h1 [ class "text-xs-center" ] [ text "Sign up" ]
                                , p [ class "text-xs-center" ] [ a [ Routes.href Routes.Login ] [ text "Have an account?" ] ]
                                , div [ class "showError" ]
                                    [ div [ class "alert alert-danger" ] [ text user.errmsg ]
                                    ]
                                , form []
                                    [ div [ style "color" "red" ] [ text (Maybe.withDefault "" user.usernameError) ]
                                    , fieldset [ class "form-group" ] [ input [ class "form-control form-control-lg", type_ "text", placeholder "Your Name", onInput SaveName, value user.username ] [] ]
                                    , div [ style "color" "red" ] [ text (Maybe.withDefault "" user.emailError) ]
                                    , fieldset [ class "form-group" ] [ input [ class "form-control form-control-lg", type_ "email", placeholder "Email", onInput SaveEmail, value user.email ] [] ]
                                    , div [ style "color" "red" ] [ text (Maybe.withDefault "" user.passwordError) ]
                                    , fieldset [ class "form-group" ] [ input [ class "form-control form-control-lg", type_ "password", placeholder "Password", onInput SavePassword, value user.password ] [] ]
                                    , button [ class "btn btn-lg btn-primary pull-xs-right", type_ "button", onClick Signup ] [ text "Sign up" ]
                                    ]
                                ]
                            ]
                        ]
                    ]
    in
    div []
        [ mainStuff --testing
        , footer []
            [ div [ class "container" ]
                [ a [ Routes.href Routes.Home, class "logo-font" ] [ text "conduit" ]
                , text " " -- helps make spacing perfect even though it's not exactly included in the og html version
                , span [ class "attribution" ]
                    [ text "An interactive learning project from "
                    , a [ href "https://thinkster.io/" ] [ text "Thinkster" ] -- external link
                    , text ". Code & design licensed under MIT."
                    ]
                ]
            ]
        ]



-- Now Auth is a component and no longer an application
-- main : Program () User Msg
-- main =
--     Browser.element
--         { init = init
--         , view = view
--         , update = update
--         , subscriptions = subscriptions
--         }
