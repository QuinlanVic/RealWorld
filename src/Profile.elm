module Profile exposing (Model, Msg, init, update, view)

-- import Exts.Html exposing (nbsp)
-- import Browser

import Auth exposing (User, userDecoder)
import Editor exposing (Author)
import Html exposing (..)
import Html.Attributes exposing (class, href, src, style, type_)
import Html.Events exposing (onClick, onMouseLeave, onMouseOver)
import Http
import Post exposing (Msg(..), initialModel)
import Routes



-- Model --


type alias Model =
    --put Posts inside? (List Post) & add User to basic Model :)
    { profile : Author
    , postsMade : List PostPreview
    }


defaultProfile : Author
defaultProfile =
    { username = "Eric Simons"
    , bio = " Cofounder @GoThinkster, lived in Aol's HQ for a few months, kinda looks like Peeta from the Hunger Games"
    , image = "http://i.imgur.com/Qr71crq.jpg"
    , following = False
    }


initialModel : Model
initialModel =
    { profile = defaultProfile
    , postsMade = [ postPreview1, postPreview2 ]
    }


init : ( Model, Cmd Msg )
init =
    -- () -> (No longer need unit flag as it's no longer an application but a component)
    ( initialModel, Cmd.none )



-- need to fetch the default profile


type alias PostPreview =
    { authorpage : String
    , authorimage : String
    , authorname : String
    , date : String
    , articletitle : String
    , articlepreview : String
    , numlikes : Int
    , liked : Bool
    }


baseUrl : String
baseUrl =
    "http://localhost:8000/"


fetchProfile : Cmd Msg
fetchProfile =
    Http.get
        { url = baseUrl ++ "api/profiles/{" -- ++ username ++ "}"
        , expect = Http.expectJson LoadProfile userDecoder
        }


postPreview1 : PostPreview
postPreview1 =
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


postPreview2 : PostPreview
postPreview2 =
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


getProfileCompleted : Model -> Result Http.Error User -> ( Model, Cmd Msg )
getProfileCompleted profile result =
    case result of
        Ok getProfile ->
            --confused here (return new model from the server with hardcoded password, errmsg and signedup values as those are not a part of the user record returned from the server?)
            ( getProfile, Cmd.none )

        --|> Debug.log "got the user"
        Err error ->
            ( { profile | errmsg = Debug.toString error }, Cmd.none )


updatePostPreviewLikes : PostPreview -> PostPreview
updatePostPreviewLikes postpreview =
    --very inefficient
    if postpreview.liked then
        { postpreview | liked = not postpreview.liked, numlikes = postpreview.numlikes - 1 }

    else
        { postpreview | liked = not postpreview.liked, numlikes = postpreview.numlikes + 1 }


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        ToggleLike ->
            ( { model | postsMade = List.map updatePostPreviewLikes model.postsMade }, Cmd.none )

        --need lazy execution
        ToggleFollow ->
            if model.followed then
                ( { model | followed = not model.followed, numfollowers = model.numfollowers - 1 }, Cmd.none )

            else
                ( { model | followed = not model.followed, numfollowers = model.numfollowers + 1 }, Cmd.none )

        LoadProfile result ->
            getProfileCompleted model result


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- View --


viewFollowButton : Model -> Html Msg
viewFollowButton model =
    --use from Post
    let
        buttonClass =
            if model.followed then
                [ class "btn btn-sm btn-outline-secondary action-btn", style "background-color" "skyblue", style "color" "#fff", style "border-color" "black", type_ "button", onClick ToggleFollow ]

            else
                [ class "btn btn-sm btn-outline-secondary action-btn", type_ "button", onClick ToggleFollow ]
    in
    button buttonClass
        [ i [ class "ion-plus-round" ] []
        , text " \u{00A0} Follow Eric Simons "
        , span [ class "counter" ] [ text ("(" ++ String.fromInt model.numfollowers ++ ")") ]
        ]


viewLoveButton : PostPreview -> Html Msg
viewLoveButton postPreview =
    --use from Post
    let
        buttonClass =
            if postPreview.liked then
                [ class "btn btn-outline-primary btn-sm pull-xs-right", style "background-color" "#d00", style "color" "#fff", style "border-color" "black", type_ "button", onClick ToggleLike ]

            else
                [ class "btn btn-outline-primary btn-sm pull-xs-right", type_ "button", onClick ToggleLike ]
    in
    button buttonClass
        [ i [ class "ion-heart" ] []
        , text (" " ++ String.fromInt postPreview.numlikes)
        ]


viewPostPreview : PostPreview -> Html Msg
viewPostPreview post =
    div [ class "post-preview" ]
        [ div [ class "post-meta" ]
            [ a [ Routes.href Routes.Post ] [ img [ src post.authorimage ] [] ]
            , text " "
            , div [ class "info" ]
                [ a [ Routes.href Routes.Post, class "author" ] [ text post.authorname ]
                , span [ class "date" ] [ text post.date ]
                ]
            , viewLoveButton post
            ]
        , a [ Routes.href Routes.Post, class "preview-link" ]
            [ h1 [] [ text post.articletitle ]
            , p [] [ text post.articlepreview ]
            , span [] [ text "Read more..." ]
            ]
        ]


viewPosts : List PostPreview -> Html Msg
viewPosts postsMade =
    div []
        --ul and li = weird dot :)
        (List.map viewPostPreview postsMade)


view : Model -> Html Msg
view model =
    div []
        [ div [ class "profile-page" ]
            [ div [ class "user-info" ]
                [ div [ class "container" ]
                    [ div [ class "row" ]
                        [ div [ class "col-md-10 col-md-offset-1" ]
                            [ img [ src model.authorimage, class "user-img" ] []
                            , h4 [] [ text model.authorname ]
                            , p [] [ text model.authorbio ]
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
                        [ div [ class "posts-toggle" ]
                            [ ul [ class "nav nav-pills outline-active" ]
                                [ li [ class "nav-item" ]
                                    [ a [ class "nav-link active", href "#" ] [ text "My Posts" ] ]
                                , li [ class "nav-item" ]
                                    [ a [ class "nav-link", href "#" ] [ text "Favorited Posts" ] ]
                                ]
                            ]
                        , viewPosts model.postsMade

                        -- , viewPostPreview postPreview1
                        -- , div [class "post-preview"]
                        --     [div [class "post-meta"]
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
                        --     , a [href "post-meta", class "preview-link"]
                        --         [ h1 [] [text "How to build webapps that scale"]
                        --         , p [] [text """In my demo, the holy grail layout is nested inside a document, so there's no body or main tags like shown above.
                        --                         Regardless, we're interested in the class names and the appearance of sections in the markup as opposed to the
                        --                         actual elements themselves. In particular, take note of the modifier classes used on the two sidebars, and the
                        --                         trivial order in which they appear in the markup. Let's break this down to paint a clear picture of what's happening..."""]
                        --         , span [] [text "Read more..."]
                        --         ]
                        --     ]
                        -- , viewPostPreview postPreview2
                        -- , div [class "post-preview"]
                        --     [div [class "post-meta"]
                        --         [ a [href "profileelm.html"] [img [src "http://i.imgur.com/N4VcUeJ.jpg"] []]
                        --         , text nbsp
                        --         , div [class "info"]
                        --                 [ a [href "profileelm.html", class "author"] [text "Albert Pai"]
                        --                 , span [class "date"] [text "January 20th"]
                        --                 ]
                        --         , viewLoveButton postPreview2
                        --         -- , button [class "btn btn-outline-primary btn-sm pull-xs-right"]
                        --         --         [ i [class "ion-heart"] []
                        --         --         , text " 32"
                        --         --         ]
                        --         ]
                        --     , a [href "postelm.html", class "preview-link"]
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
    | LoadProfile (Result Http.Error User)



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
