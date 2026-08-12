open Ppx_compare_lib
open Ppx_deriving_runtime
open Base

type style =
  | VeBorder of string
  | HoBorder of string
  | Glyph of string


module type Arena =

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

val get_area : unit -> t
val get_x : unit -> int
val get_y :  unit ->int
val get_width :  unit ->int
val get_height : unit -> int
end

 module Area : Arena = struct
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
           width = 21;
            (* The height of the `Area` *)
           height = 5
       }
 let get_area()  = t
 let get_x()  = t.x
 let get_y()  = t.y
 let get_width()  = t.width
 let get_height()  = t.height
 let right() = t.x
end

type t = {
        area : Area.t;

        contents : Stdlib.Buffer.t;
}

type test_driver = {
    pos: int * int
}
type plain = {
    top_left: string;
    top_right: string;
    bottom_left: string;
    bottom_right: string;
    vertical_left: string;
    vertical_right: string;
    horizontal_top: string;
    horizontal_bottom: string
}

type location = {

  x : int;

  y: int

}
type ansi_escape_codes = {
  text_cursor_enable: string;
  reset_text_cursor_enable: string
}
type identity = {
  agent : string Option.t;
  seq : int Option.t
}
[@@deriving sexp ,compare]

type item = {
  content : string;
  id : identity ;
  origin_left : identity Option.t;
  origin_right :identity Option.t;
  deleted :  bool
}
[@@deriving sexp ,compare]


type doc ={
  doc_content : item list
}


module type CRDTOperator = sig

  module Crdt_buffer : sig
    val merge : item list -> item -> item list
    val make : unit -> doc
  end
end
