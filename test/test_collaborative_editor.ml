open Collaborative_editor__Configurer_intf.MakeConfigurer
open Collaborative_editor__Configurer_intf

let create_config_node () : (module Configurer)=
  let module Config = struct
   include MakeConfigurer
   let config = {
    width = 5;
    height = 5
   }
   let set_size() = config
  end in
  (module Config: Configurer )



let%expect_test _=
    Printf.printf "%s" "Terminal Driver";
    [%expect {| false |}]
