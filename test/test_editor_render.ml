open Collaborative_editor__Editorstate
open Collaborative_editor__Configurer_intf

let create_config_node () : (module Configurer)=

  let module Config = struct

   include MakeConfigurer
   let set_size x y =
      {
        width = x;
        height = y;
      }


  end in
  (module Config: Configurer )


let%expect_test "Render text in editor"=
let open Collaborative_editor__Textholder in
let open Collaborative_editor__Editorstate.EditorState in
let open Collaborative_editor__Tui_types in
let config = create_config_node () in
let module C = (val config : Configurer) in

   let string_text =
     Textholder.Text {
       self = "hello";
       text_length = String.length;
     }
    in
    let run state =
        let a, state = EditorState.make string_text state in
        let b, state = change_cursor_position a state 0 5 in
        (b, state)  in
      let init_state =
      {
          cursor_position = Some{ x = 1;y = 1 };
          buf =  Buffer.create 256;
          holder =  Textholder.make string_text ;
      } in
        let (c, _s) = run ({ next = init_state}) in
        match c with
      | {cursor_position = c  ; buf = _b; holder = _h} ->
        (match c with
        | Some l ->
        Printf.printf  "x = %d y = %d"  l.x l.y;
        | None -> ()
        );
    [%expect {| x = 0 y = 5 |}]
