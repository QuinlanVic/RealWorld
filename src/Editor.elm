module Editor exposing (Article, Author, Msg, view, initialModel, articleDecoder, main)

-- import Exts.Html exposing (nbsp)

import Html exposing (..)

import Html.Attributes exposing (class, href, placeholder, rows, style, type_)
import Post exposing (Msg) 
import Html.Events exposing (onClick, onInput)

import Browser

import Http 

import Json.Decode exposing (Decoder, bool, field, int, list, null, string, succeed) 

import Json.Decode.Pipeline exposing (custom, hardcoded, required)  

import Json.Encode as Encode

-- Model --
type alias Author = --inside article 9what we need to fetch
    { username : String
    , bio : String
    , image : String
    , following : Bool
    }

type alias Article = --whole article
    { slug : String
    , title : String
    , description : String
    , body : String
    , tagList : List String 
    , createdAt : String 
    , updatedAt : String
    , favorited : Bool 
    , favoritesCount : Int
    , author : Author 
    , created : Bool 
    }
    

baseUrl : String
baseUrl = "http://localhost:3000/"    

saveArticle : Article -> Cmd Msg
saveArticle article = 
    let
        body =
            Http.jsonBody <| Encode.object [( "article", encodeArticle <| article) ]
    in 
    Http.post 
        { body = body  
        , expect = Http.expectJson LoadArticle (field "article" articleDecoder) -- wrap JSON received in LoadArtifcle Msg    
        , url = baseUrl ++ "api/articles"
        }

getArticleCompleted : Article -> Result Http.Error Article -> ( Article, Cmd Msg )
getArticleCompleted article result =
    case result of  
        Ok getArticle -> --confused here (return new model from the server with hardcoded password, errmsg and signedup values as those are not a part of the user record returned from the server?)
            (getArticle |> Debug.log "got the article", Cmd.none)    
        Err error ->
            (article, Cmd.none) 

encodeArticle : Article -> Encode.Value
encodeArticle article = --used to encode Article sent to the server via Article request body (for registering)
    Encode.object
        [ ( "title", Encode.string article.title ) 
        , ( "description", Encode.string article.description )
        , ( "body", Encode.string article.body )
        , ( "tagList", Encode.list Encode.string article.tagList )   
        ]

authorDecoder : Decoder Author
authorDecoder =
    succeed Author
        |> required "username" string
        |> required "bio" string
        |> required "image" string
        |> required "following" bool

articleDecoder : Decoder Article
articleDecoder = 
    succeed Article 
    |> required "slug" string
    |> required "title" string
    |> required "description" string
    |> required "body" string
    |> required "tagList" (list string)
    |> required "createdAt" string 
    |> required "updatedAt" string
    |> required "favorited" bool
    |> required "favoritesCount" int
    -- "author": {
    |> required "author" authorDecoder 
    |> hardcoded False 

defaultAuthor : Author
defaultAuthor =
    { username = ""
    , bio = ""
    , image = ""
    , following = False
    }

initialModel : Article 
initialModel =
    { slug = ""
    , title = ""
    , description = ""
    , body = ""
    , tagList = [""]
    , createdAt = ""
    , updatedAt = ""
    , favorited = False 
    , favoritesCount = 0
    , author = defaultAuthor 
    , created = False 
    }

init : () -> (Article, Cmd Msg)
init () =
    (initialModel, Cmd.none) 
    
-- Update --
update : Msg -> Article -> (Article, Cmd Msg)
update message article =
    case message of
        SaveTitle title -> ({ article | title = title }, Cmd.none) --update record syntax
        SaveDescription description -> ({article | description = description}, Cmd.none)
        SaveBody body -> ({ article | body = body }, Cmd.none)
        SaveTags tagList -> ({article | tagList = tagList }, Cmd.none)
        LoadArticle result -> getArticleCompleted article result 
        CreateArticle -> ({ article | created = True }, saveArticle article) 

subscriptions : Article -> Sub Msg
subscriptions article = 
    Sub.none 

-- View --
view : Article -> Html Msg 
view article =
    div []
        [ nav [ class "navbar navbar-light" ]
            [ div [ class "container" ]
                [ a [ class "navbar-brand", href "indexelm.html" ] [ text "conduit" ]
                , ul [ class "nav navbar-nav pull-xs-right" ]
                    --could make a function for doing all of this
                    [ li [class "nav-item"] [a [class "nav-link", href "indexelm.html"] [text "Home :)"]]
                    , li [ class "nav-item active" ] [ a [ class "nav-link", href "editorelm.html" ] [ i [ class "ion-compose" ] [], text (" " ++ "New Article") ] ] --&nbsp; in Elm?
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
                                [ input [ class "form-control form-control-lg", type_ "text", placeholder "Article Title", onInput SaveTitle ] [] ]
                            , fieldset [ class "form-group" ]
                                [ textarea [ class "form-control", rows 8, placeholder "Write your Article (in markdown)", onInput SaveBody ] [] ]
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
                            , button [ class "btn btn-lg btn-primary pull-xs-right", type_ "button", onClick CreateArticle ] [ text "Create Article" ]
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
    | LoadArticle (Result Http.Error Article )
    | CreateArticle

main : Program () Article Msg 
main =
     Browser.element
        { init = init
        , view = view
        , update = update 
        , subscriptions = subscriptions 
        }
