open Collaborative_editor__Configurer_intf.MakeConfigurer
open Collaborative_editor__Configurer_intf
open Collaborative_editor.Crdt.CRDTOp.Crdt_buffer

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



let%expect_test "Insert one character"=
    let open Collaborative_editor__Types in
    let pos = 1 in
    let items = [({
         content = "Text";
         id = { agent = Some "T"; seq = Some 1 };
         origin_left = None;
         origin_right = None;
         deleted = false
    })]
    in
         let origin_l = List.nth items pos in
         let origin_r = List.nth items pos in
    let item = {
         content = "Text";
         id = { agent = Some "T"; seq = Some 1 };
         origin_left = Some origin_l.id;
         origin_right = Some origin_r.id;
         deleted =  false
    } in
    let _ = merge items item in
    Printf.printf "%s" "Terminal Driver";
    [%expect {| Collaborative EditorTerminal Driver |}]
