open Eio.Std
open Collaborative_editor__Snowflake
open Service_types
open Collaborative_editor__Crdt
open Configurer_intf
open Tuiservice
open Tuioperator
open Collaborative_editor__Logger.Logger

(* Adapted from my Raft multi-node code *)
type single_node = {
    no_of_nodes : int;
	server_cap_files : string list;
}
[@@deriving_show]

let snowflake_id = ref 0

let create_config_node env no  : (module Node)=

let node = create_snowflake_node (Int64.of_int 0) in
 let cap_id_map =
  let rec loop_while  i map =
    if i < no then(
      let path = ( "/Users/anu/Documents/rays/collaborative-editor/lib/mergedoc/service/"
                   ^ ( Int.to_string i) ^ ".cap") in
        let id = generate node in
        let map = EntryMap.add
         (match id with | Ok v ->  snowflake_id := Int64.to_int v;
                                   Int64.to_int v;
                        | Error _ -> failwith
                                         "Unable to get snowflake id")
        path map in
      loop_while (i + 1) map
    ) else map
  in
  loop_while 0 EntryMap.empty in
  let module Config_node = struct
    let cap_id_map = cap_id_map
    let env = env
  end in
  (module Config_node: Configurer_intf.Node )

let  new_cluster no_of_nodes env sw=
   let n = create_config_node env no_of_nodes in
   let module Config_Node = (val n  : Configurer_intf.Node)  in

   let listen_address = [`TCP ("127.0.0.1", 8888) ] in

   let list_of_servers =
   let rec loop_while la p i =

    if i < no_of_nodes then(
      let path = ( "/Users/anu/Documents/rays/collaborative-editor/lib/mergedoc/service/" ^ ( Int.to_string i) ^ ".cap") in

      Printf.printf "Generating snowflake Id";
      let module TuiService = TuiService.Make(TUIOp) in
      Fiber.fork_daemon ~sw ( fun () ->
          ignore(TuiService.start_server  env#net env  (List.nth la i) path
                   (match (reverse path Config_Node.cap_id_map ) with
                    | Some k -> k
                    |None -> failwith "Wrong snowflake Id"));
          `Stop_daemon

      );
      Printf.printf "\nNode %d\n" i;
      loop_while la ( p @ [path]) (i + 1)
    )
    else p
   in
   loop_while listen_address [] 0
   in
	 {
      no_of_nodes = no_of_nodes;
      server_cap_files = list_of_servers;
	 }



let run_client _env service =
  let open Lwt.Syntax in
  let open Crdtclient.Client in
  (* TODO LET* *)
  let _ = mergedoc service in
  Printf.printf "Client invoked RPC\n%!" ;

  Lwt.return_unit

let connect net env uri sw =
  (* Switch.run @@ fun sw -> *)
  let client_vat = Capnp_rpc_unix.client_only_vat ~sw net in
  let sr = Capnp_rpc_unix.Vat.import_exn client_vat uri in
  Capnp_rpc_unix.with_cap_exn sr (fun cap -> Lwt_eio.run_lwt ( fun () -> run_client env cap))

let boot_server() =
  Logs.set_reporter (lwt_reporter
                       ("/Users/anu/Documents/rays/collaborative-editor/" ^
                        ( Int.to_string !snowflake_id ) ^ ".log"));
  Eio_main.run @@ fun env ->
  Lwt_eio.with_event_loop ~clock:(Eio.Stdenv.clock env) @@ fun () ->
  Eio.Switch.run (fun sw ->
  Logs.set_level (Some Debug);
  (* Waiting here to allow the server to start properly *)
  let new_cluster = new_cluster 1 env sw in
  let t = Timedesc.Span.make  ~s:95L () in
  Eio.Time.sleep (Eio.Stdenv.clock env) (Timedesc.Span.to_float_s t) ;
  let rec loop_while  i  =
  let t = Timedesc.Span.make  ~s:30L () in
  Eio.Time.sleep (Eio.Stdenv.clock env) (Timedesc.Span.to_float_s t) ;
  if i < new_cluster.no_of_nodes then(
      let _ = connect env#net env
       (match (get_url (List.nth new_cluster.server_cap_files i)) with
         | `Error _ -> failwith "Error in Uri.t"
         | `Ok o -> o) sw in
      loop_while  (i + 1));
  in
  loop_while 0;
  (* Eio.Switch.fail sw (Failure "Normal test cancellation"); *)
  )
