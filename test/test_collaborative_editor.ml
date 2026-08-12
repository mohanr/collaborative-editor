open Collaborative_editor__Configurer_intf.MakeConfigurer
open Collaborative_editor__Configurer_intf
open Collaborative_editor.Crdt.CRDTOp.Crdt_buffer
open Eio.Std
open Effect.Deep
open Collaborative_editor__Types

let create_config_node () : (module Configurer)=

  let module Config = struct

   include MakeConfigurer
   (* Default ? *)
   let config = {
    width = 5;
    height = 5
   }

   let set_size w h =
    {
    width = w;
    height =h;
   }


  end in
  (module Config: Configurer )

(* Demonstration of how effects could be used. *)
(* But simpler primitives instead of effects are recommended *)
type _ eff += Failure : string -> item eff

let get_safe_list_elt doc pos  =
  try

    List.nth doc.doc_content pos

  with Failure arg ->
    Effect.perform (Failure arg )

let get_left_or_right_elt doc pos =

   match get_safe_list_elt doc pos with

   | item -> Some item.id

   | effect Failure s, k ->

   Printf.printf "Catch exception and perform effect\n";
   None

let%expect_test "Insert one character"=
    let open Collaborative_editor__Types in
    let new_doc = make() in
    let pos = 1 in
    let item = {
         content = "a";
         id = { agent = Some "Text"; seq = Some 1 };
         origin_left = get_left_or_right_elt new_doc  (pos - 1);
         origin_right = get_left_or_right_elt new_doc pos;
         deleted = false
    } in
    let doc_content = merge new_doc.doc_content item in
    let rec loop_while  l =
    (match l  with
            | hd :: tl-> Printf.printf "%s" hd.content;
                         loop_while tl
            |[] -> ())
    in loop_while  doc_content;
    Printf.printf "There are %d items/Position is %d\n" (List.length doc_content) pos;
    [%expect {|
      Catch exception and perform effect
      Catch exception and perform effect
      There are 0 items/Position is 1
      |}];
  [%expect {| |}]
