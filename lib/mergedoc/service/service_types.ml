module type SERVEROperator = sig

 val start_server : Eio_unix.Net.t ->
   Eio_unix.Stdenv.base
   -> Capnp_rpc_unix.Network.Location.t ->string -> unit
 val getstatus_local : unit -> [`Status_d929570a7c0b0fa4] Capnp_rpc.Capability.t
 val getstatus : [`Status_d929570a7c0b0fa4] Capnp_rpc.Capability.t -> (int * int64 * string) Lwt.t
end


module  CapIdEntry = struct
  type t = int
  let compare x x1 =
    Int.compare x x1
end

module EntryMap = CCMap.Make(CapIdEntry)
type url_map = string EntryMap.t

let reverse v t =
  EntryMap.fold (fun k v' acc -> if (String.compare v  v' == 0) then Some k else acc) t None
let get_url cap_file =
  try
    let ch = open_in cap_file in
    let uri_str = input_line ch in
    close_in ch;
    `Ok (Uri.of_string uri_str)
  with
  | Sys_error msg -> `Error ("File error: " ^ msg)
  | End_of_file -> `Error "File is empty"
