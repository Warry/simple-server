module Server
    exposing
        ( Server
        , Request
        , Response
        , Error
        , IncomingRequest
        , OutgoingRequest
        , server
        )

{-|

@docs Server, server, Request, Response, Error, IncomingRequest, OutgoingRequest

# The hello world server:

```elm
port module Main exposing (..)

import Server exposing (..)
import Task exposing (Task)
import Json.Encode exposing (Value, string, null)


handler : Request -> Task Error Response
handler { headers, method, url } =
    Task.succeed
        { headers = null
        , status = 200
        , body = string "hello, world!"
        }


main : Server
main =
    server
        incomingRequest
        outgoingRequest
        handler


port incomingRequest : (IncomingRequest -> msg) -> Sub msg
port outgoingRequest : OutgoingRequest -> Cmd msg
```

-}

-- IMPORTS

import Json.Encode as JE exposing (Value)
import Json.Decode
import Task exposing (Task)


-- HTTP HANDLER


handler : Request -> Task Error Response
handler { headers, method, url } =
    Task.succeed
        { headers = JE.null
        , status = 200
        , body = JE.string "hello, world!"
        }



-- LOGIC


server :
    ((( Callback, Request ) -> Msg) -> Sub Msg)
    -> (( Callback, Response ) -> Cmd Msg)
    -> (Request -> Task Error Response)
    -> Server
server inbound outbound handler =
    Platform.program
        { init = ( (), Cmd.none )
        , update = update handler outbound
        , subscriptions = always (inbound In)
        }


update :
    (Request -> Task Error Response)
    -> (( Callback, Response ) -> Cmd Msg)
    -> Msg
    -> a
    -> ( (), Cmd Msg )
update handler outbound msg _ =
    case msg of
        In ( callback, req ) ->
            ( ()
            , Task.perform
                Out
                (Task.map ((,) callback) (Task.onError errorResponse (handler req)))
            )

        Out res ->
            ( (), outbound res )


errorResponse : Error -> Task Never Response
errorResponse err =
    Task.succeed
        { headers = JE.null
        , status = 500
        , body = JE.string err
        }



-- TYPES


type alias Request =
    { headers : Value
    , method : String
    , url : String
    }


type alias Response =
    { headers : Value
    , status : Int
    , body : Value
    }


type alias Error =
    String


type Msg
    = In ( Callback, Request )
    | Out ( Callback, Response )


type alias Callback =
    Value


type alias IncomingRequest =
    ( Callback, Request )


type alias OutgoingRequest =
    ( Callback, Response )


type alias Server =
    Program Never () Msg
