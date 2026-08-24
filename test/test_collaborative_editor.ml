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
    List.iter merged_content.doc_content ~f:(fun v ->
        Format.printf "%a" Sexp.pp_hum ([%sexp_of: item] v )) ;
    [%expect {|
      Catch exception and perform effect
      Catch exception and perform effect
       0
      ((content a) (id ((agent (Text)) (seq (0)))) (origin_left ())
       (origin_right ()) (deleted false))
      |}]

let insert  new_doc  pos c =
     insert new_doc "Text" pos c

let%expect_test "Merge two documents"=
    let new_doc = make() in
    let new_doc = insert new_doc 1 "a" in
    List.iter new_doc.doc_content ~f:(fun v ->
        Format.printf "%a" Sexp.pp_hum ([%sexp_of: item] v )) ;
    [%expect {|
      Catch exception and perform effect
      Catch exception and perform effect
       0
      ((content a) (id ((agent (Text)) (seq (0)))) (origin_left ())
       (origin_right ()) (deleted false))
      |}];
    let new_doc1 = make() in
    let open Collaborative_editor__Document.Document in

    let new_doc1 = merge_both new_doc new_doc1 in

    List.iter new_doc1.doc_content ~f:(fun v ->
        Format.printf "%a" Sexp.pp_hum ([%sexp_of: item] v )) ;
    [%expect {|
       1,  0
      src doc_content length: 1
       1
      outer: i=1, missing_len=1, non_null=1
      Check = true
       0
      outer: i=0, missing_len=1, non_null=0
      ((content a) (id ((agent (Text)) (seq (0)))) (origin_left ())
       (origin_right ()) (deleted false))
      |}];
      let merged_content = insert new_doc 2 "b" in
      let new_doc = { new_doc1 with doc_content = merged_content.doc_content } in
      let merged_content = insert new_doc 1 "c" in
      let new_doc = { new_doc with doc_content = merged_content.doc_content } in
      let merged_doc = merge_both new_doc new_doc1 in
      List.iter merged_doc.doc_content ~f:(fun v ->
        Format.printf "%a" Sexp.pp_hum ([%sexp_of: item] v )) ;
      [%expect {|
        Catch exception and perform effect
        Catch exception and perform effect
         1
        a b
         2
        b c
        a c
         3,  1
        src doc_content length: 3
         3
        outer: i=3, missing_len=3, non_null=3
        Check = false
        Check = false
        Check = true
         1
        a a
        outer: i=2, missing_len=3, non_null=2
        Check = false
        Check = false
        Check = true
         1
        a a
        outer: i=1, missing_len=3, non_null=2
        Check = false
        Check = false
        Check = true
         1
        a a
        outer: i=0, missing_len=3, non_null=2
        ((content a) (id ((agent (Text)) (seq (0)))) (origin_left ())
         (origin_right ()) (deleted false))((content a)
                                            (id ((agent (Text)) (seq (0))))
                                            (origin_left ()) (origin_right ())
                                            (deleted false))
        |}];
