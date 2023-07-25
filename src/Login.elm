module Login exposing (Msg, init, update, view)

-- import Browser

import Auth exposing (User, baseUrl, initialModel, trimString, userDecoder, validateEmail, validatePassword)
import Html exposing (..)
import Html.Attributes exposing (class, href, id, placeholder, style, type_)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, bool, field, int, list, null, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Json.Encode as Encode
import Routes exposing (Route(..))



-- import Task
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
-- port storeToken : String -> Cmd Msg
-- storeToken : String -> Cmd Msg
-- storeToken token =
--     port storeToken (Encode.string as token)


saveUser : User -> Cmd Msg
saveUser user =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "user", encodeUser <| user ) ]
    in
    Http.post
        { body = body
        , expect = Http.expectJson GotUser (field "user" userDecoder) -- wrap JSON received in GotUser Msg
        , url = baseUrl ++ "api/users/login"
        }
        |> Cmd.map (Debug.log "LoginSuccess" >> always Login)



-- Send Login message


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


init : ( User, Cmd Msg )
init =
    -- () -> (No longer need unit flag as it's no longer an application but a component)
    ( initialModel, Cmd.none )



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
            let
                --trim the input fields and then ensure that these fields are valid
                trimmedUser =
                    { user | email = trimString user.email, password = trimString user.password }

                validatedUser =
                    { trimmedUser | emailError = validateEmail trimmedUser.email, passwordError = validatePassword trimmedUser.password }
            in
            if isLoginValid validatedUser then
                ( validatedUser, saveUser validatedUser )
                --Cmd.batch , Navigation.pushUrl (Url.toString Routes.Index) ] )
                --redirect to index page :)

            else
                ( validatedUser, Cmd.none )

        GotUser (Ok gotUser) ->
            ( { gotUser | signedUpOrloggedIn = True, password = "", errmsg = "" }, Cmd.none )
        
        GotUser (Err _) ->
            ( user, Cmd.none )
            



-- Error errormsg -> user


isLoginValid : User -> Bool
isLoginValid user =
    Maybe.withDefault "" user.emailError == "" && Maybe.withDefault "" user.passwordError == ""


-- subscriptions : User -> Sub Msg
-- subscriptions user =
--     Sub.none



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
            if user.signedUpOrloggedIn then
                --testing
                div [ id "greeting" ]
                    [ h3 [ class "text-center" ] [ text greeting ]
                    , p [ class "text-center" ] [ text "You have successfully logged in!" ]
                    ]

            else
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
                                    -- [ viewForm "text" "Your Name"
                                    -- , viewForm "text" "Email"
                                    -- , viewForm "password" "Password"
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

        -- div [ class "auth-page" ]
        --     [ div [ class "container page" ]
        --         [ div [ class "row" ]
        --             [ div [ class "col-md-6 col-md-offset-3 col-xs-12" ]
        --                 [ h1 [ class "text-xs-center" ] [ text "Log in" ]
        --                 , p [ class "text-xs-center" ] [ a [ href "authelm.html" ] [ text "Don't have an account?" ] ]
        --                 -- , div [ class showError ]
        --                 --     [ div [ class "alert alert-danger" ] [ text user.errmsg ]
        --                 --     ]
        --                 , form []
        --                     -- [ viewForm "text" "Your Name"
        --                     -- , viewForm "text" "Email"
        --                     -- , viewForm "password" "Password"
        --                     [ fieldset [ class "form-group" ] [ input [ class "form-control form-control-lg", type_ "email", placeholder "Email", onInput SaveEmail ] [] ]
        --                     , fieldset [ class "form-group" ] [ input [ class "form-control form-control-lg", type_ "password", placeholder "Password", onInput SavePassword ] [] ]
        --                     , button [ class "btn btn-lg btn-primary pull-xs-right", type_ "button", onClick Login ] [ text "Log In" ]
        --                     ]
        --                 ]
        --             ]
        --         ]
        --     ]
        , footer []
            [ div [ class "container" ]
                [ a [ Routes.href Routes.Index, class "logo-font" ] [ text "conduit" ]
                , text " " --helps make spacing perfect even though it's not exactly included in the og html version
                , span [ class "attribution" ]
                    [ text "An interactive learning project from "
                    , a [ href "https://thinkster.io/" ] [ text "Thinkster" ] --Routes. (external link)
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
    | GotUser (Result Http.Error User)



-- | StoreToken String
-- | Error String
-- main : Program () User Msg
-- main =
--     Browser.element
--         { init = init
--         , view = view
--         , update = update
--         , subscriptions = subscriptions
--         }
-- elm-live src/Login.elm --open --start-page=loginelm.html -- --output=login.js
