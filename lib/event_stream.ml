open Eio.Std

open Tui_types

module type STREAMER = sig
    type key = [ | `ASCII of char ]
    val get_event_stream : unit -> key Eio.Stream.t
end

module EventStream :  STREAMER= struct

  type key = [ | `ASCII of char ]
  let stream = Eio.Stream.create 2 (* Configure *)

  let get_event_stream() =
    stream

  let handle_event() =
  Eio.Switch.run  @@ fun sw ->
       Fiber.fork ~sw
         (fun () ->
              let event = Eio.Stream.take stream in
              Fiber.yield ()
         )
end
