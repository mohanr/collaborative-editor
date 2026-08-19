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
let%expect_test "Insert one character"=
    let open Collaborative_editor__Types in
    let open Core in
    let new_doc = make() in
    let pos = 1 in
    let merged_content = insert
                       new_doc
                       "Text"
                       pos
                       "a"
                       in
    let rec loop_while  l =
    (match l  with
            | hd :: tl-> (* Printf.printf "%s" hd.content; *)
                         loop_while tl
            |[] -> ())
    in loop_while  merged_content;
    Printf.printf "There are %d items/Position is %d\n" (List.length merged_content) pos;
    List.iter merged_content ~f:(fun v ->
        Format.printf "%a" Sexp.pp_hum ([%sexp_of: item] v )) ;
    [%expect {|
      Catch exception and perform effect
      Catch exception and perform effect
       0
      There are 1 items/Position is 1
      ((content a) (id ((agent (Text)) (seq (1)))) (origin_left ())
       (origin_right ()) (deleted false))
      |}];
  [%expect {| |}]
