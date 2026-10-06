open Eio.Std
open Logger.Logger
open Tui_types
open Crdt.CRDTOp.Crdt_buffer
open Buffer
open Configurer
open Types
open Widget.Renderer
open Editorstate
open Editorcontext

module type STREAMER = sig
    val get_event_stream : unit -> key Eio.Stream.t
    val handle_event : Eio.Switch.t -> unit
    val get_data_buffer :  unit -> B.t
end

type _ Effect.t += ShowContent : string ->  unit Effect.t

(*  TODO Make this reusable*)
module Ed : sig
    val init_state : string -> tui_editor_view
  end = EditorContext (EditorState)
(*  TODO Make this reusable*)
module C : Configurer_intf.Configurer = struct
  include Configurer_intf.MakeConfigurer
  let set_size width height = { width; height }
end
module A = Area
module B = Buffer(A)
module BF = BufferManipulator (C) (B)

module EventStream :  STREAMER= struct
  let stream = Eio.Stream.create 20 (* Configure *)

  let get_event_stream() =
    stream

  let data_buffer = ref (BF.make_buffer())

  let get_data_buffer() = !data_buffer

  let update_data_in_buffer data =
    match !data_buffer  with
    | {area = _; contents = c} ->
        {!data_buffer with contents =
                            let b = Stdlib.Buffer.create 256 in
                            let () = Stdlib.Buffer.add_string b data in b }


let insert_local_doc c =
    let new_doc = make() in
    insert new_doc "Text" 1 c

  (* Effects for events/keystrokes *)
 let update_contents (f : (key Eio.Stream.t -> key )) s =
   let open Core in
   match f s  with
              | `ASCII c ->
                 let _ = log_m " Event picked up %c"  c in
                 let doc = insert_local_doc  (Char.escaped c) in
                let merged_text =
                  List.map doc.doc_content ~f:(fun item -> item.content)
                  |> String.concat ~sep:" "
                in
                 Effect.perform (ShowContent merged_text )

  let handle_event sw =
  let _ = log_m " handle_event"  in

       Fiber.fork ~sw
         (fun () ->
          let rec loop () =
              (try
              (match  (update_contents  Eio.Stream.take  stream) with
              | effect ShowContent v, _k ->
                    data_buffer := update_data_in_buffer v;
                    render();
                     let _view = Ed.init_state "" in
                    Fiber.yield ()
              | key -> ());
               with End_of_file -> ()
                  | exn -> let _ = log_m "%s" (Printexc.to_string exn) in ());
               loop ()
          in
          loop ()
         )
end
