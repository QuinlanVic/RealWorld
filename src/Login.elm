module Login exposing (Msg(..), init, update, view)

import Auth exposing (Msg(..), User, baseUrl, initialModel, trimString, userDecoder, validateEmail, validatePassword)
import Html exposing (..)
import Html.Attributes exposing (class, href, id, placeholder, style, type_)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (field)
import Json.Encode as Encode
import Routes exposing (Route(..))



--Model--
--reuse User from Auth.elm (imported)


saveUserLogin : User -> Cmd Msg
saveUserLogin user =
    -- Send Login message
    let
        body =
            Http.jsonBody <| Encode.object [ ( "user", encodeUserLogin <| user ) ]
    in
    Http.post
        { body = body
        , expect = Http.expectJson SignedUpGoHome (field "user" userDecoder) -- wrap JSON received in SignedUpGoHome Msg
        , url = baseUrl ++ "api/users/login"
        }


encodeUserLogin : User -> Encode.Value
encodeUserLogin user =
    --used to encode user sent to the server via POST request body (for logging in)
    Encode.object
        [ ( "email", Encode.string user.email )
        , ( "password", Encode.string user.password )
        ]


init : ( User, Cmd Msg )
init =
    -- () -> (No longer need unit flag as it's no longer an application but a component)
    ( initialModel, Cmd.none )



--Update--


type Msg
    = SaveEmail String
    | SavePassword String
    | Login
    | SignedUpGoHome (Result Http.Error User)


isLoginValid : User -> Bool
isLoginValid user =
    Maybe.withDefault "" user.emailError == "" && Maybe.withDefault "" user.passwordError == ""


update : Msg -> User -> ( User, Cmd Msg )
update message user =
    --what to do (update) with each message type
    case message of
        SaveEmail email ->
            ( { user | email = email }, Cmd.none )

        SavePassword password ->
            ( { user | password = password }, Cmd.none )

        Login ->
            let
                --trim the input fields and then ensure that these fields are valid
                trimmedUser =
                    { user | email = trimString user.email, password = trimString user.password }

                validatedUser =
                    { trimmedUser | emailError = validateEmail trimmedUser.email, passwordError = validatePassword trimmedUser.password }
            in
            if isLoginValid validatedUser then
                ( validatedUser, saveUserLogin validatedUser )

            else
                ( validatedUser, Cmd.none )

        SignedUpGoHome (Ok gotUser) ->
            -- intercepted in Main.elm now
            ( { gotUser | signedUpOrloggedIn = True, password = "", errmsg = "" }, Cmd.none )

        SignedUpGoHome (Err error) ->
            ( { user | errmsg = Debug.toString error }, Cmd.none )



-- Now that Login is a component this is not needed
-- subscriptions : User -> Sub Msg
-- subscriptions user =
--     Sub.none
--View--


view : User -> Html Msg
view user =
    let
        -- all of this was used for testing
        mainStuff =
            let
                greeting : String
                greeting =
                    "Hello, " ++ user.username ++ "!"
            in
            if user.signedUpOrloggedIn then
                --testing
                div [ id "greeting" ]
                    [ h3 [ class "text-center" ] [ text greeting ]
                    , p [ class "text-center" ] [ text "You have successfully logged in!" ]
                    ]

            else
                -- below is all that should be shown as above was used for testing
                div [ class "auth-page" ]
                    [ div [ class "container page" ]
                        [ div [ class "row" ]
                            [ div [ class "col-md-6 col-md-offset-3 col-xs-12" ]
                                [ h1 [ class "text-xs-center" ] [ text "Log in" ]
                                , p [ class "text-xs-center" ] [ a [ Routes.href Routes.Auth ] [ text "Don't have an account?" ] ]
                                , div [ class "showError" ]
                                    [ div [ class "alert alert-danger" ] [ text user.errmsg ]
                                    ]
                                , form []
                                    [ div [ style "color" "red" ] [ text (Maybe.withDefault "" user.emailError) ]
                                    , fieldset [ class "form-group" ] [ input [ class "form-control form-control-lg", type_ "email", placeholder "Email", onInput SaveEmail ] [] ]
                                    , div [ style "color" "red" ] [ text (Maybe.withDefault "" user.passwordError) ]
                                    , fieldset [ class "form-group" ] [ input [ class "form-control form-control-lg", type_ "password", placeholder "Password", onInput SavePassword ] [] ]
                                    , button [ class "btn btn-lg btn-primary pull-xs-right", type_ "button", onClick Login ] [ text "Log In" ]
                                    ]
                                ]
                            ]
                        ]
                    ]
    in
    div []
        [ mainStuff
        , footer []
            [ div [ class "container" ]
                [ a [ Routes.href Routes.Home {- (Routes.Index Routes.Global) -}, class "logo-font" ] [ text "conduit" ]
                , text " " -- helps make spacing perfect even though it's not exactly included in the og html version
                , span [ class "attribution" ]
                    [ text "An interactive learning project from "
                    , a [ href "https://thinkster.io/" ] [ text "Thinkster" ] -- external link
                    , text ". Code & design licensed under MIT."
                    ]
                ]
            ]
        ]



-- Now that Login is a component this is not needed
-- main : Program () User Msg
-- main =
--     Browser.element
--         { init = init
--         , view = view
--         , update = update
--         , subscriptions = subscriptions
--         }
