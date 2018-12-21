module User.Model exposing (User)


type alias User =
    { id : Int
    , name : String
    , username : String
    , email : String
    , phone : String
    , website : String
    }
