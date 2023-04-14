module Post exposing (..)

import Html exposing (..)

import Html.Attributes exposing (class, href, id, placeholder, rows, src, target)

import Exts.Html exposing (nbsp)


--extra Exts.Html installed with "elm package install krisajenkins/elm-exts" for using nbsp
main : Html msg
main =
    div[]
    [ nav[class "navbar navbar-light"]
        [div [class "container"] 
            [ a [class "navbar-brand", href "index.html"] [text "conduit"],
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
    , div [class "post-page"] 
        [ div [class "banner"] 
            [div [class "container"] 
                [ h1 [] [text "How to build webapps that scale"]
                , div [class "post-meta"] 
                    [ a [href "profile.html"] 
                        [img [src "http://i.imgur.com/Qr71crq.jpg"][]]
                    , div [class "info"] 
                        [ a [href "profile.html", class "author"] [text "Eric Simons"]
                        , span [class "date"] [text "January 20th"]
                        ]
                    , button [class "btn btn-sm btn-outline-secondary"] 
                        [ i [class "ion-plus-round"][]
                        , text (nbsp ++ nbsp ++ "  Follow Eric Simons ")
                        , span [class "counter"] [text "(10)"]
                        ]
                    , text (nbsp ++ nbsp ++ nbsp ++ nbsp)
                    , button [class "btn btn-sm btn-outline-primary"]
                        [ i [class "ion-heart"] []
                        , text (nbsp ++ nbsp ++ "  Favorite Post ")
                        , span [class "counter"] [text "(29)"]] 
                    ]
                ]
            ]
        , div [class "container page"] 
            [div [class "row post-content"] 
                [div [class "col-md-12"] 
                    [ p [] [text """Web development technologies have evolved at an incredible clip over the past few years.
                            We've gone from rudimentary DOM manipulation with libraries like jQuery to supercharged web 
                            applications organized & powered by elegant MV* based frameworks like AngularJS. 
                            Pair this with significant increases in browser rendering speeds, and it is now easier than ever 
                            before to build production quality applications on top of Javascript, HTML5, and CSS3."""]
                    , p [] [text """While these advances have been incredible, they are only just starting to affect the clear 
                            platform of the future: mobile. For years, mobile rendering speeds were atrocious, and the MVC frameworks 
                            & UI libraries provided by iOS and Android were far superior to writing mobile apps using web technologies. 
                            There were also some very public failures -- Facebook famously wrote their first iOS app in 2011 using HTML5 but 
                            ended up scrapping it due to terrible performance."""]
                    , p [] [text """For years now, hybrid apps have been mocked and jeered by 
                            native app developers for being clunky and ugly, having subpar performance, and having no advantages over native apps. 
                            While these may have been valid reasons in 2011, they are now virtually baseless, thanks to a collection of new technologies
                            that have emerged over the past two years. With these technologies, you can design, build, and deploy robust mobile apps faster
                            than you could with native technologies, all while incurring little to no app performance penalties. This is thanks in large part
                            to super fast mobile browser rendering speeds and better JavaScript performance. This course is designed to teach you how to effectively
                            use these new technologies to build insanely great mobile apps."""]
                    , p[] [text """Without further ado, we'd like to welcome you to the future of
                           mobile app development, freed from the shackles of native languages & frameworks. 
                           Let's learn what the new mobile stack consists of and how it works."""] 
                    , h2 [id "introducing-ionic"] [text "Introducing Ionic."]
                    , p [] [ text """Before, building hybrid apps was a chore -- not because it was hard to build web pages, but because it was hard to build full-fledged web applications. 
                                    With AngularJS, that has changed. As a result, Angular became the core innovation that made hybrid apps possible. The bright folks at Drifty were some of the 
                                    first to realize this and subsequently created the """
                           , a [href "http://ionicframework.com/", target "_blank"] [text "Ionic Framework "]
                           , text "to bridge the gap between AngularJS web apps and hybrid mobile apps. Since launching a little over a year ago, the Ionic Framework has "
                           , a [href "http://www.google.com/trends/explore?hl=en-US&q=ionic+framework&cmpt=q&tz&tz&content=1", target "_blank"] [text "quickly grown in popularity amongst developers"]
                           , text " and their "
                           , a [href "https://github.com/driftyco/ionic", target "_blank"] [text "main Github repo"]
                           , text " has over 13K stars as of this writing."]
                    , p [] [ text "Ionic provides similar functionality for AngularJS that "
                           , a [href "https://developer.apple.com/library/ios/documentation/UIKit/Reference/UIKit_Framework/", target"_blank"] [text "iOS UIKit"]
                           , text " provides for Obj-C/Swift, and that "
                           , a [href "http://developer.android.com/guide/topics/ui/overview.html", target "_blank"] [text "Android UI elements"]
                           , text """ provides for Java. Core mobile UI paradigms are available to developers out of the box, which means that developers can focus on building apps, 
                                instead of common user interface elements. Some examples of these include """
                           , a [href "http://ionicframework.com/docs/api/directive/ionList/", target "_blank"] [text "list views"]
                           , text ", " 
                           , a [href "http://ionicframework.com/docs/api/directive/ionNavView/", target "_blank"] [text "stateful navigation"]
                           , text ", "
                           , a [href "http://ionicframework.com/docs/nightly/api/directive/ionTabs/", target "_blank"] [text "tab bars"]
                           , text ", "
                           , a [href "http://ionicframework.com/docs/api/service/$ionicActionSheet/", target "_blank"] [text "action sheets"]
                           , text ", and "
                           , a [href "http://ionicframework.com/docs/nightly/api/", target "_blank"] [text "so much more"]
                           , text "."]
                    , p [] [text """Ionic is a great solution for creating both mobile web apps and native apps. The first sections of this course will go over structuring Ionic apps that can run on the web. 
                            Then we will cover packaging that same exact code into a native app. We will be using a build tool called Cordova for packaging our app. For those unfamiliar with Cordova, it is
                            the open source core of Adobe's proprietary PhoneGap build system. Adobe describes it with this analogy: Cordova is to PhoneGap as Blink is to Chrome. Basically, PhoneGap is
                            Cordova plus a whole bunch of other Adobe stuff."""]
                    , p [] [text """The folks at Ionic have done a fantastic job of making Cordova super easy to use by directly wrapping it in their 'ionic' command line tool (don't worry, we'll cover this later).
                            Just remember that Cordova is something that is running under the hood of your hybrid app that you will rarely need to worry about, but we will cover some common interactions with it in this course."""]
                    , h2 [id "what-we-re-going-to-build"] [text "What we're going to build"] --&#39
                    , p [] [text """We will be building an app called Songhop, a "Tinder for music" app that allows you to listen to 30-second song samples and favorite the ones you like. This is based on a real 
                            Ionic/Cordova powered app we built that exists on the """
                           , a [href "https://itunes.apple.com/us/app/songhop/id899245239?mt=8", target "_blank"] [text "iOS App Store"]
                           , text """ -- feel free to download it to get a feeling for what Ionic is capable of (and rate it 5 stars :). It's also worth noting that it only took us a month to build the Songhop app that's
                             on the App Store, so that should give you an idea of how fast you can build & iterate using Ionic / Cordova."""]
                    , p [] [strong [] [text "You can also see a "
                           , a [href "https://ionic-songhop.herokuapp.com", target "_blank"] [text "live demo of the completed application we'll be building here"]
                           , text " (resize your browser window to the size of a phone for the best experience)."]
                            ]
                    ,p [] [ text """We'll be covering a wide variety of topics in this course: scaffolding a new application, testing it in the emulator, installing native plugins for manipulating audio & 
                            files, swipe gestures for our interface, installing the app on your own device, deploying to the iOS & Android app stores, and so much more."""]
                    ]
                ] 
            , hr [] [] 
            , div [class "post-actions"]
                [div [class "post-meta"] 
                    [ a [href "profile.html"] [img [src "http://i.imgur.com/Qr71crq.jpg"] []]
                    , div [class "info"]
                        [ a [href "profile.html", class "author"] [text "Eric Simons"]
                        , span [class "date"] [text "January 20th"]
                        ]
                    , button [class "btn btn-sm btn-outline-secondary"]
                        [ i [class "ion-plus-round"] []
                        , text (nbsp ++ nbsp ++ "  Follow Eric Simons " )
                        , span [class "counter"] [text "(10)"]
                        ]
                    , text (nbsp ++ Exts.Html.nbsp)
                    , button [class "btn btn-sm btn-outline-primary"] 
                        [i [class "ion-heart"] []
                        , text (nbsp ++ nbsp ++ "  Favorite Post ")
                        , span [class "counter"] [text "(29)"]
                        ]
                    ]
                ]
            , div [class "row"] 
                [div [class "col-md-8 col-md-offset-2"] 
                    [ div [class "card"] --function to do these 2
                        [ div [class "card-block"] 
                            [p [class "card-text"] [text "With supporting text below as a natural lead-in to additional content."]
                            ]
                        , div [class "card-footer"] 
                            [ a [href "profile.html", class "comment-author"] 
                                [img [src "http://i.imgur.com/Qr71crq.jpg", class "comment-author-img"] []]
                            , text (nbsp ++ nbsp)
                            , a [href "profile.html", class "comment-author"] [text "Jacob Schmidt"]
                            , span [class "date-posted"] [text "Dec 29th"]
                            ]
                        ]
                    , div [class "card"]  
                        [div [class "card-block"] 
                            [p [class "card-text"] [text "With supporting text below as a natural lead-in to additional content."]
                            ]
                        , div [class "card-footer"] 
                            [ a [href "profile.html", class "comment-author"] 
                                [img [src "http://i.imgur.com/Qr71crq.jpg", class "comment-author-img"] []]
                            , text (nbsp ++ nbsp)
                            , a [href "profile.html", class "comment-author"] [text "Jacob Schmidt"]
                            , span [class "date-posted"] [text "Dec 29th"]
                            , span [class "mod-options"] 
                                [ i [class "ion-edit"] []
                                , i [class "ion-trash-a"] []
                                ]
                            ]
                        ]
                    , form [class "card comment-form"] 
                        [ div [class "card-block"] 
                            [textarea [class "form-control", placeholder "Write a comment...", rows 3] []]
                        , div [class "card-footer"] 
                            [ img [src "http://i.imgur.com/Qr71crq.jpg", class "comment-author-img"] []
                            , button [class "btn btn-sm btn-primary"] [text " Post Comment"]
                            ]
                        ]
                    ]
                ]
            ]
        ]   
    , footer []
        [ div [class "container"]
            [ a [href "/", class "logo-font"] [text "conduit"]
            , span [class "attribution"] 
                [ text "                                                An interactive learning project from "
                , a [href "https:..thinkster.io"] [text "Thinkster"]
                , text ". Code & design licensed under MIT."
                ] 
            ]
        ]
    ]
    