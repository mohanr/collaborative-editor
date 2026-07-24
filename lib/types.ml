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

val get_x :  int
val get_y :  int
val get_width :  int
val get_height :  int
end


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
