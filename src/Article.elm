module Article exposing (Article, Model, Msg(..), articleDecoder, commentDecoder, init, initialModel, update, view)

-- import Browser

import Html exposing (..)
import Html.Attributes exposing (class, disabled, href, id, placeholder, rows, src, style, target, type_, value)
import Html.Events exposing (onClick, onInput, onSubmit)
import Http
import Json.Decode exposing (Decoder, bool, field, int, list, nullable, string, succeed)
import Json.Decode.Pipeline exposing (hardcoded, required)
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

    -- , comments : List String
    -- , newComment : String
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
    , author : Author
    , comments : Maybe Comments
    , newComment : String
    }


defaultArticle : Article
defaultArticle =
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

    -- , comments = [ "With supporting text below as a natural lead-in to additional content." ]
    -- , newComment = ""
    }


defaultAuthor : Author
defaultAuthor =
    { username = "Eric Simons"
    , bio = Just ""
    , image = Just "http://i.imgur.com/Qr71crq.jpg"
    , following = False
    }


defaultComment : Comment
defaultComment =
    { id = 0
    , createdAt = "Dec 29th"
    , updatedAt = ""
    , body = "With supporting text below as a natural lead-in to additional content."
    , author = defaultAuthor
    }


initialModel : Model
initialModel =
    { article = defaultArticle
    , author = defaultAuthor
    , comments = Just [ defaultComment ]
    , newComment = ""
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
    case maybeString of
        Just string ->
            Encode.string string

        Nothing ->
            Encode.null


encodeAuthor : Author -> Encode.Value
encodeAuthor author =
    --used to encode user sent to the server via PUT request body (for registering)
    Encode.object
        [ ( "username", Encode.string author.username )
        , ( "bio", encodeMaybeString author.bio )
        , ( "image", encodeMaybeString author.image )
        ]



-- SERVER CALLS


favoriteArticle : Article -> Cmd Msg
favoriteArticle article =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "article", encodeArticle <| article ) ]
    in
    Http.post
        { body = body -- do not need a body but send it anyway?
        , expect = Http.expectJson GotArticle (field "article" articleDecoder)
        , url = baseUrl ++ "api/articles/" ++ article.slug ++ "/favorite"
        }


unfavoriteArticle : Article -> Cmd Msg
unfavoriteArticle article =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "article", encodeArticle <| article ) ]
    in
    Http.request
        { method = "DELETE"
        , headers = []
        , body = body
        , expect = Http.expectJson GotArticle (field "article" articleDecoder)
        , url = baseUrl ++ "api/articles/" ++ article.slug ++ "/favorite"
        , timeout = Nothing
        , tracker = Nothing
        }


followUser : Author -> Cmd Msg
followUser author =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "profile", encodeAuthor <| author ) ]
    in
    Http.post
        { body = body
        , expect = Http.expectJson GotAuthor (field "profile" authorDecoder)
        , url = baseUrl ++ "api/profiles/" ++ author.username ++ "/follow"
        }


unfollowUser : Author -> Cmd Msg
unfollowUser author =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "article", encodeAuthor <| author ) ]
    in
    Http.request
        { method = "DELETE"
        , headers = []
        , body = body
        , expect = Http.expectJson GotAuthor (field "author" authorDecoder)
        , url = baseUrl ++ "api/profiles/" ++ author.username ++ "/follow"
        , timeout = Nothing
        , tracker = Nothing
        }


editArticle : Article -> Cmd Msg
editArticle article =
    --PUT/articles/slug
    let
        body =
            Http.jsonBody <| Encode.object [ ( "article", encodeArticle <| article ) ]
    in
    Http.request
        { method = "PUT"
        , headers = []
        , body = body
        , expect = Http.expectJson GotArticle (field "article" articleDecoder) -- wrap JSON received in GotArticle Msg
        , url = baseUrl ++ "api/articles" ++ article.slug
        , timeout = Nothing
        , tracker = Nothing
        }


deleteArticle : Article -> Cmd Msg
deleteArticle article =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "article", encodeArticle <| article ) ]
    in
    Http.request
        { method = "DELETE"
        , headers = []
        , body = body
        , expect = Http.expectJson GotArticle (field "article" articleDecoder)
        , url = baseUrl ++ "api/articles/" ++ article.slug
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


createComment : String -> String -> Cmd Msg
createComment slug comment =
    let
        body =
            Http.jsonBody <| Encode.object [ ( "comment", encodeComment <| comment ) ]
    in
    Http.post
        { body = body
        , expect = Http.expectJson GotComment (field "comment" commentDecoder)
        , url = baseUrl ++ "api/articles/" ++ slug ++ "/comments"
        }


deleteComment : String -> Int -> Cmd Msg
deleteComment slug id =
    Http.request
        { method = "DELETE"
        , headers = []
        , body = Http.emptyBody
        , expect = Http.expectWhatever DeleteResponse
        , url = baseUrl ++ "api/articles/" ++ slug ++ "/comments" ++ String.fromInt id
        , timeout = Nothing
        , tracker = Nothing
        }



-- END OF SERVER CALLS


init : ( Model, Cmd Msg )
init =
    -- () -> (No longer need unit flag as it's no longer an application but a component)
    -- get a specific article ( fetchArticle slug ) in Main and then
    -- fetch the comments for that article here
    ( initialModel, fetchComments initialModel.article.slug )



-- Update --


type Msg
    = ToggleLike
    | ToggleFollow
    | UpdateComment String
    | SaveComment String
    | DeleteComment Int
    | GotArticle (Result Http.Error Article)
    | GotAuthor (Result Http.Error Author)
    | EditArticle
    | DeleteArticle
    | GotComments (Result Http.Error Comments)
    | GotComment (Result Http.Error Comment)
    | DeleteResponse (Result Http.Error ())
    | FetchProfileArticle String


addComment : Comment -> Maybe Comments -> Maybe Comments
addComment newComment oldComments =
    case oldComments of
        Just comments ->
            Just (List.append comments [ newComment ])

        Nothing ->
            Just [ newComment ]


checkNewComment : String -> Bool
checkNewComment newComment =
    let
        comment =
            String.trim newComment

        --remove trailing spaces from the comment
    in
    case comment of
        "" ->
            -- invalid comment as it is empty
            False

        _ ->
            -- add new comment
            True


toggleLike : Article -> Article
toggleLike article =
    -- favoritesCount should update automatically when the server returns the new Article!!!!
    if article.favorited then
        -- favoritesCount = article.favoritesCount - 1
        { article | favorited = not article.favorited }

    else
        -- , favoritesCount = article.favoritesCount + 1
        { article | favorited = not article.favorited }


toggleFollow : Author -> Author
toggleFollow author =
    if author.following then
        { author | following = not author.following }

    else
        { author | following = not author.following }


updateArticle : (Article -> Article) -> Article -> Article
updateArticle makeChanges article =
    --only one article so we do not have to worry about getting a specific one :)
    makeChanges article


updateAuthor : (Author -> Author) -> Author -> Author
updateAuthor makeChanges author =
    makeChanges author


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        ToggleLike ->
            if model.article.favorited then
                ( { model | article = updateArticle toggleLike model.article }, favoriteArticle model.article )

            else
                ( { model | article = updateArticle toggleLike model.article }, unfavoriteArticle model.article )

        ToggleFollow ->
            if model.author.following then
                ( { model | author = updateAuthor toggleFollow model.author }, followUser model.author )

            else
                ( { model | author = updateAuthor toggleFollow model.author }, unfollowUser model.author )

        UpdateComment comment ->
            -- update the comment as the user types it :)
            ( { model | newComment = comment }, Cmd.none )

        SaveComment comment ->
            if checkNewComment comment then
                ( model, createComment model.article.slug comment )

            else
                -- if the new comment is empty then return the old model but reset the newComment field
                ( { model | newComment = "" }, Cmd.none )

        DeleteComment id ->
            -- pass the slug of the article and id of the comment to delete
            ( model, deleteComment model.article.slug id )

        GotArticle (Ok article) ->
            ( { model | article = article }, Cmd.none )

        GotArticle (Err _) ->
            ( model, Cmd.none )

        GotAuthor (Ok author) ->
            ( { model | author = author }, Cmd.none )

        GotAuthor (Err _) ->
            ( model, Cmd.none )

        EditArticle ->
            --send to Editor page with appropriate article information
            ( model, editArticle model.article )

        DeleteArticle ->
            --delete the article using API call AND THEN SEND BACK TO MAIN PAGE
            ( model, deleteArticle model.article )

        GotComments (Ok comments) ->
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



-- subscriptions : Model -> Sub Msg
-- subscriptions model =
--     Sub.none
-- View --


viewFollowButton : Model -> Html Msg
viewFollowButton model =
    -- , button [class "btn btn-sm btn-outline-secondary"]
    -- [ i [class "ion-plus-round"][]
    -- , text (nbsp ++ nbsp ++ "  Follow Eric Simons ")
    -- , span [class "counter"] [text "(10)"]
    -- ]
    let
        buttonClass =
            if model.author.following then
                [ class "btn btn-sm btn-outline-secondary", style "background-color" "skyblue", style "color" "#fff", style "border-color" "black", type_ "button", onClick ToggleFollow ]

            else
                [ class "btn btn-sm btn-outline-secondary", type_ "button", onClick ToggleFollow ]
    in
    button buttonClass
        [ i [ class "ion-plus-round" ] []
        , text
            (" \u{00A0} "
                ++ (if model.author.following then
                        "Unfollow"

                    else
                        "Follow"
                   )
                ++ " "
                ++ model.author.username
                ++ " "
            )
        ]


viewLoveButton : Model -> Html Msg
viewLoveButton model =
    -- , button [class "btn btn-sm btn-outline-primary"]
    -- [i [class "ion-heart"] []
    -- , text (nbsp ++ nbsp ++ "  Favorite Post ")
    -- , span [class "counter"] [text "(29)"]
    -- ]
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


maybeImageBio : Maybe String -> String
maybeImageBio maybeIB =
    case maybeIB of
        Just imagebio ->
            imagebio

        Nothing ->
            ""


viewComment : Comment -> Html Msg
viewComment comment =
    --display a comment
    div [ class "card" ]
        --(div)
        [ div [ class "card-block" ]
            [ p [ class "card-text" ] [ text comment.body ]
            ]
        , div [ class "card-footer" ]
            [ a
                [ onClick (FetchProfileArticle comment.author.username)

                {- Routes.href Routes.Profile -}
                , class "comment-author"
                ]
                [ img [ src (maybeImageBio comment.author.image), class "comment-author-img" ] [] ]
            , text " \u{00A0} "
            , a
                [ onClick (FetchProfileArticle comment.author.username)

                {- Routes.href Routes.Profile -}
                , class "comment-author"
                ]
                [ text comment.author.username ]
            , text " "
            , span [ class "date-posted" ] [ text comment.createdAt ]
            , span [ class "mod-options" ]
                [ i [ class "ion-trash-a", onClick (DeleteComment comment.id) ] []
                ]
            ]
        ]


viewCommentList : Maybe Comments -> Html Msg
viewCommentList maybeComments =
    --display a list of comments (if there are)
    case maybeComments of
        Just comments ->
            div []
                (List.map viewComment comments)

        Nothing ->
            text ""



-- onEnter : msg -> Attribute msg
-- onEnter msg =
--     keyCode
--         |> Decode.andThen
--             (\key ->
--                 if key == 13 then
--                     Decode.succeed msg
--                 else
--                     Decode.fail "Not enter"
--             )
--         |> on "keyup"


viewComments : Model -> Html Msg
viewComments model =
    --display all the comments and a place for adding a new comment
    div [ class "row" ]
        [ div [ class "col-md-8 col-md-offset-2" ]
            [ viewCommentList model.comments
            , form [ class "card comment-form" ]
                [ div [ class "card-block" ]
                    [ textarea [ class "form-control", placeholder "Write a comment...", rows 3, value model.newComment, onInput UpdateComment ] [] ]

                --add enter on enter and shift enter to move to next row :) (otherwise input) onEnter UpdateComment
                , div [ class "card-footer" ]
                    -- this has to be the user's image!
                    -- onClick redirect to user's own profile
                    [ img [ src "http://i.imgur.com/Qr71crq.jpg", class "comment-author-img" ] []
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
                [ p [] [ text """Web development technologies have evolved at an incredible clip over the past few years.
                    We've gone from rudimentary DOM manipulation with libraries like jQuery to supercharged web 
                    applications organized & powered by elegant MV* based frameworks like AngularJS. 
                    Pair this with significant increases in browser rendering speeds, and it is now easier than ever 
                    before to build production quality applications on top of Javascript, HTML5, and CSS3.""" ]
                , p [] [ text """While these advances have been incredible, they are only just starting to affect the clear 
                    platform of the future: mobile. For years, mobile rendering speeds were atrocious, and the MVC frameworks 
                    & UI libraries provided by iOS and Android were far superior to writing mobile apps using web technologies. 
                    There were also some very public failures -- Facebook famously wrote their first iOS app in 2011 using HTML5 but 
                    ended up scrapping it due to terrible performance.""" ]
                , p [] [ text """For years now, hybrid apps have been mocked and jeered by 
                    native app developers for being clunky and ugly, having subpar performance, and having no advantages over native apps. 
                    While these may have been valid reasons in 2011, they are now virtually baseless, thanks to a collection of new technologies
                    that have emerged over the past two years. With these technologies, you can design, build, and deploy robust mobile apps faster
                    than you could with native technologies, all while incurring little to no app performance penalties. This is thanks in large part
                    to super fast mobile browser rendering speeds and better JavaScript performance. This course is designed to teach you how to effectively
                    use these new technologies to build insanely great mobile apps.""" ]
                , p [] [ text """Without further ado, we'd like to welcome you to the future of
                    mobile app development, freed from the shackles of native languages & frameworks. 
                    Let's learn what the new mobile stack consists of and how it works.""" ]
                , h2 [ id "introducing-ionic" ] [ text "Introducing Ionic." ]
                , p []
                    [ text """Before, building hybrid apps was a chore -- not because it was hard to build web pages, but because it was hard to build full-fledged web applications. 
                            With AngularJS, that has changed. As a result, Angular became the core innovation that made hybrid apps possible. The bright folks at Drifty were some of the 
                            first to realize this and subsequently created the """
                    , a [ href "http://ionicframework.com/", target "_blank" ] [ text "Ionic Framework " ]
                    , text "to bridge the gap between AngularJS web apps and hybrid mobile apps. Since launching a little over a year ago, the Ionic Framework has "
                    , a [ href "http://www.google.com/trends/explore?hl=en-US&q=ionic+framework&cmpt=q&tz&tz&content=1", target "_blank" ] [ text "quickly grown in popularity amongst developers" ]
                    , text " and their "
                    , a [ href "https://github.com/driftyco/ionic", target "_blank" ] [ text "main Github repo" ]
                    , text " has over 13K stars as of this writing."
                    ]
                , p []
                    [ text "Ionic provides similar functionality for AngularJS that "
                    , a [ href "https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIKit_Framework/", target "_blank" ] [ text "iOS UIKit" ]
                    , text " provides for Obj-C/Swift, and that "
                    , a [ href "http://developer.android.com/guide/topics/ui/overview.html", target "_blank" ] [ text "Android UI elements" ]
                    , text """ provides for Java. Core mobile UI paradigms are available to developers out of the box, which means that developers can focus on building apps, 
                        instead of common user interface elements. Some examples of these include """
                    , a [ href "http://ionicframework.com/docs/api/directive/ionList/", target "_blank" ] [ text "list views" ]
                    , text ", "
                    , a [ href "http://ionicframework.com/docs/api/directive/ionNavView/", target "_blank" ] [ text "stateful navigation" ]
                    , text ", "
                    , a [ href "http://ionicframework.com/docs/nightly/api/directive/ionTabs/", target "_blank" ] [ text "tab bars" ]
                    , text ", "
                    , a [ href "http://ionicframework.com/docs/api/service/$ionicActionSheet/", target "_blank" ] [ text "action sheets" ]
                    , text ", and "
                    , a [ href "http://ionicframework.com/docs/nightly/api/", target "_blank" ] [ text "so much more" ]
                    , text "."
                    ]
                , p [] [ text """Ionic is a great solution for creating both mobile web apps and native apps. The first sections of this course will go over structuring Ionic apps that can run on the web. 
                    Then we will cover packaging that same exact code into a native app. We will be using a build tool called Cordova for packaging our app. For those unfamiliar with Cordova, it is
                    the open source core of Adobe's proprietary PhoneGap build system. Adobe describes it with this analogy: Cordova is to PhoneGap as Blink is to Chrome. Basically, PhoneGap is
                    Cordova plus a whole bunch of other Adobe stuff.""" ]
                , p [] [ text """The folks at Ionic have done a fantastic job of making Cordova super easy to use by directly wrapping it in their 'ionic' command line tool (don't worry, we'll cover this later).
                    Just remember that Cordova is something that is running under the hood of your hybrid app that you will rarely need to worry about, but we will cover some common interactions with it in this course.""" ]
                , h2 [ id "what-we-re-going-to-build" ] [ text "What we're going to build" ] --&#39
                , p []
                    [ text """We will be building an app called Songhop, a "Tinder for music" app that allows you to listen to 30-second song samples and favorite the ones you like. This is based on a real 
                    Ionic/Cordova powered app we built that exists on the """
                    , a [ href "https://itunes.apple.com/us/app/songhop/id899245239?mt=8", target "_blank" ] [ text "iOS App Store" ]
                    , text """ -- feel free to download it to get a feeling for what Ionic is capable of (and rate it 5 stars :). It's also worth noting that it only took us a month to build the Songhop app that's
                        on the App Store, so that should give you an idea of how fast you can build & iterate using Ionic / Cordova."""
                    ]
                , p []
                    [ strong []
                        [ text "You can also see a "
                        , a [ href "https://ionic-songhop.herokuapp.com", target "_blank" ] [ text "live demo of the completed application we'll be building here" ]
                        , text " (resize your browser window to the size of a phone for the best experience)."
                        ]
                    ]
                , p [] [ text """We'll be covering a wide variety of topics in this course: scaffolding a new application, testing it in the emulator, installing native plugins for manipulating audio & 
                    files, swipe gestures for our interface, installing the app on your own device, deploying to the iOS & Android app stores, and so much more.""" ]
                ]
            ]
        , hr [] []
        , div [ class "post-actions" ]
            [ div [ class "post-meta" ]
                [ a
                    [ onClick (FetchProfileArticle model.author.username)

                    -- Routes.href Routes.Profile
                    ]
                    [ img [ src (maybeImageBio model.author.image) ] [] ]
                , text " " --helps make spacing perfect even though it's not exactly included in the og html version
                , div [ class "info" ]
                    [ a [ onClick (FetchProfileArticle model.author.username){-Routes.href Routes.Profile-}, class "author" ] [ text model.author.username ]
                    , span [ class "date" ] [ text model.article.createdAt ]
                    ]
                , text " " --helps make spacing perfect even though it's not exactly included in the og html version
                , viewFollowButton model
                , text " \u{00A0} "
                , viewLoveButton model
                ]
            ]
        , viewComments model

        -- , div [class "row"]
        --     [div [class "col-md-8 col-md-offset-2"]
        --         [ div [class "card"] --function to do these 2
        --             [ div [class "card-block"]
        --                 [p [class "card-text"] [text "With supporting text below as a natural lead-in to additional content."]
        --                 ]
        --             , div [class "card-footer"]
        --                 [ a [href "profile.html", class "comment-author"]
        --                     [img [src "http://i.imgur.com/Qr71crq.jpg", class "comment-author-img"] []]
        --                 , text (nbsp ++ nbsp ++ nbsp)
        --                 , a [href "profile.html", class "comment-author"] [text "Jacob Schmidt"]
        --                 , text nbsp
        --                 , span [class "date-posted"] [text "Dec 29th"]
        --                 ]
        --             ]
        --         , div [class "card"]
        --             [div [class "card-block"]
        --                 [p [class "card-text"] [text "With supporting text below as a natural lead-in to additional content."]
        --                 ]
        --             , div [class "card-footer"]
        --                 [ a [href "profile.html", class "comment-author"]
        --                     [img [src "http://i.imgur.com/Qr71crq.jpg", class "comment-author-img"] []]
        --                 , text (nbsp ++ nbsp ++ nbsp)
        --                 , a [href "profile.html", class "comment-author"] [text "Jacob Schmidt"]
        --                 , text nbsp
        --                 , span [class "date-posted"] [text "Dec 29th"]
        --                 , span [class "mod-options"]
        --                     [ i [class "ion-edit"] []
        --                     , text nbsp
        --                     , i [class "ion-trash-a"] []
        --                     ]
        --                 ]
        --             ]
        --         , form [class "card comment-form"]
        --             [ div [class "card-block"]
        --                 [textarea [class "form-control", placeholder "Write a comment...", rows 3] []]
        --             , div [class "card-footer"]
        --                 [ img [src "http://i.imgur.com/Qr71crq.jpg", class "comment-author-img"] []
        --                 , button [class "btn btn-sm btn-primary"] [text " Post Comment"]
        --                 ]
        --             ]
        --         ]
        --     ]
        ]


view : Model -> Html Msg
view model =
    div []
        [ div [ class "post-page" ]
            [ div [ class "banner" ]
                [ div [ class "container" ]
                    [ h1 [] [ text "How to build webapps that scale" ] 
                    , div [ class "post-meta" ] 
                        [ a [ {-onClick (FetchProfileArticle model.author.username)-}Routes.href (Routes.Profile model.author.username), href "" ]
                            -- add onClick to author's profile page
                            [ img [ src (maybeImageBio model.author.image) ] [] ]
                        , text " " --helps make spacing perfect even though it's not exactly included in the og html version
                        , div [ class "info" ]
                            [ a [ onClick (FetchProfileArticle model.author.username){-Routes.href Routes.Profile-}, class "author" ] [ text model.author.username ]
                            , span [ class "date" ] [ text model.article.createdAt ]
                            ]
                        , text " " --helps make spacing perfect even though it's not exactly included in the og html version
                        , viewFollowButton model
                        , text " \u{00A0}\u{00A0} "
                        , viewLoveButton model
                        ]
                    ]
                ]
            , viewArticle model
            ]
        , footer []
            [ div [ class "container" ]
                [ a [ Routes.href Routes.Index, class "logo-font" ] [ text "conduit" ] -- gohome
                , text " " --helps make spacing perfect even though it's not exactly included in the og html version
                , span [ class "attribution" ]
                    [ text "An interactive learning project from "
                    , a [ href "https://thinkster.io/" ] [ text "Thinkster" ] --external link
                    , text ". Code & design licensed under MIT."
                    ]
                ]
            ]
        ]



-- main : Program () Model Msg
-- main =
--     -- view initialModel
--     Browser.element
--         { init = initialModel
--         , view = view
--         , update = update
--         , subscriptions = subscriptions
--         }
--Now article is a component and no longer an application
