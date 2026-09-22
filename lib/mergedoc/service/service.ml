open Capnp_rpc_lwt
open Lwt.Infix
open Collaborative_editor.Types

module MergeApi = Merge.MakeRPC(Capnp_rpc_lwt)

module MergeService (CRDTOp : CRDTOperator ) = struct

let merge_local =
  let module Merge= MergeApi.Service.MergeDoc in
  Merge.local @@ object
    inherit Merge.service

    method mergedoc_impl params release_param_caps =
      release_param_caps ();
      let open MergeApi.Reader in
      let open MergeApi.Reader.MergeDoc.Mergedoc in
      let extract_item item_list =
        let id i =
          let identity = Item.id_get i in
          {
            agent = Some (Ident.agent_get identity) ;
            seq = Some (Ident.seq_get identity) ;
          }
        in
        let il =
                    List.fold_left
                    (fun acc i ->
                      {
                        content =Item.content_get i;
                        id = id i;
                        origin_left =
                                            (
                                             match IdentityU.Message.get (IdentityU.message_get
                                                                           (Item.originleft_get i)) with
                                                IdentityU.Message.Someidentity identity ->

                                                   Some(
                                                     {
                                                       agent = Some (
                                                                match AgentU.Message.get (AgentU.message_get(
                                                                  Identity.agent_get identity)) with
                                                               | Someagent s -> s
                                                               | Noneagent -> String.empty
                                                               | _ -> failwith "origin left is missing"
                                                               ) ;
                                                       seq = Some (
                                                                match SeqU.Message.get (SeqU.message_get(
                                                                  Identity.seq_get identity)) with
                                                               | Someseq s -> s
                                                               | Noneseq -> 0
                                                               | _ -> failwith "origin right is missing"
                                                               ) ;
                                                     }
                                                   )
                                              | IdentityU.Message.Noneidentity  -> None
                                              | _ -> failwith "origin left is missing"
                                            );
                        origin_right =
                                            (
                                             match IdentityU.Message.get (IdentityU.message_get
                                                                           (Item.originleft_get i)) with
                                                IdentityU.Message.Someidentity identity ->
                                                   Some(
                                                     {
                                                       agent = Some (
                                                                match AgentU.Message.get (AgentU.message_get(
                                                                  Identity.agent_get identity)) with
                                                               | Someagent s -> s
                                                               | Noneagent -> String.empty
                                                               | _ -> failwith "origin right is missing"
                                                               ) ;
                                                       seq = Some (
                                                                match SeqU.Message.get (SeqU.message_get(
                                                                  Identity.seq_get identity)) with
                                                               | Someseq s -> s
                                                               | Noneseq -> 0
                                                               | _ -> failwith "origin right is missing"
                                                               ) ;
                                                     }
                                                   )
                                              | IdentityU.Message.Noneidentity  -> None
                                              | _ -> failwith "Origin left is missing"
                                            );
                        deleted = false; (* Not used now *)
                      }
                     :: acc) [] item_list
        in il
      in
      let _item_list = extract_item (Params.itemlist_get_list params) in
      let doc_content = Params.doccontent_get_list params in
      let new_map = VersionMap.empty in
      let _version_map =
                  List.fold_left
                  (fun acc kv -> VersionMap.add
                      (VersionTuple.key_get kv)
                      (VersionTuple.value_get kv)
                      acc)
                  new_map
                  doc_content in
      let response, results = Service.Response.create
          MergeApi.Service.MergeDoc.Mergedoc.Results.init_pointer in
      (* Call the service *)
      let _ = MergeApi.Service.MergeDoc.Mergedoc.Results.itemlist_set_list  results [] in
      let _ = MergeApi.Service.MergeDoc.Mergedoc.Results.doccontent_set_list  results [] in
      Service.return response

end
end

module MergeClient = struct
module Merge = MergeApi.Client.MergeDoc.Mergedoc

(** [foo_set_list s v] sets the content of field [foo] from OCaml list [v].
    (This may result in reallocation of [foo], which may lead to poor
    performance.)

    @return a reference to the content of field [foo]

    @raise Message.Invalid_message if the message is ill-formatted *)
(* val foo_set_list : t -> Inner.t list -> (rw, Inner.t, 'b) Capnp.Array.t *)

let mergedoc t doc =
  let open Merge in
  let request, params = Capability.Request.create Params.init_pointer in
  let _ = MergeApi.Builder.MergeDoc.Mergedoc.Params.itemlist_set_list params []
  in
  let _ = MergeApi.Builder.MergeDoc.Mergedoc.Params.doccontent_set_list params []
  in
  Capability.call_for_value_exn t method_id request >|=
   Merge.Results.itemlist_get
end
