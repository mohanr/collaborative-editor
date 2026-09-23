open Configurer_intf


let get_server_urlmap  (m : (module  Node )) =
  let module M = (val m : Node ) in
  M.cap_id_map

let get_env  (m : (module  Node )) =
  let module M = (val m : Node ) in
  M.env

module Make(N:Node)  = struct

  include MakeConfigurer


  let set_config() =


  let conf = {

       other_nodes = get_server_urlmap  (module N) ;

       env = get_env (module N)

     } in conf

 end
