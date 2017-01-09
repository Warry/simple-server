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
