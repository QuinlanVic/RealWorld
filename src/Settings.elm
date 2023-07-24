module Settings exposing (Msg, init, update, view)

-- import Exts.Html exposing (nbsp)
-- import Browser

import Auth exposing (User, initialModel, isFormValid, trimString, validateEmail, validatePassword, validateUsername)
import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, rows, style, type_)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, nullable, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Json.Encode as Encode
import Routes
import String exposing (replace)



--Model--


baseUrl : String
baseUrl =
    "http://localhost:8000/"


saveUser : User -> Cmd Msg
saveUser user =
    --PUT/user
    let
        body =
            Http.jsonBody <| Encode.object [ ( "user", encodeUser <| user ) ]
    in
    Http.request
        { method = "PUT"
        , headers = []
        , body = body
        , expect = Http.expectJson LoadUser (field "user" userDecoder) -- wrap JSON received in LoadUser Msg
        , url = baseUrl ++ "api/user"
        , timeout = Nothing
        , tracker = Nothing
        }


getUser : Cmd Msg
getUser =
    --GET logged in user upon loadin
    Http.get
        { url = baseUrl ++ "api/user"
        , expect = Http.expectJson LoadUser (field "user" userDecoder)
        }


getUserCompleted : User -> Result Http.Error User -> ( User, Cmd Msg )
getUserCompleted user result =
    case result of
        Ok gotUser ->
            --confused here (return new model from the server with hardcoded password, errmsg and signedup values as those are not a part of the user record returned from the server?)
            ( { gotUser | signedUpOrloggedIn = True, password = "", errmsg = "" }, Cmd.none )

        Err error ->
            ( { user | errmsg = Debug.toString error }, Cmd.none )


encodeMaybeString : Maybe String -> Encode.Value
encodeMaybeString maybeString =
    case maybeString of
        Just string ->
            Encode.string string

        Nothing ->
            Encode.null


encodeUser : User -> Encode.Value
encodeUser user =
    --used to encode user sent to the server via PUT request body (for registering)
    Encode.object
        [ ( "email", Encode.string user.email )
        , ( "password", Encode.string user.password )
        , ( "username", Encode.string user.username )
        , ( "bio", encodeMaybeString user.bio )
        , ( "image", encodeMaybeString user.image )
        ]


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


init : ( User, Cmd Msg )
init =
    -- () -> (No longer need unit flag as it's no longer an application but a component)
    ( initialModel, getUser )



-- fetchUser : Cmd Msg
-- fetchUser =
--     Http.get
--         { url = baseUrl ++ "api/users"
--         , expect = Http.expectJson LoadUser userDecoder -- wrap JSON received in LoadUser Msg
--         }
--Update--


update : Msg -> User -> ( User, Cmd Msg )
update message user =
    case message of
        SavePic image ->
            ( { user | image = Just image }, Cmd.none )

        SaveName username ->
            ( { user | username = username }, Cmd.none )

        SaveBio bio ->
            ( { user | bio = Just bio }, Cmd.none )

        SaveEmail email ->
            ( { user | email = email }, Cmd.none )

        SavePassword password ->
            ( { user | password = password }, Cmd.none )

        UpdateSettings ->
            let
                --trimString the input fields and then ensure that these fields are valid
                trimmedUser =
                    { user | username = trimString user.username, email = trimString user.email, password = trimString user.password }

                validatedUser =
                    { trimmedUser | usernameError = validateUsername trimmedUser.username, emailError = validateEmail trimmedUser.email, passwordError = validatePassword trimmedUser.password }
            in
            if isFormValid validatedUser then
                ( validatedUser, saveUser validatedUser )

            else
                ( validatedUser, Cmd.none )

        LogOut ->
            ( user, Cmd.none )

        LoadUser result ->
            getUserCompleted user result


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
--         [input [class "form-control form-control-lg", type_ textType, placeholder textHolder] []
--         ]
-- #373a3c


view : User -> Html Msg
view user =
    div []
        [ div [ class "settings-page" ]
            [ div [ class "container page" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-6 col-md-offset-3 col-xs-12" ]
                        [ h2 [ class "text-xs-center" ] [ text "Your Settings" ]
                        , form []
                            [ fieldset []
                                [ fieldset [ class "form-group" ]
                                    [ input [ class "form-control", type_ "text", placeholder "URL of profile picture", onInput SavePic ] [] --<!--<input type="file" id="file"> -->
                                    ]

                                -- , viewForm "text" "Your Name"
                                , fieldset [ class "form-group" ]
                                    [ input [ class "form-control form-control-lg", type_ "text", placeholder "Your Name", onInput SaveName ] []
                                    ]
                                , fieldset [ class "form-group" ]
                                    [ textarea [ class "form-control form-control-lg", rows 8, placeholder "Short bio about you", onInput SaveBio ] []
                                    ]

                                -- , viewForm "text" "Email"
                                , fieldset [ class "form-group" ]
                                    [ input [ class "form-control form-control-lg", type_ "text", placeholder "Email", onInput SaveEmail ] []
                                    ]

                                -- , viewForm "password" "Password"
                                , fieldset [ class "form-group" ]
                                    [ input [ class "form-control form-control-lg", type_ "password", placeholder "New Password", onInput SavePassword ] []
                                    ]
                                , button [ class "btn btn-lg btn-primary pull-xs-right", type_ "button", onClick UpdateSettings ] [ text "Update Settings" ]
                                ]
                            , hr [] []
                            , button [ class "btn btn-outline-danger", type_ "button", onClick LogOut ] [ text "Or click here to logout." ] --needs to be inside form for events to work!
                            ]
                        ]
                    ]
                ]
            ]
        , footer []
            [ div [ class "container" ]
                [ a [ Routes.href Routes.Index, class "logo-font" ] [ text "conduit" ]
                , text " " --helps make spacing perfect even though it's not exactly included in the og html version
                , span [ class "attribution" ]
                    [ text "An interactive learning project from "
                    , a [ href "https://thinkster.io/" ] [ text "Thinkster" ] --external link
                    , text ". Code & design licensed under MIT."
                    ]
                ]
            ]
        ]


type Msg
    = SavePic String
    | SaveName String
    | SaveBio String
    | SaveEmail String
    | SavePassword String
    | UpdateSettings
    | LoadUser (Result Http.Error User)
    | LogOut



-- main : Program () User Msg
-- main =
--     Browser.element
--         { init = init
--         , view = view
--         , update = update
--         , subscriptions = subscriptions
--         }
--Now settings is a component and no longer an application
