module Link exposing (link)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Msg exposing (..)


link : String -> String -> Html Msg
link txt url =
    a [ href url, class "mdc-button" ] [ text txt ]
