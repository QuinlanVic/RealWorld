module Profile exposing (Model, Msg, init, update, view)

-- import Exts.Html exposing (nbsp)
-- import Browser

import Article exposing (Msg(..), initialModel)
import Editor exposing (authorDecoder)
import Html exposing (..)
import Html.Attributes exposing (class, href, src, style, type_)
import Html.Events exposing (onClick, onMouseLeave, onMouseOver)
import Http
import Json.Decode exposing (Decoder, bool, field, int, list, null, nullable, string, succeed)
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
    , numfollowers : Int
    }


type alias ArticlePreview =
    { authorpage : String
    , authorimage : String
    , authorname : String
    , date : String
    , articletitle : String
    , articlepreview : String
    , numlikes : Int
    , liked : Bool
    }


type alias Model =
    --put Posts inside? (List Article) & add Profile to basic Model :)
    { profile : Author
    , articlesMade : List ArticlePreview
    }


defaultProfile : Author
defaultProfile =
    { username = "Eric Simons"
    , bio = " Cofounder @GoThinkster, lived in Aol's HQ for a few months, kinda looks like Peeta from the Hunger Games"
    , image = "http://i.imgur.com/Qr71crq.jpg"
    , following = False
    , numfollowers = 10
    }


initialModel : Model
initialModel =
    { profile = defaultProfile
    , articlesMade = [ articlePreview1, articlePreview2 ]
    }


authorDecoder : Decoder Author
authorDecoder =
    succeed Author
        |> required "username" string
        |> required "bio" string
        |> required "image" string
        |> required "following" bool
        |> hardcoded 10


fetchProfile : String -> Cmd Msg
fetchProfile username =
    -- need to fetch the profile
    Http.get
        { url = baseUrl ++ "api/profiles/{" ++ username ++ "}"
        , expect = Http.expectJson (LoadProfile username) authorDecoder
        }


init : ( Model, Cmd Msg )
init =
    -- () -> (No longer need unit flag as it's no longer an application but a component)
    --fetchProfile username
    ( initialModel, Cmd.none )


baseUrl : String
baseUrl =
    "http://localhost:8000/"


articlePreview1 : ArticlePreview
articlePreview1 =
    { authorpage = "profileelm.html"
    , authorimage = "http://i.imgur.com/Qr71crq.jpg"
    , authorname = "Eric Simons"
    , date = "January 20th"
    , articletitle = "How to build webapps that scale"
    , articlepreview = """In my demo, the holy grail layout is nested inside a document, so there's no body or main tags like shown above. Regardless, we're interested in the class names 
                        and the appearance of sections in the markup as opposed to the actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and 
                        the trivial order in which they appear in the markup. Let's break this down to paint a clear picture of what's happening..."""
    , numlikes = 29
    , liked = False
    }


articlePreview2 : ArticlePreview
articlePreview2 =
    { authorpage = "profileelm.html"
    , authorimage = "http://i.imgur.com/N4VcUeJ.jpg"
    , authorname = "Albert Pai"
    , date = "January 20th"
    , articletitle = "The song you won't ever stop singing. No matter how hard you try."
    , articlepreview = """In my demo, the holy grail layout is nested inside a document, so there's no body or main tags like shown above. Regardless, we're interested in the class names 
                        and the appearance of sections in the markup as opposed to the actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and 
                        the trivial order in which they appear in the markup. Let's break this down to paint a clear picture of what's happening..."""
    , numlikes = 32
    , liked = False
    }



-- Update --
--how do you get a specific profile after a user clicks on their page


toggleFollow : Author -> Author
toggleFollow author =
    if author.following then
        { author | following = not author.following, numfollowers = author.numfollowers - 1 }

    else
        { author | following = not author.following, numfollowers = author.numfollowers + 1 }


getProfileCompleted : {- String -> -} Model -> Result Http.Error Author -> ( Model, Cmd Msg )
getProfileCompleted {- username -} model result =
    case result of
        Ok userProfile ->
            --confused here (return new model from the server with hardcoded password, errmsg and signedup values as those are not a part of the user record returned from the server?)
            ( { model | profile = userProfile }, Cmd.none )

        --|> Debug.log "got the user"
        Err error ->
            ( model, Cmd.none )


updateArticlePreviewLikes : ArticlePreview -> ArticlePreview
updateArticlePreviewLikes articlepreview =
    --very inefficient
    if articlepreview.liked then
        { articlepreview | liked = not articlepreview.liked, numlikes = articlepreview.numlikes - 1 }

    else
        { articlepreview | liked = not articlepreview.liked, numlikes = articlepreview.numlikes + 1 }


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        ToggleLike ->
            ( { model | articlesMade = List.map updateArticlePreviewLikes model.articlesMade }, Cmd.none )

        --need lazy execution
        ToggleFollow ->
            -- if model.profile.following then
            --     ( { model | following = not model.following, numfollowers = model.numfollowers - 1 }, Cmd.none )

            -- else
            --     ( { model | following = not model.following, numfollowers = model.numfollowers + 1 }, Cmd.none )
                ( { model | profile = toggleFollow model.profile }, Cmd.none )

        LoadProfile username result ->
            getProfileCompleted {- username -} model result


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- View --


viewFollowButton : Model -> Html Msg
viewFollowButton model =
    --use from Article
    let
        buttonClass =
            if model.profile.following then
                [ class "btn btn-sm btn-outline-secondary action-btn", style "background-color" "skyblue", style "color" "#fff", style "border-color" "black", type_ "button", onClick ToggleFollow ]

            else
                [ class "btn btn-sm btn-outline-secondary action-btn", type_ "button", onClick ToggleFollow ]
    in
    button buttonClass
        [ i [ class "ion-plus-round" ] []
        , text " \u{00A0} Follow Eric Simons "
        , span [ class "counter" ] [ text ("(" ++ String.fromInt model.profile.numfollowers ++ ")") ]
        ]


viewLoveButton : ArticlePreview -> Html Msg
viewLoveButton articlePreview =
    --use from Article
    let
        buttonClass =
            if articlePreview.liked then
                [ class "btn btn-outline-primary btn-sm pull-xs-right", style "background-color" "#d00", style "color" "#fff", style "border-color" "black", type_ "button", onClick ToggleLike ]

            else
                [ class "btn btn-outline-primary btn-sm pull-xs-right", type_ "button", onClick ToggleLike ]
    in
    button buttonClass
        [ i [ class "ion-heart" ] []
        , text (" " ++ String.fromInt articlePreview.numlikes)
        ]


viewArticlePreview : ArticlePreview -> Html Msg
viewArticlePreview article =
    div [ class "article-preview" ]
        [ div [ class "article-meta" ]
            [ a [ Routes.href Routes.Profile ] [ img [ src article.authorimage ] [] ]
            , text " "
            , div [ class "info" ]
                [ a [ Routes.href Routes.Profile, class "author" ] [ text article.authorname ]
                , span [ class "date" ] [ text article.date ]
                ]
            , viewLoveButton article
            ]
        , a [ Routes.href Routes.Article, class "preview-link" ]
            [ h1 [] [ text article.articletitle ]
            , p [] [ text article.articlepreview ]
            , span [] [ text "Read more..." ]
            ]
        ]


viewArticles : List ArticlePreview -> Html Msg
viewArticles articlesMade =
    div []
        --ul and li = weird dot :)
        (List.map viewArticlePreview articlesMade)


view : Model -> Html Msg
view model =
    div []
        [ div [ class "profile-page" ]
            [ div [ class "user-info" ]
                [ div [ class "container" ]
                    [ div [ class "row" ]
                        [ div [ class "col-md-10 col-md-offset-1" ]
                            [ img [ src model.profile.image, class "user-img" ] []
                            , h4 [] [ text model.profile.username ]
                            , p [] [ text model.profile.bio ]
                            , text " "
                            , viewFollowButton model

                            -- , button [class "btn btn-sm btn-outline-secondary action-btn"]
                            --     [i [class "ion-plus-round"] []
                            --     , text (nbsp ++ nbsp ++ "  Follow Eric Simons ")
                            --     , span [class "counter"] [text "(10)"]
                            --     ]
                            ]
                        ]
                    ]
                ]
            , div [ class "container" ]
                [ div [ class "row" ]
                    [ div [ class "col-md-10 col-md-offset-1" ]
                        [ div [ class "articles-toggle" ]
                            [ ul [ class "nav nav-pills outline-active" ]
                                [ li [ class "nav-item" ]
                                    [ a [ class "nav-link active", href "#" ] [ text "My Posts" ] ]
                                , li [ class "nav-item" ]
                                    [ a [ class "nav-link", href "#" ] [ text "Favorited Posts" ] ]
                                ]
                            ]
                        , viewArticles model.articlesMade

                        -- , viewArticlePreview articlePreview1
                        -- , div [class "article-preview"]
                        --     [div [class "article-meta"]
                        --         [ a [href "profileelm.html"] [img [src "http://i.imgur.com/Qr71crq.jpg"] []]
                        --         , text nbsp
                        --         , div [class "info"]
                        --             [ a [href "profileelm.html", class "author"] [text "Eric Simons"]
                        --             , span [class "date"] [text "January 20th"]
                        --             ]
                        --         , viewLoveButton model
                        --         -- , button [class "btn btn-outline-primary btn-sm pull-xs-right"]
                        --         --     [ i [class "ion-heart"] []
                        --         --     , text " 29"
                        --         --     ]
                        --         ]
                        --     , a [href "article-meta", class "preview-link"]
                        --         [ h1 [] [text "How to build webapps that scale"]
                        --         , p [] [text """In my demo, the holy grail layout is nested inside a document, so there's no body or main tags like shown above.
                        --                         Regardless, we're interested in the class names and the appearance of sections in the markup as opposed to the
                        --                         actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and the
                        --                         trivial order in which they appear in the markup. Let's break this down to paint a clear picture of what's happening..."""]
                        --         , span [] [text "Read more..."]
                        --         ]
                        --     ]
                        -- , viewArticlePreview articlePreview2
                        -- , div [class "article-preview"]
                        --     [div [class "article-meta"]
                        --         [ a [href "profileelm.html"] [img [src "http://i.imgur.com/N4VcUeJ.jpg"] []]
                        --         , text nbsp
                        --         , div [class "info"]
                        --                 [ a [href "profileelm.html", class "author"] [text "Albert Pai"]
                        --                 , span [class "date"] [text "January 20th"]
                        --                 ]
                        --         , viewLoveButton articlePreview2
                        --         -- , button [class "btn btn-outline-primary btn-sm pull-xs-right"]
                        --         --         [ i [class "ion-heart"] []
                        --         --         , text " 32"
                        --         --         ]
                        --         ]
                        --     , a [href "articleelm.html", class "preview-link"]
                        --         [ h1 [] [text "The song you won't ever stop singing. No matter how hard you try."]
                        --         , p [] [text """In my demo, the holy grail layout is nested inside a document, so there's no body or main tags like shown above.
                        --                         Regardless, we're interested in the class names and the appearance of sections in the markup as opposed to the
                        --                         actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and the
                        --                         trivial order in which they appear in the markup. Let's break this down to paint a clear picture of what's happening..."""]
                        --         , span [] [text "Read more..."]
                        --         ]
                        --     ]
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
    = ToggleLike
    | ToggleFollow
    | LoadProfile String (Result Http.Error Author)



-- main : Program () Model Msg
-- main =
--     -- view initialModel
--     Browser.element
--         { init = initialModel
--         , view = view
--         , update = update
--         , subscriptions = subscriptions
--         }
--Now profile is a component and no longer an application
