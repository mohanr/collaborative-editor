open Eio.Std

open Tui_types

module type STREAMER = sig
    val get_event_stream : unit -> key Eio.Stream.t
end

module EventStream = struct

  let stream = Eio.Stream.create 2 (* Configure *)

  let get_event_stream() =
    stream

  let handle_event() =
  Eio.Switch.run  @@ fun sw ->
       Fiber.fork ~sw
         (fun () ->
              let event = Eio.Stream.take stream in
              traceln "Got %d" event ;
              Fiber.yield ()
         )
end
