open Service
open Logger.Logger
(* https://www.youtube.com/watch?v=HNLSyxN-rPE *)

module MergeApi = Merge.MakeRPC(Capnp_rpc_lwt)

module Client = struct
let mergedoc service doc =
         let open Lwt.Infix in
         let open MergeApi.Reader in
         let result = MergeClient.mergedoc service doc in
         result >>=fun reply ->
         (* let l =  (reply :> (Merge.rw, 'a, 'b) Capnp__InnerArray.t) in *)
         let (item_list, version) = reply in
         let items = Capnp.Array.fold item_list~init:[]
                    ~f:(fun acc i ->
                        (Item.content_get i) :: acc
                     )   in
         Lwt.return items


end
