module Editor exposing (Article, Author, Msg, articleDecoder, authorDecoder, init, initialModel, update, view)

-- import Exts.Html exposing (nbsp)
-- import Browser

import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, rows, style, type_)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, bool, field, int, list, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, required)
import Json.Encode as Encode
import Routes



-- Model --


type alias Author =
    --inside article what we need to fetch
    { username : String
    , bio : String
    , image : String
    , following : Bool
    }


type alias Article =
    --whole article
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
    , titleError : Maybe String
    , bodyError : Maybe String
    , descError : Maybe String
    }


baseUrl : String
baseUrl =
    "http://localhost:8000/"


saveArticle : Article -> Cmd Msg
saveArticle article =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "article", encodeArticle <| article ) ]

        -- headers =
        --     [ Http.header "Authorization" ("Token " ++ model.user.token) ]
    in
    Http.request
        { method = "POST"
        , headers = []
        , body = body
        , expect = Http.expectJson LoadArticle (field "article" articleDecoder) -- wrap JSON received in LoadArtifcle Msg
        , url = baseUrl ++ "api/articles"
        , timeout = Nothing
        , tracker = Nothing
        }


encodeArticle : Article -> Encode.Value
encodeArticle article =
    --used to encode Article sent to the server via Article request body (for registering)
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
        |> hardcoded (Just "")
        |> hardcoded (Just "")
        |> hardcoded (Just "")


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
    , tagList = [ "" ]
    , createdAt = ""
    , updatedAt = ""
    , favorited = False
    , favoritesCount = 0
    , author = defaultAuthor
    , created = False
    , titleError = Just ""
    , bodyError = Just ""
    , descError = Just ""
    }


init : ( Article, Cmd Msg )
init =
    -- () -> (No longer need unit flag as it's no longer an application but a component)
    ( initialModel, Cmd.none )



-- Update --


type Msg
    = SaveTitle String --maybe string
    | SaveDescription String
    | SaveBody String
    | SaveTags (List String)
    | CreateArticle
    | LoadArticle (Result Http.Error Article)


validateTitle : String -> Maybe String
validateTitle input =
    if String.isEmpty input then
        Just "Input is required"

    else
        Nothing


validateBody : String -> Maybe String
validateBody input =
    if String.isEmpty input then
        Just "Input is required"

    else if String.length input < 500 then
        Just "Article has to be at least 500 characters long"

    else
        Nothing


update : Msg -> Article -> ( Article, Cmd Msg )
update message article =
    case message of
        SaveTitle title ->
            ( { article | title = title, titleError = validateTitle title }, Cmd.none )

        --update record syntax
        SaveDescription description ->
            ( { article | description = description, descError = validateTitle description }, Cmd.none )

        SaveBody body ->
            ( { article | body = body, bodyError = validateBody body }, Cmd.none )

        SaveTags tagList ->
            ( { article | tagList = tagList }, Cmd.none )

        CreateArticle ->
            let
                validatedArticle =
                    { article | titleError = validateTitle article.title, bodyError = validateBody article.body, descError = validateTitle article.description }
            in
            if isFormValid validatedArticle then
                ( validatedArticle, saveArticle validatedArticle )

            else
                ( validatedArticle, Cmd.none )

        LoadArticle (Ok gotArticle) ->
            -- get the article and then change page to new article :)
            ( gotArticle, Cmd.none )

        LoadArticle (Err _) ->
            ( article, Cmd.none )


isFormValid : Article -> Bool
isFormValid article =
    Maybe.withDefault "" article.titleError == "" && Maybe.withDefault "" article.bodyError == "" && Maybe.withDefault "" article.descError == ""



-- subscriptions : Article -> Sub Msg
-- subscriptions article =
--     Sub.none
-- View --


view : Article -> Html Msg
view article =
    div []
        [ div [ class "editor-page" ]
            [ div [ class "container page" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-10 col-md-offset-1 col-xs-12" ]
                        [ form []
                            [ div [ style "color" "red" ] [ text (Maybe.withDefault "" article.titleError) ]
                            , fieldset [ class "form-group" ]
                                [ input [ class "form-control form-control-lg", type_ "text", placeholder "Article Title", onInput SaveTitle ] [] ]
                            , div [ style "color" "red" ] [ text (Maybe.withDefault "" article.descError) ]
                            , fieldset [ class "form-group" ]
                                [ input [ class "form-control", type_ "text", placeholder "What's this article about?", onInput SaveDescription ] [] ]
                            , div [ style "color" "red" ] [ text (Maybe.withDefault "" article.bodyError) ]
                            , fieldset [ class "form-group" ]
                                [ textarea [ class "form-control", rows 8, placeholder "Write your article (in markdown)", onInput SaveBody ] [] ]
                            , fieldset [ class "form-group" ]
                                [ input [ class "form-control", type_ "text", placeholder "Enter tags" ] [] --, onInput SaveTags (have to do it for a list of strings (split into strings to be passed into list))

                                -- , div [ class "tag-list" ]
                                --     [ span [ class "label label-pill label-default" ] [ i [ class "ion-close-round" ] [], text " programming" ] --function
                                --     , text " "
                                --     , span [ class "label label-pill label-default" ] [ i [ class "ion-close-round" ] [], text " javascript" ]
                                --     , text " "
                                --     , span [ class "label label-pill label-default" ] [ i [ class "ion-close-round" ] [], text " webdev" ]
                                --     ]
                                ]
                            , button [ class "btn btn-lg btn-primary pull-xs-right", type_ "button", onClick CreateArticle ] [ text "Publish Article" ]
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



-- main : Program () Article Msg
-- main =
--     Browser.element
--         { init = init
--         , view = view
--         , update = update
--         , subscriptions = subscriptions
--         }
--Now editor is a component and no longer an application
