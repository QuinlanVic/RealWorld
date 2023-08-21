module Article exposing (Article, Comment, Comments, Model, Msg(..), articleDecoder, commentDecoder, init, initialModel, update, view)

import Html exposing (..)
import Html.Attributes exposing (class, disabled, href, id, placeholder, rows, src, style, type_, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode exposing (Decoder, bool, field, int, list, nullable, string, succeed)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode
import Routes



-- Model --


type alias Author =
    --inside article what we need to fetch
    { username : String
    , bio : Maybe String
    , image : Maybe String
    , following : Bool
    }


type alias User =
    --all of these fields are contained in the response from the server
    { email : String
    , token : String
    , username : String
    , bio : Maybe String
    , image : Maybe String
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
    }


type alias Comment =
    { id : Int
    , createdAt : String
    , updatedAt : String
    , body : String
    , author : Author
    }


type alias Comments =
    List Comment


type alias Model =
    { article : Article
    , comments : Maybe Comments
    , newComment : String
    , user : User
    }


defaultArticle : Article
defaultArticle =
    -- default stuff for testing at first and for if something breaks
    { slug = "slug1"
    , title = "How to build webapps that scale"
    , description = ""
    , body = ""
    , tagList = [ "" ]
    , createdAt = "January 20th"
    , updatedAt = "January 20th"
    , favorited = False
    , favoritesCount = 29
    , author = defaultAuthor
    }


defaultAuthor : Author
defaultAuthor =
    -- default stuff for testing at first and for if something breaks
    { username = "Eric Simons"
    , bio = Just ""
    , image = Just "http://i.imgur.com/Qr71crq.jpg"
    , following = False
    }


defaultUser : User
defaultUser =
    -- default stuff for testing at first and for if something breaks
    { email = ""
    , token = ""
    , username = ""
    , bio = Just ""
    , image = Just ""
    }


defaultComment : Comment
defaultComment =
    -- default stuff for testing at first and for if something breaks
    { id = 0
    , createdAt = "Dec 29th"
    , updatedAt = ""
    , body = "With supporting text below as a natural lead-in to additional content."
    , author = defaultAuthor
    }


initialModel : Model
initialModel =
    -- filled with default stuff for testing at first and for if something breaks
    { article = defaultArticle
    , comments = Just [ defaultComment ]
    , newComment = ""
    , user = defaultUser
    }


baseUrl : String
baseUrl =
    "http://localhost:8000/"


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


commentDecoder : Decoder Comment
commentDecoder =
    succeed Comment
        |> required "id" int
        |> required "createdAt" string
        |> required "updatedAt" string
        |> required "body" string
        |> required "author" authorDecoder


encodeArticle : Article -> Encode.Value
encodeArticle article =
    --used to encode Article slug sent to the server via request body
    Encode.object
        [ ( "slug", Encode.string article.slug ) ]


encodeComment : String -> Encode.Value
encodeComment comment =
    --used to encode comment sent to the server via request body
    Encode.object
        [ ( "body", Encode.string comment ) ]


encodeMaybeString : Maybe String -> Encode.Value
encodeMaybeString maybeString =
    -- image and bio can either be null or a string and we have to encode accordingly
    case maybeString of
        Just string ->
            Encode.string string

        Nothing ->
            Encode.null


encodeAuthor : Author -> Encode.Value
encodeAuthor author =
    -- used to encode author sent to the server
    Encode.object
        [ ( "username", Encode.string author.username )
        , ( "bio", encodeMaybeString author.bio )
        , ( "image", encodeMaybeString author.image )
        ]



-- SERVER CALLS


favoriteArticle : Model -> Article -> Cmd Msg
favoriteArticle model article =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "article", encodeArticle <| article ) ]

        headers =
            [ Http.header "Authorization" ("Token " ++ model.user.token) ]
    in
    Http.request
        { method = "POST"
        , headers = headers
        , body = body
        , expect = Http.expectJson GotArticle (field "article" articleDecoder)
        , url = baseUrl ++ "api/articles/" ++ article.slug ++ "/favorite"
        , timeout = Nothing
        , tracker = Nothing
        }


unfavoriteArticle : Model -> Article -> Cmd Msg
unfavoriteArticle model article =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "article", encodeArticle <| article ) ]

        headers =
            [ Http.header "Authorization" ("Token " ++ model.user.token) ]
    in
    Http.request
        { method = "DELETE"
        , headers = headers
        , body = body
        , expect = Http.expectJson GotArticle (field "article" articleDecoder)
        , url = baseUrl ++ "api/articles/" ++ article.slug ++ "/favorite"
        , timeout = Nothing
        , tracker = Nothing
        }


followUser : Model -> Author -> Cmd Msg
followUser model author =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "profile", encodeAuthor <| author ) ]

        headers =
            [ Http.header "Authorization" ("Token " ++ model.user.token) ]
    in
    Http.request
        { method = "POST"
        , headers = headers
        , body = body
        , expect = Http.expectJson GotAuthor (field "profile" authorDecoder)
        , url = baseUrl ++ "api/profiles/" ++ author.username ++ "/follow"
        , timeout = Nothing
        , tracker = Nothing
        }


unfollowUser : Model -> Author -> Cmd Msg
unfollowUser model author =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "profile", encodeAuthor <| author ) ]

        headers =
            [ Http.header "Authorization" ("Token " ++ model.user.token) ]
    in
    Http.request
        { method = "DELETE"
        , headers = headers
        , body = body
        , expect = Http.expectJson GotAuthor (field "profile" authorDecoder)
        , url = baseUrl ++ "api/profiles/" ++ author.username ++ "/follow"
        , timeout = Nothing
        , tracker = Nothing
        }



-- Done in main now I believe
-- editArticle : Article -> Cmd Msg
-- editArticle article =
--     --PUT/articles/slug
--     let
--         body =
--             Http.jsonBody <| Encode.object [ ( "article", encodeArticle <| article ) ]
--     in
--     Http.request
--         { method = "PUT"
--         , headers = []
--         , body = body
--         , expect = Http.expectJson GotArticle (field "article" articleDecoder) -- wrap JSON received in GotArticle Msg
--         , url = baseUrl ++ "api/articles" ++ article.slug
--         , timeout = Nothing
--         , tracker = Nothing
--         }


deleteArticle : Model -> Cmd Msg
deleteArticle model =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "article", encodeArticle <| model.article ) ]

        headers =
            [ Http.header "Authorization" ("Token " ++ model.user.token) ]
    in
    Http.request
        { method = "DELETE"
        , headers = headers
        , body = body
        , expect = Http.expectWhatever DeletedArticle
        , url = baseUrl ++ "api/articles/" ++ model.article.slug
        , timeout = Nothing
        , tracker = Nothing
        }



-- Now done in main :)
-- fetchArticle : Article -> Cmd Msg
-- fetchArticle article =
--     Http.get
--         { url = baseUrl ++ "api/articles/" ++ article.slug
--         , expect = Http.expectJson GotArticle (field "article" articleDecoder)
--         }


fetchComments : String -> Cmd Msg
fetchComments slug =
    Http.get
        { url = baseUrl ++ "api/articles/" ++ slug ++ "/comments"
        , expect = Http.expectJson GotComments (field "comments" (list commentDecoder))
        }


createComment : Model -> String -> Cmd Msg
createComment model comment =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "comment", encodeComment <| comment ) ]

        headers =
            [ Http.header "Authorization" ("Token " ++ model.user.token) ]
    in
    Http.request
        { method = "POST"
        , headers = headers
        , body = body
        , expect = Http.expectJson GotComment (field "comment" commentDecoder)
        , url = baseUrl ++ "api/articles/" ++ model.article.slug ++ "/comments"
        , timeout = Nothing
        , tracker = Nothing
        }


deleteComment : Model -> Int -> Cmd Msg
deleteComment model id =
    let
        headers =
            [ Http.header "Authorization" ("Token " ++ model.user.token) ]
    in
    Http.request
        { method = "DELETE"
        , headers = headers
        , body = Http.emptyBody
        , expect = Http.expectWhatever DeleteResponse
        , url = baseUrl ++ "api/articles/" ++ model.article.slug ++ "/comments/" ++ String.fromInt id
        , timeout = Nothing
        , tracker = Nothing
        }



-- END OF SERVER CALLS


init : ( Model, Cmd Msg )
init =
    -- () -> (No longer need unit flag as it's no longer an application but a component)
    -- get a specific article ( fetchArticle slug ) in Main and then
    -- fetch the comments for that article in main too
    ( initialModel, Cmd.none )



-- Update --


type Msg
    = ToggleLike
    | ToggleFollow
    | UpdateComment String
    | SaveComment String
    | DeleteComment Int
    | GotArticle (Result Http.Error Article)
    | GotAuthor (Result Http.Error Author)
      -- | EditArticle -- done in main now
    | DeleteArticle
    | GotComments (Result Http.Error Comments)
    | GotComment (Result Http.Error Comment)
    | DeleteResponse (Result Http.Error ())
    | FetchProfileArticle String
    | DeletedArticle (Result Http.Error ())


addComment : Comment -> Maybe Comments -> Maybe Comments
addComment newComment oldComments =
    -- add a new comment
    case oldComments of
        Just comments ->
            Just (List.append comments [ newComment ])

        Nothing ->
            Just [ newComment ]


checkNewComment : String -> Bool
checkNewComment newComment =
    let
        --remove trailing spaces from the comment
        comment =
            String.trim newComment
    in
    case comment of
        -- invalid comment as it is empty
        "" ->
            False

        -- add new comment
        _ ->
            True


updateAuthor : Article -> Author -> Article
updateAuthor article author =
    { article | author = author }


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        ToggleLike ->
            -- like and unlike article
            if model.article.favorited then
                ( model, unfavoriteArticle model model.article )

            else
                ( model, favoriteArticle model model.article )

        ToggleFollow ->
            -- follow and unfollow author
            if model.article.author.following then
                ( model, unfollowUser model model.article.author )

            else
                ( model, followUser model model.article.author )

        UpdateComment comment ->
            -- update the comment as the user types it :)
            ( { model | newComment = comment }, Cmd.none )

        SaveComment comment ->
            -- save a new comment
            if checkNewComment comment then
                ( model, createComment model comment )

            else
                -- if the new comment is empty then return the old model but reset the newComment field
                ( { model | newComment = "" }, Cmd.none )

        DeleteComment id ->
            -- pass the slug of the article and id of the comment to delete
            ( model, deleteComment model id )

        GotArticle (Ok article) ->
            -- we get an article from the server and update the model
            ( { model | article = article }, Cmd.none )

        GotArticle (Err _) ->
            ( model, Cmd.none )

        GotAuthor (Ok author) ->
            -- we get an author from the server and update the model
            ( { model | article = updateAuthor model.article author }, Cmd.none )

        GotAuthor (Err _) ->
            ( model, Cmd.none )

        -- done in main now :)
        -- EditArticle ->
        --     --send to Editor page with appropriate article information
        --     ( model, editArticle model.article )
        DeleteArticle ->
            --delete the article using API call AND THEN SEND BACK TO INDEX PAGE
            ( model, deleteArticle model )

        GotComments (Ok comments) ->
            -- got comments from the server and update the model
            ( { model | comments = Just comments }, Cmd.none )

        GotComments (Err _) ->
            ( model, Cmd.none )

        GotComment (Ok comment) ->
            -- add new comment and set newComment to empty
            ( { model | comments = addComment comment model.comments, newComment = "" }, Cmd.none )

        GotComment (Err _) ->
            -- return the same model but set newComment to empty
            ( { model | newComment = "" }, Cmd.none )

        DeleteResponse _ ->
            -- after you delete a comment, fetch the new set of comments whether it was successful or not
            ( model, fetchComments model.article.slug )

        FetchProfileArticle username ->
            ( model, Cmd.none )

        DeletedArticle _ ->
            -- this is intercepted in main to send back to Index page :)
            ( model, Cmd.none )



-- no longer needed as component?
-- subscriptions : Model -> Sub Msg
-- subscriptions model =
--     Sub.none
-- View --


viewFollowButton : Model -> Html Msg
viewFollowButton model =
    let
        buttonClass =
            if model.article.author.following then
                [ class "btn btn-sm btn-outline-secondary", style "background-color" "skyblue", style "color" "#fff", style "border-color" "black", type_ "button", onClick ToggleFollow ]

            else
                [ class "btn btn-sm btn-outline-secondary", type_ "button", onClick ToggleFollow ]
    in
    button buttonClass
        [ i [ class "ion-plus-round" ] []
        , text
            (" \u{00A0} "
                ++ (if model.article.author.following then
                        "Unfollow"

                    else
                        "Follow"
                   )
                ++ " "
                ++ model.article.author.username
                ++ " "
            )
        ]


viewLoveButton : Model -> Html Msg
viewLoveButton model =
    let
        buttonClass =
            if model.article.favorited then
                [ class "btn btn-sm btn-outline-primary", style "background-color" "#d00", style "color" "#fff", style "border-color" "black", type_ "button", onClick ToggleLike ]

            else
                [ class "btn btn-sm btn-outline-primary", type_ "button", onClick ToggleLike ]
    in
    button buttonClass
        [ i [ class "ion-heart" ] []
        , text
            (" \u{00A0} "
                ++ (if model.article.favorited then
                        "Unfavorite"

                    else
                        "Favorite"
                   )
                ++ " Post "
            )
        , span [ class "counter" ] [ text ("(" ++ String.fromInt model.article.favoritesCount ++ ")") ]
        ]


viewEditArticleButtons : String -> Html Msg
viewEditArticleButtons slug =
    -- show the buttons to edit/delete an article
    span [ class "ng-scope" ]
        [ a [ class "btn btn-outline-secondary btn-sm", Routes.href (Routes.Editor slug) ]
            [ i [ class "ion-edit" ] [], text " Edit Article " ]
        , text " "
        , button [ class "btn btn-outline-danger btn-sm", onClick DeleteArticle ]
            [ i [ class "ion-trash-a" ] [], text " Delete Article " ]
        ]


formatDate : String -> String
formatDate dateStr =
    case splitDate dateStr of
        Just ( year, month, day ) ->
            monthName month ++ " " ++ day ++ ", " ++ year

        Nothing ->
            "Invalid date"


splitDate : String -> Maybe ( String, String, String )
splitDate dateStr =
    let
        parts =
            String.split "-" dateStr
    in
    case parts of
        [ year, month, dayWithTime ] ->
            let
                day =
                    String.left 2 dayWithTime
            in
            Just ( year, month, day )

        _ ->
            Nothing


monthName : String -> String
monthName month =
    case month of
        "01" ->
            "January"

        "02" ->
            "February"

        "03" ->
            "March"

        "04" ->
            "April"

        "05" ->
            "May"

        "06" ->
            "June"

        "07" ->
            "July"

        "08" ->
            "August"

        "09" ->
            "September"

        "10" ->
            "October"

        "11" ->
            "November"

        "12" ->
            "December"

        _ ->
            "Invalid month"


maybeImageBio : Maybe String -> String
maybeImageBio maybeIB =
    case maybeIB of
        Just imagebio ->
            imagebio

        Nothing ->
            ""


viewComment : Model -> Comment -> Html Msg
viewComment model comment =
    --display a comment
    div [ class "card" ]
        [ div [ class "card-block" ]
            [ p [ class "card-text" ] [ text comment.body ]
            ]
        , div [ class "card-footer" ]
            [ a
                [ Routes.href (Routes.Profile comment.author.username Routes.WholeProfile)
                , onClick (FetchProfileArticle comment.author.username)
                , class "comment-author"
                ]
                [ img [ src (maybeImageBio comment.author.image), class "comment-author-img" ] [] ]
            , text " \u{00A0} "
            , a
                [ Routes.href (Routes.Profile comment.author.username Routes.WholeProfile)
                , onClick (FetchProfileArticle comment.author.username)
                , class "comment-author"
                ]
                [ text comment.author.username ]
            , text " "
            , span [ class "date-posted" ] [ text (formatDate comment.createdAt) ]
            , span [ class "mod-options" ]
                [ i
                    [ if model.user.username == comment.author.username then
                        class "ion-trash-a"

                      else
                        class ""
                    , onClick (DeleteComment comment.id)
                    ]
                    []
                ]
            ]
        ]


viewCommentList : Model -> Maybe Comments -> Html Msg
viewCommentList model maybeComments =
    --display a list of comments (if there are)
    case maybeComments of
        Just comments ->
            div []
                (List.map (viewComment model) comments)

        Nothing ->
            text ""


viewComments : Model -> Html Msg
viewComments model =
    --display all the comments and a place for adding a new comment
    div [ class "row" ]
        [ div [ class "col-md-8 col-md-offset-2" ]
            [ viewCommentList model model.comments
            , form [ class "card comment-form" ]
                [ div [ class "card-block" ]
                    [ textarea [ class "form-control", placeholder "Write a comment...", rows 3, value model.newComment, onInput UpdateComment ] [] ]
                , div [ class "card-footer" ]
                    [ img [ src (maybeImageBio model.user.image), class "comment-author-img" ] []
                    , button [ class "btn btn-sm btn-primary", disabled (String.isEmpty model.newComment), type_ "button", onClick (SaveComment model.newComment) ] [ text " Post Comment" ]
                    ]
                ]
            ]
        ]


viewArticle : Model -> Html Msg
viewArticle model =
    div [ class "container page" ]
        [ div [ class "row post-content" ]
            [ div [ class "col-md-12" ]
                [ div []
                    [ p [] [ text model.article.body ]

                    -- could add tags here?
                    ]
                ]
            ]
        , hr [] []
        , div [ class "post-actions" ]
            [ div [ class "post-meta" ]
                [ a
                    [ Routes.href (Routes.Profile model.article.author.username Routes.WholeProfile)

                    -- onClick (FetchProfileArticle model.author.username)
                    ]
                    [ img [ src (maybeImageBio model.article.author.image) ] [] ]
                , text " " --helps make spacing perfect even though it's not exactly included in the og html version
                , div [ class "info" ]
                    [ a
                        [ Routes.href (Routes.Profile model.article.author.username Routes.WholeProfile)

                        -- onClick (FetchProfileArticle model.author.username)
                        , class "author"
                        ]
                        [ text model.article.author.username ]
                    , span [ class "date" ] [ text (formatDate model.article.createdAt) ]
                    ]
                , text " " --helps make spacing perfect even though it's not exactly included in the og html version
                , if model.user.username == model.article.author.username then
                    viewEditArticleButtons model.article.slug

                  else
                    span []
                        [ viewFollowButton model
                        , text "\u{00A0}"
                        , viewLoveButton model
                        ]
                ]
            ]
        , viewComments model
        ]


view : Model -> Html Msg
view model =
    div []
        [ div [ class "post-page" ]
            [ div [ class "banner" ]
                [ div [ class "container" ]
                    [ h1 [] [ text model.article.title ]
                    , div [ class "post-meta" ]
                        [ a
                            [ Routes.href (Routes.Profile model.article.author.username Routes.WholeProfile)

                            -- onClick (FetchProfileArticle model.author.username)
                            ]
                            [ img [ src (maybeImageBio model.article.author.image) ] [] ]
                        , text " " --helps make spacing perfect even though it's not exactly included in the og html version
                        , div [ class "info" ]
                            [ a
                                [ Routes.href (Routes.Profile model.article.author.username Routes.WholeProfile)

                                -- onClick (FetchProfileArticle model.author.username)
                                , class "author"
                                ]
                                [ text model.article.author.username ]
                            , span [ class "date" ] [ text (formatDate model.article.createdAt) ]
                            ]
                        , text " " --helps make spacing perfect even though it's not exactly included in the og html version
                        , if model.user.username == model.article.author.username then
                            viewEditArticleButtons model.article.slug

                          else
                            span []
                                [ viewFollowButton model
                                , text "\u{00A0}"
                                , viewLoveButton model
                                ]
                        ]
                    ]
                ]
            , viewArticle model
            ]
        , footer []
            [ div [ class "container" ]
                [ a [ Routes.href Routes.Home {- (Routes.Index Routes.Global) -}, class "logo-font" ] [ text "conduit" ] -- gohome
                , text " " -- helps make spacing perfect even though it's not exactly included in the og html version
                , span [ class "attribution" ]
                    [ text "An interactive learning project from "
                    , a [ href "https://thinkster.io/" ] [ text "Thinkster" ] -- external link
                    , text ". Code & design licensed under MIT."
                    ]
                ]
            ]
        ]



--Now article is a component and no longer an application
-- main : Program () Model Msg
-- main =
--     -- view initialModel
--     Browser.element
--         { init = initialModel
--         , view = view
--         , update = update
--         , subscriptions = subscriptions
--         }
