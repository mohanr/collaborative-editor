open Core
open Collaborative_editor__Types
open Collaborative_editor.Crdt.CRDTOp.Crdt_buffer


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
      ((content a) (id ((agent (Text)) (seq (0)))) (origin_left ())
       (origin_right ()) (deleted false))
      |}]

let insert  new_doc  pos c =
     insert new_doc "Text" pos c

let text_of doc =
  List.map doc.doc_content ~f:(fun item -> item.content)
  |> String.concat ~sep:""



let%expect_test "Merge two documents"=
    let new_doc = make() in
    let new_doc = insert new_doc 1 "a" in
    let new_doc1 = make() in
    let open Collaborative_editor__Document.Document in

    let new_doc1 = merge_both new_doc new_doc1 in

    List.iter new_doc1.doc_content ~f:(fun v ->
        Format.printf "%a" Sexp.pp_hum ([%sexp_of: item] v )) ;
    [%expect {|
      ((content a) (id ((agent (Text)) (seq (0)))) (origin_left ())
       (origin_right ()) (deleted false))
      |}];
      let merged_content = insert new_doc 2 "b" in
      let merged_content = insert merged_content 1 "c" in
      let merged_doc = merge_both merged_content new_doc1 in
      let merged_text =
        List.map merged_doc.doc_content ~f:(fun item -> item.content)
        |> String.concat ~sep:" "
      in
      List.iter merged_doc.doc_content ~f:(fun v ->
        Format.printf "%a\n" Sexp.pp_hum ([%sexp_of: item] v ))
        ;
      assert (String.equal merged_text "c a b");
      Format.printf "\n%s" merged_text;
      [%expect {|
        ((content c) (id ((agent (Text)) (seq (2)))) (origin_left ())
         (origin_right (((agent (Text)) (seq (0))))) (deleted false))
        ((content a)
                                                                       (id
                                                                        ((agent
                                                                          (Text))
                                                                         (seq (0))))
                                                                       (origin_left
                                                                        ())
                                                                       (origin_right
                                                                        ())
                                                                       (deleted
                                                                        false))

        ((content b) (id ((agent (Text)) (seq (1))))
         (origin_left (((agent (Text)) (seq (0))))) (origin_right ())
         (deleted false))

        c a b
        |}];
        VersionMap.iter (fun k v ->
        Format.printf "%a %a\n" Sexp.pp_hum ([%sexp_of: string] k )
           Sexp.pp_hum ([%sexp_of: int] v )) merged_doc.version;
        (* print_s [%sexp (some_map : int Int.Map.t)] *)

  [%expect {| Text 2 |}]

let%expect_test "concurrent insertion "=
  let new_doc = make () in

  let make_item agent seq content =
    {
      content;
      id = { agent = Some agent; seq = Some seq };
      origin_left = None;
      origin_right = None;
      deleted = false;
    }
  in

  let item1 = make_item "Text0" 0 "A" in
  let item2  = make_item "Text1" 0 "B" in

  let doc1 = { new_doc with doc_content = [item1] } in
  let result1 = merge doc1 item2   in

  let doc2 = { new_doc with doc_content = [item2] } in
  let result2 = merge doc2 item1   in

  let contents items =
        List.map items ~f:(fun item -> item.content)
        |> String.concat ~sep:" "
  in


  Printf.printf " %s\n" (contents result1);
  Printf.printf " %s\n" (contents result2);
  [%expect {|
    A B
    A B
    |}]
