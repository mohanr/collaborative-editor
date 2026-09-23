open Service
(* https://www.youtube.com/watch?v=HNLSyxN-rPE *)
open Merge

module MergeApi = Merge.MakeRPC(Capnp_rpc_lwt)

module Client = struct
let mergedoc service =
         let open Lwt.Infix in
         let open MergeApi.Reader in
         let result = MergeClient.mergedoc service [] in
         result >>=fun reply ->
         (* let l =  (reply :> (Merge.rw, 'a, 'b) Capnp__InnerArray.t) in *)

         let _ = Capnp.Array.fold reply  ~init:[]
                    ~f:(fun acc i ->
                        Printf.printf "%s" (Item.content_get i);
                        (Item.content_get i) :: acc
                     )   in
         Lwt.return_unit


end
