module Editor exposing (main)

import Exts.Html exposing (nbsp)

import Html exposing (..)

import Html.Attributes exposing (class, href, placeholder, rows, style, type_)
import Post exposing (Msg)
import Html.Events exposing (onClick, onInput)

import Browser

-- Model --
type alias Post =
    { title : String
    , content : String
    , tags : List String 
    , created : Bool
    }

initialModel : Post 
initialModel =
    { title = ""
    , content = ""
    , tags = [""]
    , created = False 
    }
    
-- Update --
update : Msg -> Post -> Post 
update message post =
    case message of
        SaveTitle title -> { post | title = title } --update record syntax
        SaveContent content -> { post | content = content }
        SaveTags tags -> {post | tags = tags }
        CreatePost -> { post | created = True }

-- View --
view : Post -> Html Msg 
view post =
    div []
        [ nav [ class "navbar navbar-light" ]
            [ div [ class "container" ]
                [ a [ class "navbar-brand", href "indexelm.html" ] [ text "conduit" ]
                , ul [ class "nav navbar-nav pull-xs-right" ]
                    --could make a function for doing all of this
                    [ li [ class "nav-item" ] [ a [ class "nav-link", href "editorelm.html", style "color" "black" ] [ i [ class "ion-compose" ] [], text (nbsp ++ "New Post") ] ] --&nbsp; in Elm?
                    , li [class "nav-item"] [a [class "nav-link", href "loginelm.html"] [text "Log in"]]
                    , li [ class "nav-item" ] [ a [ class "nav-link", href "authelm.html" ] [ text "Sign up" ] ]
                    , li [ class "nav-item" ] [ a [ class "nav-link", href "settingselm.html" ] [ text "Settings" ] ]

                    -- <!--           <li class="nav-item active">
                    --<a class="nav-link" href="index.html">Home</a>
                    --</li> -->
                    ]
                ]
            ]
        , div [ class "editor-page" ]
            [ div [ class "container page" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-10 col-md-offset-1 col-xs-12" ]
                        [ form []
                            [ fieldset [ class "form-group" ]
                                [ input [ class "form-control form-control-lg", type_ "text", placeholder "Post Title", onInput SaveTitle ] [] ]
                            , fieldset [ class "form-group" ]
                                [ textarea [ class "form-control", rows 8, placeholder "Write your post (in markdown)", onInput SaveContent ] [] ]
                            , fieldset [ class "form-group" ]
                                [ input [ class "form-control", type_ "text", placeholder "Enter tags" ] [] --, onInput SaveTags (have to do it for a list of strings (split into strings to be passed into list))
                                , div [ class "tag-list" ]
                                    [ span [ class "label label-pill label-default" ] [ i [ class "ion-close-round" ] [], text " programming" ] --function
                                    , text nbsp
                                    , span [ class "label label-pill label-default" ] [ i [ class "ion-close-round" ] [], text " javascript" ]
                                    , text nbsp
                                    , span [ class "label label-pill label-default" ] [ i [ class "ion-close-round" ] [], text " webdev" ]
                                    ]
                                ]
                            , button [ class "btn btn-lg btn-primary pull-xs-right", onClick CreatePost ] [ text "Create Post" ]
                            ]
                        ]
                    ]
                ]
            ]
        , footer []
            [ div [ class "container" ]
                [ a [ href "/", class "logo-font" ] [ text "conduit" ]
                , text nbsp --helps make spacing perfect even though it's not exactly included in the og html version
                , span [ class "attribution" ]
                    [ text "An interactive learning project from "
                    , a [ href "https:..thinkster.io" ] [ text "Thinkster" ]
                    , text ". Code & design licensed under MIT."
                    ]
                ]
            ]
        ]
type Msg 
    = SaveTitle String 
    | SaveContent String 
    | SaveTags (List String)
    | CreatePost

main : Program () Post Msg 
main =
     Browser.sandbox
        { init = initialModel
        , view = view
        , update = update 
        }
