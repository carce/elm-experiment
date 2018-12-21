module Msg exposing (Msg(..))

import Array exposing (..)
import Browser
import Http
import Url
import User.Model exposing (User)


type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotText (Result Http.Error (List User))
