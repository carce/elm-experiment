module User.User exposing (getJustUser, getUser, userDecoder, userListDecoder)

import Http
import Json.Decode as D
import Msg as Main
import User.Model exposing (User)


getUser : Cmd Main.Msg
getUser =
    Http.send Main.GotText (Http.get "https://jsonplaceholder.typicode.com/users" userListDecoder)


userListDecoder : D.Decoder (List User)
userListDecoder =
    D.list userDecoder


userDecoder : D.Decoder User
userDecoder =
    D.map6 User
        (D.field "id" D.int)
        (D.field "name" D.string)
        (D.field "username" D.string)
        (D.field "email" D.string)
        (D.field "phone" D.string)
        (D.field "website" D.string)


getJustUser : Maybe User -> User
getJustUser user =
    case user of
        Just juser ->
            juser

        Nothing ->
            User 0 "" "" "" "" ""
