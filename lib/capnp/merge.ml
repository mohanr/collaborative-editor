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

module MakeRPC(MessageWrapper : Capnp.RPC.S) = struct
  type 'a reader_t = 'a MessageWrapper.StructStorage.reader_t
  type 'a builder_t = 'a MessageWrapper.StructStorage.builder_t
  module CamlBytes = Bytes
  module DefaultsMessage_ = Capnp.BytesMessage

  let _builder_defaults_message =
    let message_segments = [
      Bytes.unsafe_of_string "\
      ";
    ] in
    DefaultsMessage_.Message.readonly
      (DefaultsMessage_.Message.of_storage message_segments)

  let invalid_msg = Capnp.Message.invalid_msg

  include Capnp.Runtime.BuilderInc.Make(MessageWrapper)

  type 'cap message_t = 'cap MessageWrapper.Message.t

  module DefaultsCopier_ =
    Capnp.Runtime.BuilderOps.Make(Capnp.BytesMessage)(MessageWrapper)

  let _reader_defaults_message =
    MessageWrapper.Message.create
      (DefaultsMessage_.Message.total_size _builder_defaults_message)


  module Reader = struct
    type array_t = ro MessageWrapper.ListStorage.t
    type builder_array_t = rw MessageWrapper.ListStorage.t
    type pointer_t = ro MessageWrapper.Slice.t option
    let of_pointer = RA_.deref_opt_struct_pointer

    module VersionTuple = struct
      type struct_t = [`VersionTuple_be5c09d305f9a058]
      type t = struct_t reader_t
      let has_key x =
        RA_.has_field x 0
      let key_get x =
        RA_.get_text ~default:"" x 0
      let value_get x =
        RA_.get_int16 ~default:(0) x 0
      let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
      let of_builder x = Some (RA_.StructStorage.readonly x)
    end
    module MergeDoc = struct
      type t = [`MergeDoc_a32eddf67702f1ec]
      module Mergedoc = struct
        module Params = struct
          type struct_t = [`Mergedoc_ee7286a7b7fbfd93]
          type t = struct_t reader_t
          let has_doccontent x =
            RA_.has_field x 0
          let doccontent_get x = 
            RA_.get_struct_list x 0
          let doccontent_get_list x =
            Capnp.Array.to_list (doccontent_get x)
          let doccontent_get_array x =
            Capnp.Array.to_array (doccontent_get x)
          let has_versionlist x =
            RA_.has_field x 1
          let versionlist_get x =
            RA_.get_int16_list x 1
          let versionlist_get_list x =
            Capnp.Array.to_list (versionlist_get x)
          let versionlist_get_array x =
            Capnp.Array.to_array (versionlist_get x)
          let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
          let of_builder x = Some (RA_.StructStorage.readonly x)
        end
        module Results = struct
          type struct_t = [`Mergedoc_addff87e5b612119]
          type t = struct_t reader_t
          let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
          let of_builder x = Some (RA_.StructStorage.readonly x)
        end
      end
    end
  end

  module Builder = struct
    type array_t = Reader.builder_array_t
    type reader_array_t = Reader.array_t
    type pointer_t = rw MessageWrapper.Slice.t

    module VersionTuple = struct
      type struct_t = [`VersionTuple_be5c09d305f9a058]
      type t = struct_t builder_t
      let has_key x =
        BA_.has_field x 0
      let key_get x =
        BA_.get_text ~default:"" x 0
      let key_set x v =
        BA_.set_text x 0 v
      let value_get x =
        BA_.get_int16 ~default:(0) x 0
      let value_set_exn x v =
        BA_.set_int16 ~default:(0) x 0 v
      let of_message x = BA_.get_root_struct ~data_words:1 ~pointer_words:1 x
      let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
      let to_reader x = Some (RA_.StructStorage.readonly x)
      let init_root ?message_size () =
        BA_.alloc_root_struct ?message_size ~data_words:1 ~pointer_words:1 ()
      let init_pointer ptr =
        BA_.init_struct_pointer ptr ~data_words:1 ~pointer_words:1
    end
    module MergeDoc = struct
      type t = [`MergeDoc_a32eddf67702f1ec]
      module Mergedoc = struct
        module Params = struct
          type struct_t = [`Mergedoc_ee7286a7b7fbfd93]
          type t = struct_t builder_t
          let has_doccontent x =
            BA_.has_field x 0
          let doccontent_get x = 
            BA_.get_struct_list ~data_words:1 ~pointer_words:1 x 0
          let doccontent_get_list x =
            Capnp.Array.to_list (doccontent_get x)
          let doccontent_get_array x =
            Capnp.Array.to_array (doccontent_get x)
          let doccontent_set x v =
            BA_.set_struct_list ~data_words:1 ~pointer_words:1 x 0 v
          let doccontent_init x n =
            BA_.init_struct_list ~data_words:1 ~pointer_words:1 x 0 n
          let doccontent_set_list x v =
            let builder = doccontent_init x (List.length v) in
            let () = List.iteri (fun i a -> Capnp.Array.set builder i a) v in
            builder
          let doccontent_set_array x v =
            let builder = doccontent_init x (Array.length v) in
            let () = Array.iteri (fun i a -> Capnp.Array.set builder i a) v in
            builder
          let has_versionlist x =
            BA_.has_field x 1
          let versionlist_get x =
            BA_.get_int16_list x 1
          let versionlist_get_list x =
            Capnp.Array.to_list (versionlist_get x)
          let versionlist_get_array x =
            Capnp.Array.to_array (versionlist_get x)
          let versionlist_set x v =
            BA_.set_int16_list x 1 v
          let versionlist_init x n =
            BA_.init_int16_list x 1 n
          let versionlist_set_list x v =
            let builder = versionlist_init x (List.length v) in
            let () = List.iteri (fun i a -> Capnp.Array.set builder i a) v in
            builder
          let versionlist_set_array x v =
            let builder = versionlist_init x (Array.length v) in
            let () = Array.iteri (fun i a -> Capnp.Array.set builder i a) v in
            builder
          let of_message x = BA_.get_root_struct ~data_words:0 ~pointer_words:2 x
          let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
          let to_reader x = Some (RA_.StructStorage.readonly x)
          let init_root ?message_size () =
            BA_.alloc_root_struct ?message_size ~data_words:0 ~pointer_words:2 ()
          let init_pointer ptr =
            BA_.init_struct_pointer ptr ~data_words:0 ~pointer_words:2
        end
        module Results = struct
          type struct_t = [`Mergedoc_addff87e5b612119]
          type t = struct_t builder_t
          let of_message x = BA_.get_root_struct ~data_words:0 ~pointer_words:0 x
          let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
          let to_reader x = Some (RA_.StructStorage.readonly x)
          let init_root ?message_size () =
            BA_.alloc_root_struct ?message_size ~data_words:0 ~pointer_words:0 ()
          let init_pointer ptr =
            BA_.init_struct_pointer ptr ~data_words:0 ~pointer_words:0
        end
      end
    end
  end

  module Client = struct
    module MergeDoc = struct
      type t = [`MergeDoc_a32eddf67702f1ec]
      let interface_id = Stdint.Uint64.of_string "0xa32eddf67702f1ec"
      module Mergedoc = struct
        module Params = Builder.MergeDoc.Mergedoc.Params
        module Results = Reader.MergeDoc.Mergedoc.Results
        let method_id : (t, Params.t, Results.t) Capnp.RPC.MethodID.t =
          Capnp.RPC.MethodID.v ~interface_id ~method_id:0
      end
      let method_name = function
        | 0 -> Some "mergedoc"
        | _ -> None
      let () = Capnp.RPC.Registry.register ~interface_id ~name:"MergeDoc" method_name
    end
  end

  module Service = struct
    module MergeDoc = struct
      type t = [`MergeDoc_a32eddf67702f1ec]
      let interface_id = Stdint.Uint64.of_string "0xa32eddf67702f1ec"
      module Mergedoc = struct
        module Params = Reader.MergeDoc.Mergedoc.Params
        module Results = Builder.MergeDoc.Mergedoc.Results
      end
      class virtual service = object (self)
        method release = ()
        method dispatch ~interface_id:i ~method_id =
          if i <> interface_id then MessageWrapper.Untyped.unknown_interface ~interface_id:i
          else match method_id with
          | 0 -> MessageWrapper.Untyped.abstract_method self#mergedoc_impl
          | x -> MessageWrapper.Untyped.unknown_method ~interface_id ~method_id
        method pp f = Format.pp_print_string f "MergeDoc"
        method virtual mergedoc_impl : (Mergedoc.Params.t, Mergedoc.Results.t) MessageWrapper.Service.method_t
      end
      let local (service:#service) =
        MessageWrapper.Untyped.local service
    end
  end
  module MessageWrapper = MessageWrapper
end

module Make(M:Capnp.MessageSig.S) = MakeRPC(Capnp.RPC.None(M))
