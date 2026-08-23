open Collaborative_editor__Configurer_intf.MakeConfigurer
open Collaborative_editor__Configurer_intf
open Collaborative_editor.Crdt.CRDTOp.Crdt_buffer
open Eio.Std
open Effect.Deep
open Core
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
    let new_doc = make() in
    let pos = 1 in
    let merged_content = insert
                       new_doc
                       "Text"
                       pos
                       "a"
                       in
    (* let rec loop_while  l = *)
    (* (match l  with *)
    (*         | hd :: tl-> (\* Printf.printf "%s" hd.content; *\) *)
    (*                      loop_while tl *)
    (*         |[] -> ()) *)
    (* in loop_while  merged_content; *)
    Printf.printf "There are %d items/Position is %d\n" (List.length merged_content) pos;
    List.iter merged_content ~f:(fun v ->
        Format.printf "%a" Sexp.pp_hum ([%sexp_of: item] v )) ;
    [%expect {|
      Catch exception and perform effect
      Catch exception and perform effect
       0
      There are 1 items/Position is 1
      ((content a) (id ((agent (Text)) (seq (0)))) (origin_left ())
       (origin_right ()) (deleted false))
      |}]

let%expect_test "Merge two documents"=
    let new_doc = make() in
    let pos = 1 in
    let merged_content = insert
                       new_doc
                       "Text"
                       pos
                       "a"
                       in
    let new_doc = { new_doc with doc_content = merged_content } in
    Printf.printf "There are %d items/Position is %d\n"
      (List.length merged_content) pos;
    List.iter merged_content ~f:(fun v ->
        Format.printf "%a" Sexp.pp_hum ([%sexp_of: item] v )) ;
    [%expect {|
      Catch exception and perform effect
      Catch exception and perform effect
       0
      There are 1 items/Position is 1
      ((content a) (id ((agent (Text)) (seq (0)))) (origin_left ())
       (origin_right ()) (deleted false))
      |}];
    let new_doc1 = make() in
    let pos = 1 in
    let merged_content1 = insert
                       new_doc1
                       "Text1"
                       pos
                       "a"
                       in
    let new_doc1 = { new_doc1 with doc_content = merged_content1 } in
    Printf.printf "There are %d items/Position is %d\n" (List.length merged_content) pos;
    List.iter merged_content1 ~f:(fun v ->
        Format.printf "%a" Sexp.pp_hum ([%sexp_of: item] v )) ;
    [%expect {|
      Catch exception and perform effect
      Catch exception and perform effect
       0
      There are 1 items/Position is 1
      ((content a) (id ((agent (Text1)) (seq (0)))) (origin_left ())
       (origin_right ()) (deleted false))
      |}];
    let open Collaborative_editor__Document.Document in

    let merged_doc = merge_both new_doc new_doc1 in

    List.iter merged_doc ~f:(fun v ->
        Format.printf "%a" Sexp.pp_hum ([%sexp_of: item] v )) ;
    [%expect {|
       1,  1
      src doc_content length: 1
       1
      outer: i=1, missing_len=1, non_null=1
      Check = true
       1
      a a
      outer: i=0, missing_len=1, non_null=0
      ((content a) (id ((agent (Text)) (seq (0)))) (origin_left ())
       (origin_right ()) (deleted false))((content a)
                                          (id ((agent (Text1)) (seq (0))))
                                          (origin_left ()) (origin_right ())
                                          (deleted false))
      |}]
