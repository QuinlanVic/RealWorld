module Settings exposing (Msg, UserSettings, init, update, view)

-- import Exts.Html exposing (nbsp)
-- import Browser

import Auth exposing (User)
import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, rows, style, type_)
import Html.Events exposing (onClick, onInput)
import Routes



--Model--


type alias UserSettings =
    { urlpic : String
    , name : String
    , bio : String
    , email : String
    , password : String
    , updated : Bool
    , loggedOut : Bool
    }


initialModel : UserSettings
initialModel =
    { urlpic = ""
    , name = ""
    , bio = ""
    , email = ""
    , password = ""
    , updated = False
    , loggedOut = False
    }


init : ( UserSettings, Cmd Msg )
init =
    -- () -> (No longer need unit flag as it's no longer an application but a component)
    ( initialModel, Cmd.none )



-- fetchUser : Cmd Msg
-- fetchUser =
--     Http.get
--         { url = baseUrl ++ "api/users"
--         , expect = Http.expectJson LoadUser userDecoder -- wrap JSON received in LoadUser Msg
--         }
--Update--


update : Msg -> UserSettings -> ( UserSettings, Cmd Msg )
update message userset =
    case message of
        SavePic urlpic ->
            ( { userset | urlpic = urlpic }, Cmd.none )

        SaveName name ->
            ( { userset | name = name }, Cmd.none )

        SaveBio bio ->
            ( { userset | bio = bio }, Cmd.none )

        SaveEmail email ->
            ( { userset | email = email }, Cmd.none )

        SavePassword password ->
            ( { userset | password = password }, Cmd.none )

        UpdateSettings ->
            ( { userset | updated = True }, Cmd.none )

        LogOut ->
            ( { userset | loggedOut = True }, Cmd.none )


subscriptions : UserSettings -> Sub Msg
subscriptions userSettings =
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


view : UserSettings -> Html Msg
view user =
    div []
        [ div [ class "settings-page" ]
            [ div [ class "container page" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-6 col-md-offset-3 col-xs-12" ]
                        [ h1 [ class "text-xs-center" ] [ text "Your Settings" ]
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
                                    [ input [ class "form-control form-control-lg", type_ "password", placeholder "Password", onInput SavePassword ] []
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
    | LogOut



-- main : Program () UserSettings Msg
-- main =
--     Browser.element
--         { init = init
--         , view = view
--         , update = update
--         , subscriptions = subscriptions
--         }
--Now settings is a component and no longer an application
