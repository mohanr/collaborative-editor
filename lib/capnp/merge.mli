[@@@ocaml.warning "-27-32-37-60"]

type ro = Capnp.Message.ro
type rw = Capnp.Message.rw

module type S = sig
  module MessageWrapper : Capnp.RPC.S
  type 'cap message_t = 'cap MessageWrapper.Message.t
  type 'a reader_t = 'a MessageWrapper.StructStorage.reader_t
  type 'a builder_t = 'a MessageWrapper.StructStorage.builder_t


  module Reader : sig
    type array_t
    type builder_array_t
    type pointer_t = ro MessageWrapper.Slice.t option
    val of_pointer : pointer_t -> 'a reader_t
    module VersionTuple : sig
      type struct_t = [`VersionTuple_be5c09d305f9a058]
      type t = struct_t reader_t
      val has_key : t -> bool
      val key_get : t -> string
      val value_get : t -> int
      val of_message : 'cap message_t -> t
      val of_builder : struct_t builder_t -> t
    end
    module MergeDoc : sig
      type t = [`MergeDoc_a32eddf67702f1ec]
      module Mergedoc : sig
        module Params : sig
          type struct_t = [`Mergedoc_ee7286a7b7fbfd93]
          type t = struct_t reader_t
          val has_doccontent : t -> bool
          val doccontent_get : t -> (ro, VersionTuple.t, array_t) Capnp.Array.t
          val doccontent_get_list : t -> VersionTuple.t list
          val doccontent_get_array : t -> VersionTuple.t array
          val has_versionlist : t -> bool
          val versionlist_get : t -> (ro, int, array_t) Capnp.Array.t
          val versionlist_get_list : t -> int list
          val versionlist_get_array : t -> int array
          val of_message : 'cap message_t -> t
          val of_builder : struct_t builder_t -> t
        end
        module Results : sig
          type struct_t = [`Mergedoc_addff87e5b612119]
          type t = struct_t reader_t
          val of_message : 'cap message_t -> t
          val of_builder : struct_t builder_t -> t
        end
      end
    end
  end

  module Builder : sig
    type array_t = Reader.builder_array_t
    type reader_array_t = Reader.array_t
    type pointer_t = rw MessageWrapper.Slice.t
    module VersionTuple : sig
      type struct_t = [`VersionTuple_be5c09d305f9a058]
      type t = struct_t builder_t
      val has_key : t -> bool
      val key_get : t -> string
      val key_set : t -> string -> unit
      val value_get : t -> int
      val value_set_exn : t -> int -> unit
      val of_message : rw message_t -> t
      val to_message : t -> rw message_t
      val to_reader : t -> struct_t reader_t
      val init_root : ?message_size:int -> unit -> t
      val init_pointer : pointer_t -> t
    end
    module MergeDoc : sig
      type t = [`MergeDoc_a32eddf67702f1ec]
      module Mergedoc : sig
        module Params : sig
          type struct_t = [`Mergedoc_ee7286a7b7fbfd93]
          type t = struct_t builder_t
          val has_doccontent : t -> bool
          val doccontent_get : t -> (rw, VersionTuple.t, array_t) Capnp.Array.t
          val doccontent_get_list : t -> VersionTuple.t list
          val doccontent_get_array : t -> VersionTuple.t array
          val doccontent_set : t -> (rw, VersionTuple.t, array_t) Capnp.Array.t -> (rw, VersionTuple.t, array_t) Capnp.Array.t
          val doccontent_set_list : t -> VersionTuple.t list -> (rw, VersionTuple.t, array_t) Capnp.Array.t
          val doccontent_set_array : t -> VersionTuple.t array -> (rw, VersionTuple.t, array_t) Capnp.Array.t
          val doccontent_init : t -> int -> (rw, VersionTuple.t, array_t) Capnp.Array.t
          val has_versionlist : t -> bool
          val versionlist_get : t -> (rw, int, array_t) Capnp.Array.t
          val versionlist_get_list : t -> int list
          val versionlist_get_array : t -> int array
          val versionlist_set : t -> (rw, int, array_t) Capnp.Array.t -> (rw, int, array_t) Capnp.Array.t
          val versionlist_set_list : t -> int list -> (rw, int, array_t) Capnp.Array.t
          val versionlist_set_array : t -> int array -> (rw, int, array_t) Capnp.Array.t
          val versionlist_init : t -> int -> (rw, int, array_t) Capnp.Array.t
          val of_message : rw message_t -> t
          val to_message : t -> rw message_t
          val to_reader : t -> struct_t reader_t
          val init_root : ?message_size:int -> unit -> t
          val init_pointer : pointer_t -> t
        end
        module Results : sig
          type struct_t = [`Mergedoc_addff87e5b612119]
          type t = struct_t builder_t
          val of_message : rw message_t -> t
          val to_message : t -> rw message_t
          val to_reader : t -> struct_t reader_t
          val init_root : ?message_size:int -> unit -> t
          val init_pointer : pointer_t -> t
        end
      end
    end
  end
end

module MakeRPC(MessageWrapper : Capnp.RPC.S) : sig
  include S with module MessageWrapper = MessageWrapper

  module Client : sig
    module MergeDoc : sig
      type t = [`MergeDoc_a32eddf67702f1ec]
      val interface_id : Stdint.Uint64.t
      module Mergedoc : sig
        module Params = Builder.MergeDoc.Mergedoc.Params
        module Results = Reader.MergeDoc.Mergedoc.Results
        val method_id : (t, Params.t, Results.t) Capnp.RPC.MethodID.t
      end
    end
  end

  module Service : sig
    module MergeDoc : sig
      type t = [`MergeDoc_a32eddf67702f1ec]
      val interface_id : Stdint.Uint64.t
      module Mergedoc : sig
        module Params = Reader.MergeDoc.Mergedoc.Params
        module Results = Builder.MergeDoc.Mergedoc.Results
      end
      class virtual service : object
        inherit MessageWrapper.Untyped.generic_service
        method virtual mergedoc_impl : (Mergedoc.Params.t, Mergedoc.Results.t) MessageWrapper.Service.method_t
      end
      val local : #service -> t MessageWrapper.Capability.t
    end
  end
end

module Make(M : Capnp.MessageSig.S) : module type of MakeRPC(Capnp.RPC.None(M))
