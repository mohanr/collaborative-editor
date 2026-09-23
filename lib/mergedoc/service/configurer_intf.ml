open Service_types

module MakeConfigurer = struct


type  config = {

	other_nodes : string EntryMap.t;

 env : Eio_unix.Stdenv.base

}

end

module type Configurer=
sig

  include module type of MakeConfigurer
  val set_config: unit ->  config

end


module type Node = sig
    val cap_id_map : string EntryMap.t
    val env : Eio_unix.Stdenv.base

end
module type MAKER = Configurer

module type Intf = sig
  module Make(_:Node) : MAKER

end
