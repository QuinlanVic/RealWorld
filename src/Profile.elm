module Profile exposing (..)

import Html exposing (..)

import Html.Attributes exposing (class, href, src, style)

import Exts.Html exposing (nbsp)
import Post exposing (initialModel)

import Browser

import Html.Events exposing (onClick)

-- Model --
type alias Model = --put Posts inside? (List Post)
    { authorimage : String 
    , authorname : String
    , authorbio : String  
    , numfollowers : Int
    , followed : Bool
    , postsMade : List PostPreview 
    }

initialModel : Model 
initialModel =
    { authorimage = "" 
    , authorname = ""
    , authorbio = ""
    , numfollowers = 10
    , followed = False 
    , postsMade = [postPreview1, postPreview2]
    }

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
updatePostPreviewLikes : PostPreview -> PostPreview
updatePostPreviewLikes postpreview = --very inefficient
    if postpreview.liked then {postpreview | liked = not postpreview.liked, numlikes = postpreview.numlikes - 1} else {postpreview | liked = not postpreview.liked, numlikes = postpreview.numlikes + 1}

update : Msg -> Model -> Model 
update message model =
    case message of
        ToggleLike -> {model | postsMade = List.map updatePostPreviewLikes model.postsMade} --need lazy execution
        ToggleFollow -> if model.followed then {model | followed = not model.followed, numfollowers = model.numfollowers - 1} else {model | followed = not model.followed, numfollowers = model.numfollowers + 1}

-- View --
viewFollowButton : Model -> Html Msg 
viewFollowButton model = --use from Post
    let 
        buttonClass =
            if model.followed then 
                [class "btn btn-sm btn-outline-secondary action-btn", style "background-color" "skyblue", style "color" "#fff", style "border-color" "black", onClick ToggleFollow] 
            else 
                [class "btn btn-sm btn-outline-secondary action-btn", onClick ToggleFollow] 
    in
    button buttonClass
        [ i [class "ion-plus-round"][]
        , text (nbsp ++ nbsp ++ "  Follow Eric Simons ")
        , span [class "counter"] [text ("(" ++ String.fromInt model.numfollowers ++ ")")]
        ]

viewLoveButton : PostPreview -> Html Msg 
viewLoveButton postPreview = --use from Post
    let 
        buttonClass =
            if postPreview.liked then 
                [class "btn btn-outline-primary btn-sm pull-xs-right", style "background-color" "#d00", style "color" "#fff", style "border-color" "black", onClick ToggleLike] 
            else 
                [class "btn btn-outline-primary btn-sm pull-xs-right", onClick ToggleLike] 
    in
    button buttonClass
           [i [class "ion-heart"] []
           , text (" " ++ String.fromInt postPreview.numlikes)
           ]
    

viewPostPreview : PostPreview -> Html Msg 
viewPostPreview post =
    div [class "post-preview"] 
        [ div [class "post-meta"] 
                [ a [href post.authorpage] [img [src post.authorimage] []]
                , text nbsp
                , div [class "info"] 
                    [ a [href post.authorpage, class "author"] [text post.authorname]
                    , span [class "date"] [text post.date] 
                    ]
                , viewLoveButton post
                ]
            , a [href "postelm.html", class "preview-link"] 
                [ h1 [] [text post.articletitle]
                , p [] [text post.articlepreview]
                , span [] [text "Read more..."]
                ]
        ]

viewPosts : List PostPreview -> Html Msg 
viewPosts postsMade =
    div [] --ul and li = weird dot :)
        (List.map viewPostPreview postsMade) 

view : Model -> Html Msg 
view model =
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
    , div [class "profile-page"]
        [ div [class "user-info"] 
             [ div [class "container"] 
                [div [class "row"]
                    [div [class "col-md-10 col-md-offset-1"] 
                        [ img [src "http://i.imgur.com/Qr71crq.jpg", class "user-img"] []
                        , h4 [] [text "Eric Simons"]
                        , p [] [text " Cofounder @GoThinkster, lived in Aol's HQ for a few months, kinda looks like Peeta from the Hunger Games"]
                        , text nbsp
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
        , div [class "container"] 
            [div [class "row"] 
                 [div [class "col-md-10 col-md-offset-1"] 
                    [ div [class "posts-toggle"]
                        [ul [class "nav nav-pills outline-active"]
                            [ li [class "nav-item"] 
                                [a [class "nav-link active", href "#"] [text "My Posts"]]
                            , li [class "nav-item"] 
                                [a [class "nav-link", href "#"] [text "Favorited Posts"]]
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
    = ToggleLike 
    | ToggleFollow 


main : Program () Model Msg
main =
    -- view initialModel
    Browser.sandbox
    { init = initialModel
    , view = view
    , update = update 
    }
