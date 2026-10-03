open Eio.Std
open Logger.Logger
open Tui_types

module type STREAMER = sig
    val get_event_stream : unit -> key Eio.Stream.t
    val handle_event : Eio.Switch.t -> unit
end

module EventStream :  STREAMER= struct
  let stream = Eio.Stream.create 20 (* Configure *)

  let get_event_stream() =
    stream

  let handle_event sw =
  let _ = log_m " handle_event"  in

       Fiber.fork ~sw
         (fun () ->
          let rec loop () =
              try
              let event = Eio.Stream.take stream in
              match (event :> key)  with
              | `ASCII  key ->
               let _ = log_m " Event picked up %c"  key  in
              Fiber.yield ();
              loop ()
               with End_of_file -> ()
                  | exn -> let _ = log_m "%s" (Printexc.to_string exn) in ();
          loop ()
          in
          loop ()
         )
end
