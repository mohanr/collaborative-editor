open Eio.Std
open Logger.Logger
open Tui_types

module type STREAMER = sig
    val get_event_stream : unit -> key Eio.Stream.t
    val handle_event : Eio.Switch.t -> unit
end

type _ Effect.t += ShowContent : key -> unit Effect.t

module EventStream :  STREAMER= struct
  let stream = Eio.Stream.create 20 (* Configure *)

  let get_event_stream() =
    stream

  (* Effects for events/keystrokes *)
 let update_contents (f : (key Eio.Stream.t -> key )) s =
   match f s  with
              | `ASCII c ->
               Effect.perform (ShowContent (`ASCII c :> key))

  let handle_event sw =
  let _ = log_m " handle_event"  in

       Fiber.fork ~sw
         (fun () ->
          let rec loop () =
              try
              match  (update_contents  Eio.Stream.take  stream) with
              | effect ShowContent v, _k ->
               (match v with
               | `ASCII c ->
                let _ = log_m " Event picked up %c"  c in ());
                Fiber.yield ();
              | key -> ();
              loop ()
               with End_of_file -> ()
                  | exn -> let _ = log_m "%s" (Printexc.to_string exn) in ();
          loop ()
          in
          loop ()
         )
end
