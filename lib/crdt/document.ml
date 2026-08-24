open Types
open Containers
open Crdt

module Document = struct

type _ Effect.t += Effect_merger_error:  doc -> doc Effect.t

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
 (seq = 0 || check_version1 {agent = Some agent; seq = Some (seq - 1) }
                           doc_content.version)
 (* Left and Right should be present already *)
 && (match item.origin_left with
    | None -> true
    | Some _ -> check_version1 (get_identity item.origin_left) doc_content.version)
 && (match item.origin_right with
    | None -> true
    | Some _ -> check_version1 (get_identity item.origin_right) doc_content.version)

let increment key m =
  VersionMap.update key (function
    | None ->  Some (-1)         (* Key does not exist, start at 1 *)
    | Some v -> Some (v + 1) (* Key exists, increment value *)
  ) m

let merge_both  src_content dest_content =
Printf.printf " %d,  %d\n"
    (List.length src_content.doc_content)
    (List.length dest_content.doc_content);

  let get_item item =             (* Since I mapped to Option.t below *)
      (match item with | Some v -> v
                       | None -> failwith "Error in merge_both ")
  in
  let check_for_missing_content = (* What is this? *)
   List.filter ( fun item -> not (check_version1 item.id dest_content.version))
     src_content.doc_content |> List.map (fun v -> Some v) in
Printf.printf "src doc_content length: %d\n" (List.length src_content.doc_content);
   let missing_content_length = List.length check_for_missing_content  in
   Printf.printf " %d\n" missing_content_length;
  (* What is the length of this missing content ? *)

  let rec loop_while_outer doc i merged_count missing =
     Printf.printf "outer: i=%d, missing_len=%d, non_null=%d\n"
      i missing_content_length
      (List.length (List.filter Option.is_some missing));
    if i > 0 then(
      let count,l, l1 =
      let rec loop_while_inner  j merged_count l l1 =
       if j < missing_content_length then (
        let item = List.nth check_for_missing_content j in
        let valid =
          check_veracity_of_insertion (get_item item) dest_content
        in

        Printf.printf "Check = %b\n" valid;

        if not valid then

            loop_while_inner (j + 1) merged_count l l1
           else(
             let item_list = CRDTOp.Crdt_buffer.merge dest_content (get_item item )  in
             (* 'List' requires this inefficient function. Array ? *)
             let item = get_item item in
             let updated_version = increment (get_agent item.id) l1.version in
             let new_doc =
             {
               doc_content = item_list ;
               version = updated_version
             }
             in
             let l =
             List.concat (
                 List.mapi (fun i x ->
                   if i = j then [None] else [x]
                 ) l
               ) in
             loop_while_inner  (j + 1)
                               (merged_count + 1) l new_doc
           )
        ) else merged_count,l, l1
        in
             loop_while_inner
                                 0
                                 0
                                 check_for_missing_content
                                 doc
          in
          if count = 0 then
            Effect.perform (Effect_merger_error doc)
          else
            loop_while_outer l1 (i - 1) 0 l
    ) else doc
    in
      (match loop_while_outer (CRDTOp.Crdt_buffer.make ())  missing_content_length 0 check_for_missing_content  with
        | effect Effect_merger_error v, k -> let() = Printf.printf "Not merging properly"
                                                 in v
        | iteml -> iteml;
       )

end
