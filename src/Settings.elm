module Settings exposing (Model, Msg, init, update, view)

-- import Exts.Html exposing (nbsp)
-- import Browser

import Auth exposing (initialModel, trimString, validateEmail, validatePassword, validateUsername)
import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, rows, type_)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, field, nullable, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Json.Encode as Encode
import Routes



--Model--


type alias User =
    { email : String --all of these fields are contained in the response from the server (besides last 3)
    , token : String
    , username : String
    , bio : Maybe String
    , image : Maybe String
    }


type alias Model =
    { user : User
    , password : String
    , signedUpOrloggedIn : Bool
    , errmsg : String
    , usernameError : Maybe String
    , emailError : Maybe String
    , passwordError : Maybe String
    }


defaultUser : User
defaultUser =
    { email = ""
    , token = ""
    , username = ""
    , bio = Just ""
    , image = Just ""
    }


initialModel : Model
initialModel =
    { user = defaultUser
    , password = ""
    , signedUpOrloggedIn = False
    , errmsg = ""
    , usernameError = Just ""
    , emailError = Just ""
    , passwordError = Just ""
    }


baseUrl : String
baseUrl =
    "http://localhost:8000/"


saveUser : Model -> Cmd Msg
saveUser model =
    --PUT/user
    let
        body =
            Http.jsonBody <| Encode.object [ ( "user", encodeUser <| model ) ]
    in
    Http.request
        { method = "PUT"
        , headers = []
        , body = body
        , expect = Http.expectJson GotUser (field "user" userDecoder) -- wrap JSON received in GotUser Msg
        , url = baseUrl ++ "api/user"
        , timeout = Nothing
        , tracker = Nothing
        }


getUser : User -> Cmd Msg
getUser user =
    --GET logged in user upon loadin
    let
        headers =
            [ Http.header "Authorization" ("Token " ++ user.token) ]
    in
    Http.request
        { method = "GET"
        , headers = headers
        , url = baseUrl ++ "api/user"
        , expect = Http.expectJson GotUser (field "user" userDecoder)
        , body = Http.emptyBody
        , timeout = Nothing
        , tracker = Nothing
        }


encodeMaybeString : Maybe String -> Encode.Value
encodeMaybeString maybeString =
    case maybeString of
        Just string ->
            Encode.string string

        Nothing ->
            Encode.null


encodeUser : Model -> Encode.Value
encodeUser model =
    --used to encode user sent to the server via PUT request body (for registering)
    Encode.object
        [ ( "email", Encode.string model.user.email )
        , ( "password", Encode.string model.password )
        , ( "username", Encode.string model.user.username )
        , ( "bio", encodeMaybeString model.user.bio )
        , ( "image", encodeMaybeString model.user.image )
        ]


userDecoder : Decoder User
userDecoder =
    succeed User
        |> required "email" string
        |> required "token" string
        |> required "username" string
        |> required "bio" (nullable string)
        |> required "image" (nullable string)


init : ( Model, Cmd Msg )
init =
    -- () -> (No longer need unit flag as it's no longer an application but a component)
    ( initialModel, Cmd.none )



-- fetchUser : Cmd Msg
-- fetchUser =
--     Http.get
--         { url = baseUrl ++ "api/users"
--         , expect = Http.expectJson GotUser userDecoder -- wrap JSON received in GotUser Msg
--         }
--Update--


type Msg
    = SavePic String
    | SaveName String
    | SaveBio String
    | SaveEmail String
    | SavePassword String
    | UpdateSettings
    | GotUser (Result Http.Error User)
    | LogOut


updateImage : User -> String -> User
updateImage user newImage =
    { user | image = Just newImage }


updateUsername : User -> String -> User
updateUsername user newUsername =
    { user | username = newUsername }


updateBio : User -> String -> User
updateBio user newBio =
    { user | bio = Just newBio }


updateEmail : User -> String -> User
updateEmail user newEmail =
    { user | email = newEmail }


trimUsernameAndEmail : User -> String -> String -> User
trimUsernameAndEmail user trimmedUsername trimmedEmail =
    { user | username = trimmedUsername, email = trimmedEmail }


isFormValid : Model -> Bool
isFormValid model =
    Maybe.withDefault "" model.usernameError == "" && Maybe.withDefault "" model.emailError == "" && Maybe.withDefault "" model.passwordError == ""


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        SavePic image ->
            ( { model | user = updateImage model.user image }, Cmd.none )

        SaveName username ->
            ( { model | user = updateUsername model.user username }, Cmd.none )

        SaveBio bio ->
            ( { model | user = updateBio model.user bio }, Cmd.none )

        SaveEmail email ->
            ( { model | user = updateEmail model.user email }, Cmd.none )

        SavePassword password ->
            ( { model | password = password }, Cmd.none )

        UpdateSettings ->
            let
                --trimString the input fields and then ensure that these fields are valid
                trimmedModel =
                    { model | user = trimUsernameAndEmail model.user (trimString model.user.username) (trimString model.user.email), password = trimString model.password }

                validatedModel =
                    { trimmedModel | usernameError = validateUsername trimmedModel.user.username, emailError = validateEmail trimmedModel.user.email, passwordError = validatePassword trimmedModel.password }
            in
            if isFormValid validatedModel then
                ( validatedModel, saveUser validatedModel )

            else
                ( validatedModel, Cmd.none )

        LogOut ->
            ( model, Cmd.none )

        GotUser (Ok gotUser) ->
            ( { model | user = gotUser, signedUpOrloggedIn = True, password = "", errmsg = "" }, Cmd.none )

        GotUser (Err _) ->
            ( model, Cmd.none )



-- subscriptions : User -> Sub Msg
-- subscriptions user =
--     Sub.none
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


maybeImageBio : Maybe String -> String
maybeImageBio maybeIB =
    case maybeIB of
        Just imagebio ->
            imagebio

        Nothing ->
            ""


view : Model -> Html Msg
view model =
    div []
        [ div [ class "settings-page" ]
            [ div [ class "container page" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-6 col-md-offset-3 col-xs-12" ]
                        [ h2 [ class "text-xs-center" ] [ text "Your Settings" ]
                        , form []
                            [ fieldset []
                                [ fieldset [ class "form-group" ]
                                    [ input [ class "form-control", type_ "text", placeholder "URL of profile picture", onInput SavePic ] [ text (maybeImageBio model.user.image) ]
                                    ]

                                -- , viewForm "text" "Your Name"
                                , fieldset [ class "form-group" ]
                                    [ input [ class "form-control form-control-lg", type_ "text", placeholder "Your Name", onInput SaveName ] [ text model.user.username ]
                                    ]
                                , fieldset [ class "form-group" ]
                                    [ textarea [ class "form-control form-control-lg", rows 8, placeholder "Short bio about you", onInput SaveBio ] [ text (maybeImageBio model.user.bio) ]
                                    ]

                                -- , viewForm "text" "Email"
                                , fieldset [ class "form-group" ]
                                    [ input [ class "form-control form-control-lg", type_ "text", placeholder "Email", onInput SaveEmail ] [ text model.user.email ]
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



-- main : Program () User Msg
-- main =
--     Browser.element
--         { init = init
--         , view = view
--         , update = update
--         , subscriptions = subscriptions
--         }
--Now settings is a component and no longer an application
