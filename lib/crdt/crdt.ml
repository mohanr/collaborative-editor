open Types
open Eio.Std
open Effect.Deep
(* https://xavierleroy.org/CdF/2023-2024/5.pdf *)
module Crdt = struct

  module Crdt_buffer = struct

    type _ Effect.t += Early_return :  int -> int Effect.t
    let make() =
      {
        doc_content = []
      }

    let content c =
      let list  = List.filter (fun item ->
              (match item with
              | Item i ->
                  Bool.equal  i.deleted false
              | Empty -> failwith "Empty")) c in
      let contents =
            let rec loop_while l1 l2 =
            match l2 with
            | hd :: tl->
              (match hd with
              | Item i ->
                (match i with
                   | {content = c;_}->
                    loop_while ( l1 @ [i.content]) tl
                )
              | Empty ->
                    loop_while l1 tl
              )

            | [] -> l1
            in loop_while [] list
     in contents

    let find_index doc_content id new_item =
       let id_found = List.find_mapi (fun i item ->
                        if ((compare_identity item.id new_item.id  ) = 0) then
                           Some ( i, item )
                        else None
                        ) doc_content  in
       (match id_found with
       | Some ( right_index , item ) -> right_index
       | None -> -1
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

    let merge doc_content new_item =
       let left = List.find_mapi (fun i item ->
                        if ((compare_identity item.id new_item.id  ) = 0) then
                           Some ( i, item )
                        else None
                        ) doc_content  in
      (match left with
      | Some ( left_index , item ) ->
            let dest_location = left_index  + 1 in
            let right = (match new_item.origin_left with
                         | Some id ->
                           find_index doc_content id item
                         | None -> List.length doc_content
                        )
            in
            let rec loop_while i idx scanning =
              let idx =
              if not scanning then
                i
              else
                idx in

                if i = List.length doc_content || i = right then
                  Effect.perform ( Early_return  idx)
                else(
                  let other = List.nth doc_content i in
                  let other_left =
                           find_index doc_content other.origin_left new_item
                  in
                  let other_right =
                  (match other.origin_right with
                               | Some value ->
                                find_index doc_content other.origin_right new_item
                               | None -> List.length doc_content)
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
        (match loop_while  0 dest_location false with
         | idx ->
           List.concat (
               List.mapi (fun i x ->
                 if i = idx then [new_item; x] else [x]
               ) doc_content
             )
        | effect Early_return idx, k ->
           List.concat (
               List.mapi (fun i x ->
                 if i = idx then [new_item; x] else [x]
               ) doc_content
             )
       )
       | None -> failwith "Merge error"
      )

    end

end

module CRDTOp = Crdt
