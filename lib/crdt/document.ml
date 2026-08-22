open Types
open Containers
open Crdt

module Document = struct

type _ Effect.t += Effect_continue :  unit -> unit Effect.t

type item_array =
    (item Option.t) CCArray.t
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

let merge_both  src_content dest_content =
  let get_item item =             (* Since I mapped to Option.t below *)
      (match item with | Some v -> v
                       | None -> failwith "Error in merge_both ")
  in
  let check_for_missing_content = (* What is this? *)
   List.filter ( fun item -> check_version1 item.id src_content.version )
     src_content.doc_content |> List.map (fun v -> Some v) in
   let missing_content_length = List.length check_for_missing_content  in
  (* What is the length of this missing content ? *)

  let rec loop_while_outer i merged_count =
    if i > 0 then(
      let count =
      let rec loop_while_inner  j merged_count l  =
       if i < j then (
        let item = List.nth check_for_missing_content i in
           if not (check_veracity_of_insertion (get_item item ) dest_content) then
            loop_while_inner j merged_count l
           else(
             let _item_list = CRDTOp.Crdt_buffer.merge dest_content (get_item item )  in
             (* 'List' requires this inefficient function. Array ? *)
             let l =
             List.concat (
                 List.mapi (fun i x ->
                   if i = j then [None] else [x]
                 ) check_for_missing_content
               ) in
             loop_while_inner  (missing_content_length - 1)
                               (merged_count + 1) l
           )
        ) else merged_count
        in
             loop_while_inner    missing_content_length
                                       0
                                       check_for_missing_content
          in
          if count = 0 then
            Effect.perform (Effect_continue ())
          else
            loop_while_outer (i - 1) missing_content_length
    ) else ()
    in
      (match loop_while_outer   (List.length check_for_missing_content) 0  with
        | effect Effect_continue (), k -> Printf.printf "Effect_continue ";
        | _ -> Printf.printf "All are handled by effects";
       )

end
