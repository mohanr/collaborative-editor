open Types

module Document = struct

    let get_seq identity =
      (match identity.seq with | Some v -> v
                                 | None -> failwith "Error in get_seq ")
    let get_agent identity =
      (match identity.agent with | Some v -> v
                                 | None -> failwith "Error in get_agent ")
    let get_identity identity =
      (match identity with | Some v -> v
                           | None -> failwith "Error in get_identity ")
  (* Parameters are 'identity' and VersionMap *)
let check_version1 id version =
   let agent = get_agent id in
   let seq = get_seq  id in
    (* What is the highest sequence ? *)
              let highest_seq =
                (match (VersionMap.find_opt agent version) with
                           | Some v -> v >= seq
                           | None -> false
                           )
              in highest_seq

(* TODO What are the checks ? *)
let check_veracity_of_insertion item doc_content =
   let agent = get_agent item.id in
   let seq = get_seq  item.id in
 not (check_version1 item.id doc_content.version) &&
 (seq = 0 && check_version1 {agent = Some agent; seq = Some (seq - 1) }
                           doc_content.version)
 (* Left and Right should be present already *)
 && (check_version1 (get_identity item.origin_left) doc_content.version)
 && (check_version1 (get_identity item.origin_right) doc_content.version)
(* let merge src_content dest_content = *)

end
