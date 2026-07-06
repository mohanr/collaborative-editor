open Configurer_intf

module type Buffer_area =

sig
       type t = {
           (* The x coordinate of the top left corner of the `Area` *)
           x : int;
            (* The y coordinate of the top left corner of the `Rect` *)
           y : int;
            (* The width of the `Area` *)
           width : int;
            (* The height of the `Area` *)
           height : int
       }

val get_x :  int
val get_y :  int
val get_width :  int
val get_height :  int
val get_t : unit -> t
end

 module Area : Buffer_area = struct
       type t = {
           (* The x coordinate of the top left corner of the `Area` *)
           x : int;
            (* The y coordinate of the top left corner of the `Rect` *)
           y : int;
            (* The width of the `Area` *)
           width : int;
            (* The height of the `Area` *)
           height : int
       }
       let t = {
           (* The x coordinate of the top left corner of the `Area` *)
           x = 5;
            (* The y coordinate of the top left corner of the `Rect` *)
           y = 5;
            (* The width of the `Area` *)
           width = 5;
            (* The height of the `Area` *)
           height = 5
       }
 let get_t () = t
 let get_x  = t.x
 let get_y  = t.y
 let get_width  = t.width
 let get_height  = t.height
 let right() = t.x
end



module Buffer ( Area :  Buffer_area )= struct


module Area  = Area

type t = {
    area : Area.t;

    contents : Bytes.t;
}

let get_area() =
  (module Area:Buffer_area)

module Make( Config : Configurer_intf.Configurer) = struct
  let new_buffer ()  =
    let config= Config.set_size () in
    let area : Area.t = { x = 0;y = 0;
                 width = config.width; height  = config.height } in
    {area = area; contents = Bytes.create 100}

end

end

module type BufferMaker = sig
  module Make( Config : Configurer_intf.Configurer) : sig

    type t = {
        area : Area.t;

        contents : Bytes.t;
    }

    val new_buffer : unit -> t
  end
end

module BufferManipulator
                       ( Config : Configurer_intf.Configurer)
                       ( Buffer : BufferMaker)= struct

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
