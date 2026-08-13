open Types
open Eio.Std
open Effect.Deep
(* https://xavierleroy.org/CdF/2023-2024/5.pdf *)
module Crdt = struct

  module Crdt_buffer = struct

   exception Version_error of string

   type _ eff += Failure : string -> item eff

   let get_safe_list_elt doc pos  =
     try

       List.nth doc.doc_content pos

     with Failure arg ->
       Effect.perform (Failure arg )

   let get_left_or_right_elt doc pos =

      match get_safe_list_elt doc pos with

      | item -> Some item.id

      | effect Failure s, k ->

      Printf.printf "Catch exception and perform effect\n";
      None


    type _ Effect.t += Early_return :  int -> int Effect.t
    let make() =
      {
        doc_content = [];
        version = VersionMap.empty
      }

    let content c =
      let list  = List.filter (fun item ->
                               Bool.equal  item.deleted false) c in
      let contents =
            let rec loop_while l1 l2 =
            match l2 with
                   | {content = c;_}:: tl->
                    loop_while ( l1 @ [c]) tl
                   | [] -> l1
            in loop_while [] list
     in contents

    (*TODO Both 'id' and 'new_item' are passed  *)
    let find_index doc_content id new_item =
       let id_found = List.find_mapi (fun i item ->
                        if ((compare_identity item.id new_item.id  ) = 0) then
                           Some ( i, item )
                        else None
                        ) doc_content  in
       (match id_found with
       | Some ( index , item ) -> index
       | None -> -1 (* failwith "Not found" *)
       )
    (* Example effect handler *)
    (* let tree_enum (type elt) : elt tree -> elt enum = *)
         (* let module Inv = struct *)
         (* type _ eff += Next : elt -> unit eff *)
         (* let tree_enum (t: elt tree) : elt enum = *)
         (* match tree_iter (fun x -> perform (Next x)) t with *)
         (* | () -> Done *)
         (* | effect Next x, k -> More(x, fun () -> continue k ()) *)
         (* end in *)
         (* Inv.tree_enum *)
    let check_version doc new_item =

      let identity = new_item.id in
      let agent = (match identity.agent with
                 | Some v -> v
                 | None -> raise (Version_error "CRDT error")
                 ) in
      let version_option =                   (* CCMap *)
        VersionMap.find_opt agent doc.version in
      let seq = (match version_option with
                 | Some v -> v + 1
                 | None -> 0
                 )
      in seq

    let merge doc new_item =

      let _version =  check_version doc new_item in

      let left_index  = (find_index doc.doc_content new_item.id new_item) + 1 in
            let right = (match new_item.origin_left with
                         | Some id ->
                           find_index doc.doc_content id new_item
                         | None -> List.length doc.doc_content
                        )
            in
            let rec loop_while i idx scanning =
              let idx =
              if not scanning then
                i
              else
                idx in

                if i = List.length doc.doc_content || i = right then
                  Effect.perform ( Early_return  idx)
                else(
                  let other = List.nth doc.doc_content i in
                  let other_left =
                           find_index doc.doc_content other.origin_left new_item
                  in
                  let other_right =
                  (match other.origin_right with
                               | Some value ->
                                find_index doc.doc_content other.origin_right new_item
                               | None -> List.length doc.doc_content)
                  in
                  if ( other_left < left_index ) || ((other_left = left_index) &&
                                               (other_right= right) &&
                                               ( new_item.id.agent = other.id.agent)) then

                    Effect.perform ( Early_return  idx)
                  else(
                       loop_while (i + 1) idx
                         (if other_left = left_index then
                            other_right < right
                         else
                            scanning)
                  )
        )
        in
         Printf.printf " %d\n" (List.length doc.doc_content);
        (match loop_while  0 left_index false with
        | effect Early_return idx, k ->
          if idx = List.length doc.doc_content then
           doc.doc_content @ [new_item]
          else
           List.concat (
               List.mapi (fun i x ->
                 Printf.printf "%s %s\n" x.content new_item.content;
                 if i = idx then [new_item; x] else [x]
               ) doc.doc_content
             )
        | _ -> Printf.printf "All are handled by effects";
               doc.doc_content
       )

    let insert doc agent pos text seq =
    let item = {
         content = text;
         id = { agent = agent ; seq = seq  };
         origin_left = get_left_or_right_elt doc  (pos - 1);
         origin_right = get_left_or_right_elt doc pos;
         deleted = false
       } in
    merge doc item
    end

end

module CRDTOp = Crdt
