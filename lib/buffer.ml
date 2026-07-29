open Configurer_intf
open Stdlib
open Types


module type BUFFERMAKER = sig

  type t
  module Make( Config : Configurer_intf.Configurer) : sig
    val new_buffer : unit -> t
  end
end


module Buffer ( Area :  Types.Arena )
  :BUFFERMAKER with  type t=Types.t
                                   = struct

type t = Types.t

let get_area() =
  (module Area:Arena)

module Make( Config : Configurer_intf.Configurer) = struct
  let new_buffer ()  =
    let config= Config.set_size 10 10 in
    let area : Types.Area.t = { x = 0;y = 0;
                 width = config.width; height  = config.height } in
    {area = area; contents = Buffer.create 4096}

end

end
(* This is supposed to manipulate the buffer *)
module BufferManipulator
                       ( Config : Configurer_intf.Configurer)
                       ( Buffer : BUFFERMAKER)= struct

let make_buffer() =
 let module B =   Buffer.Make(Config) in
  B.new_buffer()


 (* let set_stringn *)
 (*        x *)
 (*        y *)
 (*        s *)
 (*        max_width = *)

 (*        let buf = make_buffer() in *)
 (*        match buf with *)
 (*        |{ area; contents } -> *)

end
