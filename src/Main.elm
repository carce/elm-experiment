module Main exposing (Model, Route(..), init, main, parseLocation, routeParser, update, view)

import Array exposing (Array)
import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Html.Attributes exposing (..)
import Http
import Json.Decode as D
import Link exposing (link)
import Msg exposing (..)
import Url
import Url.Parser exposing ((</>), Parser, map, oneOf, parse, s, top)
import User.Model exposing (..)
import User.User exposing (..)


type Route
    = Index
    | Users
    | OneUser Int
    | Other
    | Unknown


routeParser : Parser (Route -> a) a
routeParser =
    oneOf
        [ map Index top
        , map Other (s "other")
        , map Users (s "users")
        , map OneUser (s "users" </> Url.Parser.int)
        ]


parseLocation : Url.Url -> Route
parseLocation url =
    case parse routeParser url of
        Just route ->
            route

        Nothing ->
            Unknown



---- MODEL ----


type alias Model =
    { key : Nav.Key
    , url : Url.Url
    , route : Route
    , text : String
    , users : Array User
    , count : Int
    }


init : flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    ( Model key url (parseLocation url) "" Array.empty 0
    , getUser
    )



---- UPDATE ----


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        route =
            parseLocation model.url
    in
    case msg of
        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            case url.path of
                "/users" ->
                    ( { model | url = url, route = parseLocation url, count = model.count + 1 }
                    , getUser
                    )

                _ ->
                    ( { model | url = url, route = parseLocation url }
                    , Cmd.none
                    )

        GotText (Err _) ->
            ( model, Cmd.none )

        GotText (Ok []) ->
            ( model, Cmd.none )

        GotText (Ok users) ->
            ( { model | users = Array.fromList users }, Cmd.none )



---- VIEW ----


view : Model -> Browser.Document Msg
view model =
    { title = "Hello App"
    , body =
        [ div []
            [ p [] [ text ("You are on the page: " ++ model.url.path) ]
            , nav []
                [ link "Home" "/"
                , link "Users" "/users"
                , link "Other" "/other"
                ]
            ]
        , case model.route of
            Index ->
                div []
                    [ h1 [] [ text "This is INDEX" ]
                    , img [ src "/logo.svg" ] []
                    ]

            Other ->
                p [] [ text "This is content from Other page" ]

            Users ->
                div [] (Array.toList (Array.map (\user -> p [] [ a [ href ("/users/" ++ String.fromInt user.id) ] [ text (String.fromInt user.id ++ " " ++ user.name) ] ]) model.users))

            OneUser int ->
                let
                    user =
                        getJustUser (Array.get (int - 1) model.users)

                    row string1 string2 =
                        tr []
                            [ td
                                [ style "text-align" "left"
                                , style "padding-right" "10px"
                                ]
                                [ text string1 ]
                            , td [ style "text-align" "right" ] [ text string2 ]
                            ]
                in
                    case user.id of
                        0 ->
                            p [] [ text "Unknown User" ]
                        _ ->
                            div [ style "display" "inline-block" ]
                                [ table []
                                    [ row "ID" (String.fromInt user.id)
                                    , row "Name" user.name
                                    , row "Username" user.username
                                    , row "Email" user.email
                                    , row "Phone" user.phone
                                    , row "Website" user.website

                            --         , p [] [ text ("ID: " ++ String.fromInt user.id) ]
                            --         , p [] [ text ("Name: " ++ user.name) ]
                            --         , p [] [ text ("Username: " ++ user.username) ]
                            --         , p [] [ text ("Email: " ++ user.email) ]
                            --         , p [] [ text ("Phone: " ++ user.phone) ]
                            --         , p [] [ text ("Website: " ++ user.website) ]
                                    ]
                                , nav []
                                    [ prevLink user.id
                                    , nextLink model user.id
                                    ]
                                ]
                            

            Unknown ->
                p [] [ text "Unknown Page" ]
        ]
    }

nextLink : Model -> Int -> Html Msg
nextLink model currentInt =
    let 
        len = Array.length model.users
    in
        if currentInt < len  then
            a [ href ("/users/" ++ (String.fromInt (currentInt + 1))) ] [ text "Next" ]
        else
            text ""

prevLink : Int -> Html Msg
prevLink int =
    if int > 1 then
        a [ href ("/users/" ++ (String.fromInt (int - 1))) ] [ text "Prev" ]
    else
        text ""


---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.application
        { view = view
        , init = init
        , update = update
        , subscriptions = always Sub.none
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }
