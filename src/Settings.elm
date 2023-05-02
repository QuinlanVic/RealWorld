module Settings exposing (UserSettings, main)

import Browser

import Html exposing (..)

import Html.Attributes exposing (class, href, placeholder, rows, type_)

import Exts.Html exposing (nbsp)
import Exts.Html.Bootstrap.Glyphicons exposing (Glyphicon(..))

--Model--
type alias UserSettings =
    { urlpic : String
    , name : String
    , bio : String
    , email : String
    , password : String
    , updated : Bool
    }

initialModel : UserSettings
initialModel =
    { urlpic = ""
    , name = ""
    , bio = ""
    , email = ""
    , password = ""
    , updated = False 
    }    
--Update--
update : Msg -> UserSettings -> UserSettings  
update message userset =
    case message of
        SavePic urlpic -> { userset | urlpic = urlpic }
        SaveName name -> { userset | name = name }
        SaveBio bio -> { userset | bio = bio }
        SaveEmail email -> { userset | email = email }
        SavePassword password -> {userset | password = password }
        UpdateSettings -> { userset | updated = True }

--View--
viewForm : String -> String -> Html msg
viewForm textType textHolder =
    fieldset [class "form-group"] 
        [input [class "form-control form-control-lg", type_ textType, placeholder textHolder] []
        ]

view : UserSettings -> Html msg
view user =
    div[]
    [ nav[class "navbar navbar-light"]
        [div [class "container"] 
            [ a [class "navbar-brand", href "indexelm.html"] [text "conduit"],
            ul [class "nav navbar-nav pull-xs-right"] --could make a function for doing all of this
                [ li [class "nav-item"] [a [class "nav-link", href "editorelm.html"] [i [class "ion-compose"][], text (nbsp ++ "New Post")]] --&nbsp; in Elm?
                , li [class "nav-item"] [a [class "nav-link", href "authelm.html"] [text "Sign up"]]
                , li [class "nav-item"] [a [class "nav-link", href "settingselm.html"] [text "Settings"]]
                -- <!--           <li class="nav-item active">
                --<a class="nav-link" href="index.html">Home</a>
                --</li> -->
                ]
            ]
        ]
    , div [class "settings-page"]
        [div [class "container page"] 
            [div [class "row"] 
                [div [class "col-md-6 col-md-offset-3 col-xs-12"] 
                    [ h1 [class "text-xs-center"] [text "Your Settings"]
                    , form [] 
                        [ fieldset [class "form-group"] 
                            [input [class "form-control", type_ "text", placeholder "URL of profile picture"] [] --<!--<input type="file" id="file"> -->
                            ]
                        , viewForm "text" "Your Name"
                        -- , fieldset [class "form-group"] 
                        --     [input [class "form-control form-control-lg", type_ "text", placeholder "Your Name"] []
                        --     ]
                        , fieldset [class "form-group"] 
                            [textarea [class "form-control form-control-lg", rows 8, placeholder "Short bio about you"] []
                            ]
                        , viewForm "text" "Email"
                        -- , fieldset [class "form-group"] 
                        --     [input [class "form-control form-control-lg", type_ "text", placeholder "Email"] []
                        --     ]
                        , viewForm "password" "Password"
                        -- , fieldset [class "form-group"]
                        --     [input [class "form-control form-control-lg", type_ "password", placeholder "Password"] []
                        --     ]
                        , button [class "btn btn-lg btn-primary pull-xs-right"] [text "Update Settings"]
                        ]
                    ]
                ]
            ]
        ]
    , footer []
        [ div [class "container"]
            [ a [href "/", class "logo-font"] [text "conduit"]
            , text nbsp --helps make spacing perfect even though it's not exactly included in the og html version
            , span [class "attribution"] 
                [ text "An interactive learning project from "
                , a [href "https:..thinkster.io"] [text "Thinkster"]
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

main : Html msg
main = 
    view initialModel


