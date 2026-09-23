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
