module Editor exposing (main)

-- import Exts.Html exposing (nbsp)

import Html exposing (..)

import Html.Attributes exposing (class, href, placeholder, rows, style, type_)
import Post exposing (Msg)
import Html.Events exposing (onClick, onInput)

import Browser

import Http 

import Json.Decode exposing (Decoder, bool, int, list, string, succeed) 

import Json.Decode.Pipeline exposing (hardcoded, required)  

import Json.Encode as Encode

import Json.Decode exposing (null)
import Platform.Cmd as Cmd


-- Model --
type alias Post =
    { title : String
    , description : String --?
    , body : String
    , tagList : List String 
    , created : Bool
    }

type alias Post2 =
    { slug : String
    , title : String
    , description : String
    , body : String
    , tagList : List String 
    , createdAt : String 
    , updatedAt : String
    , favorited : Bool 
    , favoritesCount : Int
    -- "author": {
    , username : String
    , bio : String
    , image : String
    , following : Bool
    }
    

baseUrl : String
baseUrl = "http://localhost:8010/proxy/"    

savePost : Post -> Cmd Msg
savePost user = 
    let
        body =
            Http.jsonBody <| encodePost <| user       
    in 
    Http.post
        { body = body 
        , expect = Http.expectJson LoadArticle (postDecoder) -- wrap JSON received in LoadUser Msg    
        , url = baseUrl ++ "api/users"
        }

getPostCompleted : Post -> Result Http.Error Post -> ( Post, Cmd Msg )
getPostCompleted post result =
    case result of  
        Ok getPost -> --confused here (return new model from the server with hardcoded password, errmsg and signedup values as those are not a part of the user record returned from the server?)
            (getPost |> Debug.log "got the post", Cmd.none)   
        Err error ->
            (post, Cmd.none) 

encodePost : Post -> Encode.Value
encodePost post = --used to encode user sent to the server via POST request body (for registering)
    Encode.object
        [ ( "title", Encode.string post.title ) 
        , ( "description", Encode.string post.description )
        , ( "body", Encode.string post.body )
        , ( "tagList", Encode.list Encode.string post.tagList )   
        ]

postDecoder : Decoder Post2
postDecoder = 
    succeed Post2 
    |> required "slug" string
    |> required "title" string
    |> required "description" string
    |> required "body" string
    |> required "tagList" list string  
    |> required "createdAt" string 
    |> required "updatedAt" string
    |> required "favorited" bool
    |> required "favoritesCount" int
    -- "author": {
    |> required "username" string
    |> required "bio" string
    |> required "image" string
    |> required "following" bool

initialModel : Post 
initialModel =
    { title = ""
    , description = ""
    , body = ""
    , tagList = [""]
    , created = False 
    }

init : () -> (Post, Cmd Msg)
init () =
    (initialModel, Cmd.none) 
    
-- Update --
update : Msg -> Post -> (Post, Cmd Msg)
update message post =
    case message of
        SaveTitle title -> ({ post | title = title }, Cmd.none) --update record syntax
        SaveDescription description -> ({post | description = description}, Cmd.none)
        SaveBody body -> ({ post | body = body }, Cmd.none)
        SaveTags tagList -> ({post | tagList = tagList }, Cmd.none)
        LoadArticle result -> getPostCompleted post result 
        CreatePost -> ({ post | created = True }, savePost post) 

subscriptions : Post -> Sub Msg
subscriptions post = 
    Sub.none 

-- View --
view : Post -> Html Msg 
view post =
    div []
        [ nav [ class "navbar navbar-light" ]
            [ div [ class "container" ]
                [ a [ class "navbar-brand", href "indexelm.html" ] [ text "conduit" ]
                , ul [ class "nav navbar-nav pull-xs-right" ]
                    --could make a function for doing all of this
                    [ li [class "nav-item"] [a [class "nav-link", href "indexelm.html"] [text "Home :)"]]
                    , li [ class "nav-item active" ] [ a [ class "nav-link", href "editorelm.html" ] [ i [ class "ion-compose" ] [], text (" " ++ "New Post") ] ] --&nbsp; in Elm?
                    , li [class "nav-item"] [a [class "nav-link", href "loginelm.html"] [text "Log in"]]
                    , li [ class "nav-item" ] [ a [ class "nav-link", href "authelm.html" ] [ text "Sign up" ] ]
                    , li [ class "nav-item" ] [ a [ class "nav-link", href "settingselm.html" ] [ text "Settings" ] ]
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
                                [ textarea [ class "form-control", rows 8, placeholder "Write your post (in markdown)", onInput SaveBody ] [] ]
                            , fieldset [ class "form-group" ]
                                [ input [ class "form-control", type_ "text", placeholder "Enter tagList" ] [] --, onInput SaveTags (have to do it for a list of strings (split into strings to be passed into list))
                                , div [ class "tag-list" ]
                                    [ span [ class "label label-pill label-default" ] [ i [ class "ion-close-round" ] [], text " programming" ] --function
                                    , text " "
                                    , span [ class "label label-pill label-default" ] [ i [ class "ion-close-round" ] [], text " javascript" ]
                                    , text " "
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
                , text " " --helps make spacing perfect even though it's not exactly included in the og html version
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
    | SaveDescription String 
    | SaveBody String 
    | SaveTags (List String)
    | LoadArticle (Result Http.Error Post2 )
    | CreatePost

main : Program () Post Msg 
main =
     Browser.element
        { init = init
        , view = view
        , update = update 
        , subscriptions = subscriptions 
        }
