module Editor exposing (Article, Author, Model, Msg(..), articleDecoder, authorDecoder, init, initialModel, update, view)

import Html exposing (..)
import Html.Attributes exposing (class, href, placeholder, rows, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, bool, field, int, list, nullable, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Routes



-- Model --


type alias Author =
    -- inside article what we need to fetch
    { username : String
    , bio : Maybe String
    , image : Maybe String
    , following : Bool
    }


type alias Article =
    -- whole article
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
    }


type alias User =
    --all of these fields are contained in the response from the server
    { email : String
    , token : String
    , username : String
    , bio : Maybe String
    , image : Maybe String
    }


type alias Model =
    { user : User
    , article : Article
    , created : Bool
    , titleError : Maybe String
    , bodyError : Maybe String
    , descError : Maybe String
    , tagInput : String
    }


baseUrl : String
baseUrl =
    "http://localhost:8000/"


saveArticle : Model -> Cmd Msg
saveArticle model =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "article", encodeArticle <| model.article ) ]

        headers =
            [ Http.header "Authorization" ("Token " ++ model.user.token) ]
    in
    Http.request
        { method = "POST"
        , headers = headers
        , body = body
        , expect = Http.expectJson GotArticle (field "article" articleDecoder) -- wrap JSON received in GotArticle Msg
        , url = baseUrl ++ "api/articles"
        , timeout = Nothing
        , tracker = Nothing
        }


updateArticle : Model -> Cmd Msg
updateArticle model =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "article", encodeArticleUpdate <| model.article ) ]

        headers =
            [ Http.header "Authorization" ("Token " ++ model.user.token) ]
    in
    Http.request
        { method = "PUT"
        , headers = headers
        , body = body
        , expect = Http.expectJson GotArticle (field "article" articleDecoder) -- wrap JSON received in GotArticle Msg
        , url = baseUrl ++ "api/articles/" ++ model.article.slug
        , timeout = Nothing
        , tracker = Nothing
        }


encodeArticle : Article -> Encode.Value
encodeArticle article =
    -- used to encode Article sent to the server via Article request body (for creating)
    Encode.object
        [ ( "title", Encode.string article.title )
        , ( "description", Encode.string article.description )
        , ( "body", Encode.string article.body )
        , ( "tagList", Encode.list Encode.string article.tagList )
        ]


encodeArticleUpdate : Article -> Encode.Value
encodeArticleUpdate article =
    -- used to encode Article sent to the server via Article request body (for updating)
    -- does not include taglist for some reason according to their specs
    Encode.object
        [ ( "title", Encode.string article.title )
        , ( "description", Encode.string article.description )
        , ( "body", Encode.string article.body )
        ]


authorDecoder : Decoder Author
authorDecoder =
    succeed Author
        |> required "username" string
        |> required "bio" (nullable string)
        |> required "image" (nullable string)
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


defaultAuthor : Author
defaultAuthor =
    { username = ""
    , bio = Just ""
    , image = Just ""
    , following = False
    }


defaultUser : User
defaultUser =
    { email = ""
    , token = ""
    , username = ""
    , bio = Just ""
    , image = Just ""
    }


defaultArticle : Article
defaultArticle =
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
    }


initialModel : Model
initialModel =
    { user = defaultUser
    , article = defaultArticle
    , created = False
    , titleError = Just ""
    , bodyError = Just ""
    , descError = Just ""
    , tagInput = ""
    }


init : ( Model, Cmd Msg )
init =
    -- () -> (No longer need unit flag as it's no longer an application but a component)
    ( initialModel, Cmd.none )



-- Update --


type Msg
    = SaveTitle String
    | SaveDescription String
    | SaveBody String
    | SaveTags String
    | CreateArticle
    | GotArticle (Result Http.Error Article)
    | UpdateArticle


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


updateTitle : Article -> String -> Article
updateTitle article newTitle =
    { article | title = newTitle }


updateDescription : Article -> String -> Article
updateDescription article newDescription =
    { article | description = newDescription }


updateBody : Article -> String -> Article
updateBody article newBody =
    { article | body = newBody }


updateTags : Article -> List String -> Article
updateTags article newTags =
    { article | tagList = newTags }


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        SaveTitle title ->
            ( { model | article = updateTitle model.article title, titleError = validateTitle title }, Cmd.none )

        SaveDescription description ->
            ( { model | article = updateDescription model.article description, descError = validateTitle description }, Cmd.none )

        SaveBody body ->
            ( { model | article = updateBody model.article body, bodyError = validateBody body }, Cmd.none )

        SaveTags tagInput ->
            ( { model | tagInput = tagInput }, Cmd.none )

        CreateArticle ->
            let
                tags =
                    String.split "," model.tagInput
                        |> List.map String.trim

                validatedModel =
                    { model | titleError = validateTitle model.article.title, bodyError = validateBody model.article.body, descError = validateTitle model.article.description }
            in
            if isFormValid validatedModel then
                ( { validatedModel | article = updateTags model.article tags }, saveArticle validatedModel )

            else
                ( validatedModel, Cmd.none )

        GotArticle (Ok gotArticle) ->
            -- get the article and then change page to new article :)
            -- intercepted in main now :)
            ( { model | article = gotArticle }, Cmd.none )

        GotArticle (Err _) ->
            ( model, Cmd.none )

        UpdateArticle ->
            let
                validatedModel =
                    { model | titleError = validateTitle model.article.title, bodyError = validateBody model.article.body, descError = validateTitle model.article.description }
            in
            if isFormValid validatedModel then
                ( validatedModel, updateArticle validatedModel )

            else
                ( validatedModel, Cmd.none )


isFormValid : Model -> Bool
isFormValid model =
    Maybe.withDefault "" model.titleError == "" && Maybe.withDefault "" model.bodyError == "" && Maybe.withDefault "" model.descError == ""



-- Editor is now a component so this is not needed
-- subscriptions : Article -> Sub Msg
-- subscriptions article =
--     Sub.none
-- View --


view : Model -> Html Msg
view model =
    div []
        [ div [ class "editor-page" ]
            [ div [ class "container page" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-10 col-md-offset-1 col-xs-12" ]
                        [ form []
                            [ div [ style "color" "red" ] [ text (Maybe.withDefault "" model.titleError) ]
                            , fieldset [ class "form-group" ]
                                [ input [ class "form-control form-control-lg", type_ "text", placeholder "Article Title", onInput SaveTitle, value model.article.title ] [] ]
                            , div [ style "color" "red" ] [ text (Maybe.withDefault "" model.descError) ]
                            , fieldset [ class "form-group" ]
                                [ input [ class "form-control", type_ "text", placeholder "What's this article about?", onInput SaveDescription, value model.article.description ] [] ]
                            , div [ style "color" "red" ] [ text (Maybe.withDefault "" model.bodyError) ]
                            , fieldset [ class "form-group" ]
                                [ textarea [ class "form-control", rows 8, placeholder "Write your article (in markdown)", onInput SaveBody, value model.article.body ] [] ]
                            , fieldset [ class "form-group" ]
                                [ input [ class "form-control", type_ "text", placeholder "Enter tags", onInput SaveTags, value model.tagInput ] [] ]
                            , button
                                [ class "btn btn-lg btn-primary pull-xs-right"
                                , type_ "button"
                                , onClick
                                    (if model.article.slug == "default" then
                                        CreateArticle

                                     else
                                        UpdateArticle
                                    )
                                ]
                                [ text "Publish Article" ]
                            ]
                        ]
                    ]
                ]
            ]
        , footer []
            [ div [ class "container" ]
                [ a [ Routes.href (Routes.Index Routes.Global), class "logo-font" ] [ text "conduit" ]
                , text " " -- helps make spacing perfect even though it's not exactly included in the og html version
                , span [ class "attribution" ]
                    [ text "An interactive learning project from "
                    , a [ href "https://thinkster.io/" ] [ text "Thinkster" ] -- external link
                    , text ". Code & design licensed under MIT."
                    ]
                ]
            ]
        ]



-- Now editor is a component and no longer an application
-- main : Program () Article Msg
-- main =
--     Browser.element
--         { init = init
--         , view = view
--         , update = update
--         , subscriptions = subscriptions
--         }
