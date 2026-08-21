open Types

module Document = struct
  (* Parameters are 'identity' and VersionMap *)
let check_version id version =
   let agent, seq = id in
    (* What is the highest sequence ? *)
              let highest_seq =
                (match (VersionMap.find_opt agent version) with
                           | Some v -> v >= seq
                           | None -> false
                           )
              in highest_seq
(* let merge src_content dest_content = *)

end
