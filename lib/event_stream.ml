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
end

type _ Effect.t += ShowContent : doc ->  unit Effect.t

(*  TODO Make this reusable*)
module Ed : sig
    val init_state : string -> tui_editor_view
    val load_buffer : string -> tui_editor_view
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

  let update_data_in_buffer data =
     Ed.load_buffer data


let insert_local_doc i new_doc c =
    insert new_doc "Text" i c

  (* Effects for events/keystrokes *)
 let update_contents  doc (f : (key Eio.Stream.t -> key )) s =
   match f s  with
              | `ASCII c ->
                 (* let _ = log_m " Event picked up %c"  c in *)

                 let doc = insert_local_doc ((List.length doc.doc_content ) + 1) doc (Char.escaped c) in
                 Effect.perform (ShowContent doc )

let handle_event sw =
    let _ = log_m " handle_event"  in
    let open Core in

    let new_doc = make() in     (* Create 'doc' once *)
       Fiber.fork ~sw
         (fun () ->
          let rec loop doc  =
           let v =
              try
              (match  (update_contents  doc Eio.Stream.take  stream) with
              | effect ShowContent v, _k ->
                let merged_text =
                  List.map v.doc_content ~f:(fun item -> item.content)
                  |> String.concat ~sep:""
                  in
                    let _new_view = update_data_in_buffer merged_text  in
                    render();
                    Fiber.yield ();
                    v
              | key -> doc)
               with End_of_file -> doc
                  | exn -> let _ = log_m "%s" (Exn.to_string exn) in doc
            in
            loop v (* v is out of scope *)
          in
          loop new_doc
         )
end
